import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/sync/sync_status.dart';
import '../core/ui/app_snackbar.dart';
import 'providers.dart';

/// What pull-to-refresh does on every screen: sync now, then tell the user
/// when the device is offline (changes stay saved locally either way).
Future<void> refreshAndNotify(WidgetRef ref, BuildContext context) async {
  final engine = ref.read(syncEngineProvider);
  await engine.syncNow();
  if (!context.mounted) return;
  if (engine.currentStatus is SyncOffline) {
    AppSnack.info(context, "You're offline — changes are saved on this device");
  } else {
    HapticFeedback.lightImpact();
  }
}
