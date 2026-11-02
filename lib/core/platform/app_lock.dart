import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../ui/motion.dart';

class LockState {
  const LockState({
    this.loaded = false,
    this.enabled = false,
    this.timeoutMinutes = 1,
    this.locked = true,
    this.inactive = false,
  });
  final bool loaded;
  final bool enabled;
  final int timeoutMinutes;
  final bool locked;
  final bool inactive;

  LockState copyWith({
    bool? loaded,
    bool? enabled,
    int? timeoutMinutes,
    bool? locked,
    bool? inactive,
  }) => LockState(
    loaded: loaded ?? this.loaded,
    enabled: enabled ?? this.enabled,
    timeoutMinutes: timeoutMinutes ?? this.timeoutMinutes,
    locked: locked ?? this.locked,
    inactive: inactive ?? this.inactive,
  );
}

Future<bool> deviceCanAuthenticate() async {
  try {
    return await LocalAuthentication().isDeviceSupported();
  } catch (_) {
    return false;
  }
}

/// App lock: owns the persisted settings, the lock/unlock state, the
/// background timer and the biometric prompt. Observes the app lifecycle
/// itself, so no widget needs a State object for it.
class LockController extends Notifier<LockState> with WidgetsBindingObserver {
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();
  DateTime? _backgroundedAt;
  bool _prompting = false;

  @override
  LockState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    _load();
    return const LockState();
  }

  Future<void> _load() async {
    try {
      final en = await _storage.read(key: 'lock_enabled');
      final t = await _storage.read(key: 'lock_timeout');
      final enabled = en == '1';
      state = state.copyWith(
        loaded: true,
        enabled: enabled,
        timeoutMinutes: int.tryParse(t ?? '') ?? 1,
        locked: enabled,
      );
    } catch (_) {
      state = state.copyWith(loaded: true, locked: false);
    }
    if (state.enabled) unlock();
  }

  Future<void> set({bool? enabled, int? timeoutMinutes}) async {
    state = state.copyWith(
      enabled: enabled,
      timeoutMinutes: timeoutMinutes,
      locked: (enabled ?? state.enabled) ? state.locked : false,
    );
    await _storage.write(key: 'lock_enabled', value: state.enabled ? '1' : '0');
    await _storage.write(key: 'lock_timeout', value: '${state.timeoutMinutes}');
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (!state.enabled) return;
    switch (lifecycle) {
      case AppLifecycleState.inactive:
        state = state.copyWith(inactive: true);
      case AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        state = state.copyWith(inactive: false);
        final at = _backgroundedAt;
        _backgroundedAt = null;
        if (at != null &&
            DateTime.now().difference(at).inMinutes >= state.timeoutMinutes) {
          state = state.copyWith(locked: true);
        }
        if (state.locked) unlock();
      default:
        break;
    }
  }

  /// Prompts for biometrics/passcode to confirm a sensitive change (e.g.
  /// turning the lock off). Returns true on success. A device with no screen
  /// lock can't prompt at all, so it must not be trapped with the lock on.
  Future<bool> authenticate(String reason) async {
    if (_prompting) return false;
    _prompting = true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
      );
    } catch (_) {
      return !await deviceCanAuthenticate();
    } finally {
      _prompting = false;
    }
  }

  Future<void> unlock() async {
    if (_prompting || !state.locked) return;
    _prompting = true;
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock SpendWise',
        biometricOnly: false,
      );
      if (ok) state = state.copyWith(locked: false);
    } catch (_) {
      // A device with no screen lock at all must never trap the user.
      if (!await deviceCanAuthenticate()) state = state.copyWith(locked: false);
    } finally {
      _prompting = false;
    }
  }
}

final lockSettingsProvider = NotifierProvider<LockController, LockState>(
  LockController.new,
);

/// Covers the app while locked, and in the app switcher while inactive.
class LockGate extends ConsumerWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lockSettingsProvider);
    final showLock = s.enabled && s.locked;
    final cover = showLock || (s.enabled && s.inactive);
    return Stack(
      children: [
        child,
        if (cover)
          Positioned.fill(
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: showLock
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline, size: 48).pop(context),
                          const SizedBox(height: 12),
                          const Text('SpendWise is locked'),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: ref
                                .read(lockSettingsProvider.notifier)
                                .unlock,
                            child: const Text('Unlock'),
                          ),
                        ],
                      )
                    : const Icon(Icons.lock_outline, size: 48),
              ),
            ),
          ),
      ],
    );
  }
}
