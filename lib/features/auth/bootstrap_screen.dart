import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/async_value_view.dart';
import '../../core/ui/motion.dart';
import 'application/bootstrap_controller.dart';

/// First sign-in on a device: full pull in dependency order, with progress.
class BootstrapScreen extends ConsumerWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(bootstrapProvider);
    if (s.error != null) {
      return Scaffold(
        body: ErrorState(
          title: 'Could not finish setting up',
          message: s.error!,
          onRetry: ref.read(bootstrapProvider.notifier).run,
        ),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const LottieView(LottieAsset.loading, size: 120),
            const SizedBox(height: 8),
            SizedBox(
              width: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: s.progress == 0 ? null : s.progress, minHeight: 6),
              ),
            ),
            const SizedBox(height: 16),
            Text(s.label, style: theme.textTheme.bodyMedium),
          ]),
        ),
      ),
    );
  }
}
