import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../core/error/app_error.dart';
import '../core/logging/app_log.dart';
import 'providers.dart';

enum SessionPhase { checking, signedOut, bootstrapping, ready }

class SessionState {
  const SessionState({this.phase = SessionPhase.checking, this.notice});
  final SessionPhase phase;
  final String? notice; // one-shot message for the UI (shown, then cleared)
  SessionState copyWith({SessionPhase? phase, Object? notice = _keep}) =>
      SessionState(phase: phase ?? this.phase, notice: identical(notice, _keep) ? this.notice : notice as String?);
}

const _keep = Object();

/// Auth → first-sync → app. Offline with a persisted session goes straight in;
/// an expired token while offline never signs the user out.
class SessionController extends Notifier<SessionState> {
  StreamSubscription<sb.AuthState>? _sub;
  String? _activeUid;

  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  @override
  SessionState build() {
    _sub = _client.auth.onAuthStateChange.listen((e) {
      if (e.event == sb.AuthChangeEvent.signedIn && e.session != null) {
        unawaited(_onSignedIn(e.session!.user.id));
      } else if (e.event == sb.AuthChangeEvent.signedOut) {
        _activeUid = null;
        state = state.copyWith(phase: SessionPhase.signedOut);
      }
    });
    ref.onDispose(() => _sub?.cancel());
    Future.microtask(_init);
    return const SessionState();
  }

  Future<void> _init() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      state = state.copyWith(phase: SessionPhase.signedOut);
    } else {
      await _onSignedIn(user.id);
    }
  }

  Future<void> _onSignedIn(String uid) async {
    if (_activeUid == uid && state.phase == SessionPhase.ready) return;
    try {
      final db = ref.read(dbProvider);
      final previous = await db.kvGet('user_id');
      if (previous != null && previous != uid) {
        // A different user may only take over a device with nothing unsynced.
        final pending = await db.select(db.outbox).get();
        if (pending.isNotEmpty) {
          await _client.auth.signOut();
          state = state.copyWith(
            phase: SessionPhase.signedOut,
            notice: 'This device has unsynced changes for another account. Sign in with that account first.',
          );
          return;
        }
        await ref.read(syncEngineProvider).wipeLocalSyncedData();
      }
      await db.kvSet('user_id', uid);
      ref.read(cachedUserIdProvider.notifier).state = uid;
      _activeUid = uid;

      final engine = ref.read(syncEngineProvider);
      if (await engine.isBootstrapped()) {
        state = state.copyWith(phase: SessionPhase.ready);
        await engine.start();
        engine.clearAuthRequired();
        unawaited(ref.read(proofServiceProvider).cleanupOrphans(db));
      } else {
        state = state.copyWith(phase: SessionPhase.bootstrapping);
      }
    } catch (e, st) {
      AppLog.line('session', 'sign-in handling failed: $e\n$st');
      state = state.copyWith(phase: SessionPhase.signedOut, notice: toFailure(e, st).message);
    }
  }

  /// The first full pull finished: enter the app and start syncing.
  Future<void> bootstrapDone() async {
    state = state.copyWith(phase: SessionPhase.ready);
    await ref.read(syncEngineProvider).start();
  }

  void clearNotice() => state = state.copyWith(notice: null);
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Triggers a sync whenever the app returns to the foreground.
class ResumeSync extends Notifier<void> with WidgetsBindingObserver {
  @override
  void build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed && ref.read(sessionProvider).phase == SessionPhase.ready) {
      ref.read(syncEngineProvider).onResume();
    }
  }
}

final resumeSyncProvider = NotifierProvider<ResumeSync, void>(ResumeSync.new);
