import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'app/app.dart';
import 'app/providers.dart';
import 'core/data/db/database.dart';
import 'core/data/db/key_store.dart';
import 'core/data/remote/remote_gateway.dart';
import 'core/data/remote/secure_local_storage.dart';
import 'core/logging/app_log.dart';
import 'core/platform/notification_service.dart';
import 'core/ui/async_value_view.dart';

Future<void> main() async {
  // Anything that escapes a screen is logged, never shown as a red error page.
  runZonedGuarded(_boot, (e, st) => AppLog.line('zone', 'Unhandled: $e\n$st'));
}

Future<void> _boot() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (d) {
    AppLog.line('flutter', '${d.exceptionAsString()}\n${d.stack}');
    if (kDebugMode) FlutterError.dumpErrorToConsole(d);
  };
  PlatformDispatcher.instance.onError = (e, st) {
    AppLog.line('platform', 'Unhandled: $e\n$st');
    return true;
  };
  ErrorWidget.builder = (_) => const AppErrorWidget();
  tzdata.initializeTimeZones();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Missing .env: the app shows a configuration screen.
  }
  // Only the URL and the publishable (anon) key — read from .env.
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
      // Debug builds print every request/response to the console.
      httpClient: kDebugMode ? LoggingHttpClient() : null,
    );
  }
  try {
    await NotificationService.instance.init();
  } catch (_) {}
  final key = await DbKeyStore().getOrCreate();
  final db = AppDatabase.open(key);
  final cachedUser = await db.kvGet('user_id');
  String? deviceZone;
  try {
    deviceZone = (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (_) {}

  runApp(ProviderScope(
    overrides: [
      dbProvider.overrideWithValue(db),
      cachedUserIdProvider.overrideWith((ref) => cachedUser),
    ],
    child: TakaTrackerApp(missingConfig: supabaseUrl.isEmpty || supabaseAnonKey.isEmpty, deviceZone: deviceZone),
  ));
}
