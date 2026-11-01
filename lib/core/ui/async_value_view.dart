import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/app_error.dart';
import 'motion.dart';

/// Every stream/future-backed screen goes through this: loading shows the
/// supplied skeleton, errors show a friendly message with Retry (which
/// invalidates the provider), data builds the screen. Errors are never
/// swallowed into an empty list.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    required this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    // Keep showing the last good data during a refresh or a transient error.
    if (value.hasValue) return data(value.requireValue);
    return value.when(
      loading: () => loading ?? const Center(child: LottieView(LottieAsset.loading, size: 96)),
      error: (e, _) => ErrorState(message: friendlyMessage(e), onRetry: onRetry),
      data: data,
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry, this.title = 'Something went wrong'});
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const LottieView(LottieAsset.offline, size: 96, fallback: Icons.error_outline),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ],
        ]),
      ),
    );
  }
}

/// Last-resort widget shown instead of Flutter's red error screen.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key});
  @override
  Widget build(BuildContext context) => const Material(
        child: ErrorState(message: 'This part of the screen could not be displayed.'),
      );
}
