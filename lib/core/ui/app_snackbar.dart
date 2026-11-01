import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The one way to show a transient message. Success/error pair a colour with
/// an icon so meaning never rests on colour alone.
class AppSnack {
  AppSnack._();

  static void success(BuildContext context, String message) =>
      _show(context, message, Icons.check_circle_outline, Tokens.statusGood);

  static void error(BuildContext context, String message) =>
      _show(context, message, Icons.error_outline, Tokens.statusCritical);

  static void info(BuildContext context, String message) => _show(context, message, null, null);

  static void _show(BuildContext context, String message, IconData? icon, Color? accent) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Row(children: [
            if (icon != null) ...[Icon(icon, size: 20, color: accent), const SizedBox(width: 10)],
            Expanded(child: Text(message)),
          ]),
        ),
      );
  }
}
