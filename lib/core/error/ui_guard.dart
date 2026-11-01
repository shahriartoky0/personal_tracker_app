import 'package:flutter/widgets.dart';

import '../ui/app_snackbar.dart';
import 'app_error.dart';

/// Runs a UI-triggered action; any exception becomes a friendly snackbar
/// instead of an unhandled error. Returns null when the action failed.
Future<T?> runGuarded<T>(BuildContext context, Future<T> Function() action, {String? success}) async {
  try {
    final r = await action();
    if (success != null && context.mounted) AppSnack.success(context, success);
    return r;
  } catch (e, st) {
    if (context.mounted) AppSnack.error(context, toFailure(e, st).message);
    return null;
  }
}
