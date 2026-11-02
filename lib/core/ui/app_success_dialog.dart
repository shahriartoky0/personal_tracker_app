import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'motion.dart';

/// Shows a centred "saved" dialog (Lottie check) that closes itself.
/// Not dismissible by the user; it never outlives [duration].
Future<void> showSuccessDialog(
  BuildContext context, {
  String title = 'Saved',
  String? subtitle = 'Synced when you are online',
  Duration duration = const Duration(milliseconds: 1100),
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => _SuccessDialog(title: title, subtitle: subtitle, duration: duration),
  );
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog({required this.title, required this.subtitle, required this.duration});
  final String title;
  final String? subtitle;
  final Duration duration;

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(widget.duration, () {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SuccessRing(
                  child: const LottieView(
                    LottieAsset.success,
                    size: 110,
                    fallback: Icons.check_circle,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.title, style: theme.textTheme.titleMedium),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft ring that expands and fades behind the success check.
class SuccessRing extends StatelessWidget {
  const SuccessRing({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.slow + Motion.fast,
      curve: Motion.curve,
      child: child,
      builder: (_, t, child) => Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: (1 - t).clamp(0.0, 1.0) * 0.5,
            child: Container(
              width: 70 + 90 * t,
              height: 70 + 90 * t,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Tokens.statusGood, width: 3 * (1 - t) + 0.5),
              ),
            ),
          ),
          child!,
        ],
      ),
    );
  }
}
