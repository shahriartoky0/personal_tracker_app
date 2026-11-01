import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../logging/app_log.dart';
import '../db/database.dart';
import '../remote/remote_failure.dart';
import '../remote/remote_gateway.dart';
import 'resolvers.dart';
import 'sync_tables.dart';

enum PushOutcome { drained, offline, authRequired, stopped }

/// Outbox → Supabase (§8, Appendix B). Strict FIFO, one request at a time.
class PushEngine {
  PushEngine({
    required this.db,
    required this.remote,
    required this.tables,
    required this.resolvers,
    int Function()? nowMs,
    Random? random,
  })  : _now = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch),
        _rnd = random ?? Random();

  final AppDatabase db;
  final RemoteGateway remote;
  final SyncTables tables;
  final UniqueResolvers resolvers;
  final int Function() _now;
  final Random _rnd;

  bool cancelled = false;

  /// Crash recovery: only at startup.
  Future<void> resetInFlight() => (db.update(db.outbox)..where((o) => o.status.equals('in_flight')))
      .write(const OutboxCompanion(status: Value('pending')));

  Future<OutboxRow?> _nextReady() => (db.select(db.outbox)
        ..where((o) => o.status.equals('pending') & o.nextAttemptAtMs.isSmallerOrEqualValue(_now()))
        ..orderBy([(o) => OrderingTerm.asc(o.seq)])
        ..limit(1))
      .getSingleOrNull();

  Future<int> remainingCount() async {
    final c = db.outbox.seq.count();
    final q = db.selectOnly(db.outbox)
      ..addColumns([c])
      ..where(db.outbox.status.isIn(const ['pending', 'in_flight']));
    return (await q.getSingle()).read(c) ?? 0;
  }

  Future<PushOutcome> run({void Function(int done, int total)? onProgress}) async {
    final total = await remainingCount();
    var done = 0;
    while (!cancelled) {
      final op = await _nextReady();
      if (op == null) return PushOutcome.drained;
      await (db.update(db.outbox)..where((o) => o.seq.equals(op.seq)))
          .write(const OutboxCompanion(status: Value('in_flight')));
      try {
        AppLog.line('sync.push', '→ #${op.seq} ${op.op} ${op.entity} ${op.entityId} (attempt ${op.attempts + 1})');
        final updated = await _apply(op);
        AppLog.line('sync.push', '✓ #${op.seq} ${op.op} ${op.entity} done');
        await _complete(op, updated);
        done++;
        onProgress?.call(done, total);
      } catch (e) {
        final f = classifyError(e);
        AppLog.line('sync.push', '✗ #${op.seq} ${op.op} ${op.entity} ${f.kind.name}${f.code != null ? ' [${f.code}]' : ''}: ${f.message}');
        switch (f.kind) {
          case FailureKind.transient:
            await _backoff(op, f.message);
            return f.isOffline ? PushOutcome.offline : PushOutcome.stopped;
          case FailureKind.auth:
            await _release(op);
            if (!await remote.isReachable()) return PushOutcome.offline;
            if (!await remote.refreshSession()) return PushOutcome.authRequired;
            // refreshed: loop retries the op
            break;
          case FailureKind.unique:
            await _release(op);
            final resolved = await resolvers.resolve(op);
            if (!resolved) await _park(op, f.message);
            break;
          case FailureKind.permanent:
            if (op.op == 'upload_proof') {
              await _dropFailedProof(op, f.message);
            } else {
              await _park(op, f.message);
            }
            break;
        }
      }
    }
    return PushOutcome.stopped;
  }

  Future<Map<String, String?>> _apply(OutboxRow op) async {
    final table = tables.of(op.entity);
    switch (op.op) {
      case 'upsert':
        final row = jsonDecode(op.payload) as Map<String, dynamic>;
        final updated = await remote.upsert(op.entity, row, table.onConflict);
        return {row['id'] as String: updated};
      case 'upsert_batch':
        final rows = (jsonDecode(op.payload) as List).cast<Map<String, dynamic>>();
        return remote.upsertBatch(op.entity, rows, table.onConflict);
      case 'delete':
        await remote.delete(op.entity, op.entityId);
        return {};
      case 'upload_proof':
        final p = jsonDecode(op.payload) as Map<String, dynamic>;
        final path = p['path'] as String;
        await remote.uploadProof(path, p['localFile'] as String, _contentTypeOf(path));
        await (db.update(db.transactions)..where((t) => t.receiptPath.equals(path)))
            .write(const TransactionsCompanion(receiptLocalFile: Value(null)));
        return {};
      case 'delete_proof':
        final dp = jsonDecode(op.payload) as Map<String, dynamic>;
        try {
          await remote.deleteProof(dp['path'] as String);
        } catch (e) {
          // Best-effort: only retry on transient errors.
          if (classifyError(e).kind == FailureKind.transient) rethrow;
        }
        return {};
      default:
        throw RemoteFailure(FailureKind.permanent, 'Unsupported operation: ${op.op}');
    }
  }

  /// One local txn: remove op; mark rows synced unless another op pends.
  Future<void> _complete(OutboxRow op, Map<String, String?> updatedById) async {
    await db.transaction(() async {
      await (db.delete(db.outbox)..where((o) => o.seq.equals(op.seq))).go();
      final table = tables.of(op.entity);
      for (final e in updatedById.entries) {
        final more = await (db.select(db.outbox)
              ..where((o) => o.entity.equals(op.entity) & o.entityId.equals(e.key))
              ..limit(1))
            .get();
        if (more.isEmpty) {
          await table.markSynced(e.key, e.value);
        } else {
          // Still has queued changes: keep pending but remember the new base.
          await (db.update(db.outbox)..where((o) => o.entity.equals(op.entity) & o.entityId.equals(e.key)))
              .write(OutboxCompanion(baseUpdatedAt: Value(e.value)));
        }
      }
    });
  }

  String _contentTypeOf(String path) {
    final l = path.toLowerCase();
    if (l.endsWith('.png')) return 'image/png';
    if (l.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  /// Permanent upload failure (too large / wrong type / file gone): clear
  /// receipt_path on the row and on queued upserts, and tell the user via the
  /// conflict log shown on the diagnostics screen.
  Future<void> _dropFailedProof(OutboxRow op, String message) async {
    final path = (jsonDecode(op.payload) as Map<String, dynamic>)['path'] as String;
    await db.transaction(() async {
      await (db.delete(db.outbox)..where((o) => o.seq.equals(op.seq))).go();
      await (db.update(db.transactions)..where((t) => t.receiptPath.equals(path))).write(
          const TransactionsCompanion(
              receiptPath: Value(null), receiptLocalFile: Value(null), pending: Value(true)));
      final ups = await (db.select(db.outbox)
            ..where((o) => o.entity.equals('transactions') & o.op.like('upsert%')))
          .get();
      for (final u in ups) {
        final decoded = jsonDecode(u.payload);
        var changed = false;
        void fix(Object? m) {
          if (m is Map && m['receipt_path'] == path) {
            m['receipt_path'] = null;
            changed = true;
          }
        }
        if (decoded is List) {
          decoded.forEach(fix);
        } else {
          fix(decoded);
        }
        if (changed) {
          await (db.update(db.outbox)..where((o) => o.seq.equals(u.seq)))
              .write(OutboxCompanion(payload: Value(jsonEncode(decoded))));
        }
      }
      await db.into(db.conflictLog).insert(ConflictLogCompanion.insert(
            entity: 'proof',
            entityId: path,
            serverVersionJson: jsonEncode({'error': message}),
            resolution: 'proof_removed',
            atMs: _now(),
          ));
    });
  }

  Future<void> _release(OutboxRow op) => (db.update(db.outbox)..where((o) => o.seq.equals(op.seq)))
      .write(const OutboxCompanion(status: Value('pending')));

  int _delayMs(int attempts) {
    final secs = min(300, 2 * pow(2, attempts).toInt());
    final jitter = 0.8 + _rnd.nextDouble() * 0.4;
    return (secs * 1000 * jitter).round();
  }

  Future<void> _backoff(OutboxRow op, String message) =>
      (db.update(db.outbox)..where((o) => o.seq.equals(op.seq))).write(OutboxCompanion(
        status: const Value('pending'),
        attempts: Value(op.attempts + 1),
        nextAttemptAtMs: Value(_now() + _delayMs(op.attempts)),
        lastError: Value(message),
      ));

  /// Permanent failure: mark failed, block later ops that reference it.
  Future<void> _park(OutboxRow op, String message) async {
    await db.transaction(() async {
      await (db.update(db.outbox)..where((o) => o.seq.equals(op.seq))).write(OutboxCompanion(
        status: const Value('failed'),
        lastError: Value(message),
        attempts: Value(op.attempts + 1),
      ));
      final later = await (db.select(db.outbox)
            ..where((o) => o.seq.isBiggerThanValue(op.seq) & o.status.equals('pending')))
          .get();
      final ids = _idsIn(op);
      for (final l in later) {
        if (ids.any((id) => l.entityId == id || l.payload.contains(id))) {
          await (db.update(db.outbox)..where((o) => o.seq.equals(l.seq))).write(OutboxCompanion(
            status: const Value('blocked'),
            lastError: Value('Waiting on a failed change (${op.entity}).'),
          ));
        }
      }
    });
  }

  Set<String> _idsIn(OutboxRow op) {
    final ids = <String>{op.entityId};
    try {
      final p = jsonDecode(op.payload);
      if (p is Map && p['id'] is String) ids.add(p['id'] as String);
      if (p is List) {
        for (final r in p) {
          if (r is Map && r['id'] is String) ids.add(r['id'] as String);
        }
      }
    } catch (_) {}
    return ids;
  }

  // ── User actions on parked ops (diagnostics screen) ─────────────────────
  Future<void> retry(int seq) async {
    await (db.update(db.outbox)..where((o) => o.seq.equals(seq))).write(const OutboxCompanion(
      status: Value('pending'),
      attempts: Value(0),
      nextAttemptAtMs: Value(0),
      lastError: Value(null),
    ));
    // Unblock dependents.
    await (db.update(db.outbox)..where((o) => o.status.equals('blocked')))
        .write(const OutboxCompanion(status: Value('pending'), lastError: Value(null)));
  }

  /// Discard: drop the op and revert the local row to its last synced state.
  Future<void> discard(int seq) async {
    final op = await (db.select(db.outbox)..where((o) => o.seq.equals(seq))).getSingleOrNull();
    if (op == null) return;
    await db.transaction(() async {
      await (db.delete(db.outbox)..where((o) => o.seq.equals(seq))).go();
      final ids = _idsIn(op);
      final table = tables.of(op.entity);
      for (final id in ids) {
        if (!await table.exists(id)) continue;
        final remoteAt = await table.remoteUpdatedAtOf(id);
        if (remoteAt == null) {
          await table.deleteLocal(id); // never reached server
        } else {
          final server = await remote.fetchByColumn(op.entity, 'id', id).catchError((_) => null);
          if (server != null) await table.applyServerRow(server);
        }
      }
      // Unblock whatever was waiting on this op.
      await (db.update(db.outbox)..where((o) => o.status.equals('blocked')))
          .write(const OutboxCompanion(status: Value('pending'), lastError: Value(null)));
    });
  }
}
