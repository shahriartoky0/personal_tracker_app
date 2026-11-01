import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Table, TableInfo;

import '../../logging/app_log.dart';
import '../db/database.dart';
import '../remote/remote_failure.dart';
import '../remote/remote_gateway.dart';
import 'outbox_service.dart';
import 'pull_engine.dart';
import 'push_engine.dart';
import 'resolvers.dart';
import 'sync_status.dart';
import 'sync_tables.dart';

/// Single-flight orchestrator (§11): push → pull → push again if needed.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.remote,
    required this.outbox,
    required this.clientVersion,
    int Function()? nowMs,
  }) : _now = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch) {
    tables = SyncTables(db);
    resolvers = UniqueResolvers(db, remote, tables, nowMs: _now);
    push = PushEngine(db: db, remote: remote, tables: tables, resolvers: resolvers, nowMs: _now);
    pull = PullEngine(db: db, remote: remote, tables: tables, nowMs: _now);
  }

  final AppDatabase db;
  final RemoteGateway remote;
  final OutboxService outbox;
  final String clientVersion;
  final int Function() _now;

  late final SyncTables tables;
  late final UniqueResolvers resolvers;
  late final PushEngine push;
  late final PullEngine pull;

  final _statusCtl = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncOffline();
  SyncStatus get currentStatus => _status;
  Stream<SyncStatus> get status async* {
    yield _status;
    yield* _statusCtl.stream;
  }

  bool _running = false;
  bool _rerun = false;
  bool _disposed = false;
  bool _authRequired = false;
  bool _updateRequired = false;
  bool _offline = false;
  int? _lastSyncedMs;
  int _pending = 0;
  int _attention = 0;
  Timer? _debounce;
  Timer? _periodic;
  StreamSubscription<dynamic>? _connSub;
  StreamSubscription<int>? _pendingSub;
  StreamSubscription<int>? _attentionSub;

  /// Bootstrap progress for the first-sign-in screen.
  final bootstrapProgress = StreamController<({String entity, int index, int total})>.broadcast();

  Future<void> start() async {
    await push.resetInFlight();
    _pendingSub = outbox.watchPendingCount().listen((n) {
      _pending = n;
      _emit();
    });
    _attentionSub = outbox.watchAttentionCount().listen((n) {
      _attention = n;
      _emit();
    });
    _connSub = Connectivity().onConnectivityChanged.listen((r) {
      if (!r.contains(ConnectivityResult.none)) kick(immediate: true);
    });
    _periodic = Timer.periodic(const Duration(minutes: 5), (_) => kick());
    kick(immediate: true);
  }

  /// Non-blocking trigger (debounced ~1 s after local writes).
  void kick({bool immediate = false}) {
    if (_disposed) return;
    _debounce?.cancel();
    if (immediate) {
      unawaited(syncNow());
    } else {
      _debounce = Timer(const Duration(seconds: 1), () => unawaited(syncNow()));
    }
  }

  void onResume() => kick(immediate: true);

  /// User signed in again as the same user.
  void clearAuthRequired() {
    _authRequired = false;
    kick(immediate: true);
  }

  Future<void> syncNow() async {
    if (_disposed) return;
    if (_running) {
      _rerun = true;
      return;
    }
    _running = true;
    try {
      do {
        _rerun = false;
        await _pass();
      } while (_rerun && !_disposed);
    } finally {
      _running = false;
      _emit();
    }
  }

  Future<void> _pass() async {
    AppLog.line('sync', 'pass start (pending ops: $_pending)');
    if (_authRequired || _updateRequired) {
      _emit();
      return;
    }
    if (!await remote.isReachable()) {
      AppLog.line('sync', 'offline — skipping pass');
      _offline = true;
      _emit();
      return;
    }
    _offline = false;
    _setStatus(SyncSyncing(done: 0, total: _pending));
    try {
      if (!await _versionOk()) {
        _updateRequired = true;
        return;
      }
      var outcome = await push.run(onProgress: (d, t) => _setStatus(SyncSyncing(done: d, total: t)));
      if (outcome == PushOutcome.authRequired) {
        _authRequired = true;
        return;
      }
      if (outcome == PushOutcome.offline) {
        _offline = true;
        return;
      }
      await _maybeRebootstrap();
      await pull.pullAll();
      // New local changes may have appeared while pulling.
      outcome = await push.run();
      if (outcome == PushOutcome.authRequired) {
        _authRequired = true;
        return;
      }
      if (outcome == PushOutcome.drained) _lastSyncedMs = _now();
    } catch (e) {
      final f = classifyError(e);
      if (f.kind == FailureKind.auth) {
        if (await remote.isReachable() && !await remote.refreshSession()) _authRequired = true;
      } else if (f.isOffline) {
        _offline = true;
      }
    }
  }

  Future<bool> _versionOk() async {
    try {
      final cfg = await remote.fetchAppConfig();
      final min = cfg?['min_client_version'] as String?;
      if (min == null) return true;
      return _compareSemver(clientVersion, min) >= 0;
    } catch (_) {
      return true; // never block on a failed config read
    }
  }

  int _compareSemver(String a, String b) {
    List<int> p(String s) => s.split('+').first.split('.').map((x) => int.tryParse(x) ?? 0).toList();
    final x = p(a), y = p(b);
    for (var i = 0; i < 3; i++) {
      final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
      if (d != 0) return d;
    }
    return 0;
  }

  /// Safe re-bootstrap only when the outbox is empty (§9.5).
  Future<void> _maybeRebootstrap() async {
    if (!await pull.retentionExceeded()) return;
    if (await push.remainingCount() > 0 || _attention > 0) return;
    await rebuildFromServer();
  }

  /// First-sign-in / rebuild. Wipes synced tables only if the outbox is empty.
  Future<bool> rebuildFromServer() async {
    final pendingOps = await db.select(db.outbox).get();
    if (pendingOps.isNotEmpty) return false;
    await wipeLocalSyncedData();
    await bootstrap();
    return true;
  }

  /// Clears every synced table + cursors. Caller must ensure the outbox is empty.
  Future<void> wipeLocalSyncedData() async {
    await db.transaction(() async {
      for (final t in <TableInfo<Table, dynamic>>[
        db.transactions,
        db.budgetAllocations,
        db.dailyBudgets,
        db.budgetTemplates,
        db.plannedExpenses,
        db.reminderPreferences,
        db.payees,
        db.categories,
        db.accounts,
      ]) {
        await db.delete(t).go();
      }
      await db.delete(db.syncCursors).go();
      await db.delete(db.profiles).go();
      await db.delete(db.localKv).go();
    });
  }

  /// Full pull in dependency order with progress. Needs a connection.
  Future<void> bootstrap() async {
    await pull.pullAll(
      fullBootstrap: true,
      onTable: (e, i, t) => bootstrapProgress.add((entity: e, index: i, total: t)),
    );
    await pull.markBootstrapped();
    _lastSyncedMs = _now();
    _emit();
  }

  Future<bool> isBootstrapped() => pull.isBootstrapped();

  void _setStatus(SyncStatus s) {
    _status = s;
    if (!_statusCtl.isClosed) _statusCtl.add(s);
  }

  void _emit() {
    final SyncStatus s;
    if (_updateRequired) {
      s = const SyncUpdateRequired();
    } else if (_authRequired) {
      s = const SyncAuthRequired();
    } else if (_running && _status is SyncSyncing) {
      return; // progress already published by the pass
    } else if (_attention > 0) {
      s = SyncAttention(_attention);
    } else if (_offline) {
      s = SyncOffline(pending: _pending);
    } else if (_pending > 0) {
      s = SyncPending(_pending);
    } else {
      s = SyncIdle(lastSyncedAtMs: _lastSyncedMs);
    }
    _setStatus(s);
  }

  Future<void> dispose() async {
    _disposed = true;
    push.cancelled = true;
    pull.cancelled = true;
    _debounce?.cancel();
    _periodic?.cancel();
    await _connSub?.cancel();
    await _pendingSub?.cancel();
    await _attentionSub?.cancel();
    await _statusCtl.close();
    await bootstrapProgress.close();
  }
}
