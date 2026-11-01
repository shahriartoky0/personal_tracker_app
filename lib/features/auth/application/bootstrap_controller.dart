import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/session_controller.dart';
import '../../../core/error/app_error.dart';

class BootstrapState {
  const BootstrapState({this.progress = 0, this.label = 'Preparing…', this.error});
  final double progress;
  final String label;
  final String? error;
}

/// First sign-in on a device: full pull in dependency order, with progress.
class BootstrapController extends AutoDisposeNotifier<BootstrapState> {
  @override
  BootstrapState build() {
    Future.microtask(run);
    return const BootstrapState();
  }

  Future<void> run() async {
    state = const BootstrapState();
    final engine = ref.read(syncEngineProvider);
    final sub = engine.bootstrapProgress.stream.listen((p) {
      state = BootstrapState(progress: p.index / p.total, label: 'Loading ${p.entity.replaceAll('_', ' ')}…');
    });
    try {
      if (!await engine.remote.isReachable()) {
        state = const BootstrapState(error: 'The first sync needs an internet connection. Connect and try again.');
        return;
      }
      await engine.bootstrap();
      await ref.read(sessionProvider.notifier).bootstrapDone();
    } catch (e, st) {
      state = BootstrapState(error: toFailure(e, st).message);
    } finally {
      await sub.cancel();
    }
  }
}

final bootstrapProvider = NotifierProvider.autoDispose<BootstrapController, BootstrapState>(BootstrapController.new);
