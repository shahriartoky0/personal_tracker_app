import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/local_date.dart';

class ReminderPref {
  const ReminderPref({required this.type, required this.enabled, this.time = '20:00', this.thresholdPercent});
  final String type; // plan_day | close_day | budget_threshold
  final bool enabled;
  final String time; // HH:mm
  final int? thresholdPercent;
}

/// Local, offline reminders and budget alerts (§15).
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _idPlan = 1001;
  static const _idClose = 1002;
  static const _idAlertBase = 2000;

  Future<void> init() async {
    if (_ready) return;
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: init);
    _ready = true;
  }

  /// Requested lazily, when the user turns a reminder on.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final a = await android?.requestNotificationsPermission();
    final i = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return (a ?? i ?? true);
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'taka_reminders',
          'Reminders & alerts',
          channelDescription: 'Daily plan reminders and budget alerts',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      );

  tz.TZDateTime _nextAt(String hhmm, String zone) {
    final loc = locationOf(zone);
    final now = tz.TZDateTime.now(loc);
    final parts = hhmm.split(':');
    var at = tz.TZDateTime(loc, now.year, now.month, now.day, int.tryParse(parts[0]) ?? 20,
        int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  /// Cancel + reschedule the daily reminders. Call on start and whenever
  /// preferences or the profile timezone change.
  Future<void> reschedule(List<ReminderPref> prefs, String zone) async {
    await init();
    await _plugin.cancel(id: _idPlan);
    await _plugin.cancel(id: _idClose);
    for (final p in prefs.where((p) => p.enabled)) {
      final (id, title, body) = switch (p.type) {
        'plan_day' => (_idPlan, 'Plan your day', 'Set today\'s limit before you spend.'),
        'close_day' => (_idClose, 'Close your day', 'Review today\'s spending and close the day.'),
        _ => (0, '', ''),
      };
      if (id == 0) continue;
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextAt(p.time, zone),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// One-shot budget alert (e.g. 75/90/100%).
  Future<void> showBudgetAlert(int level, String body) async {
    await init();
    await _plugin.show(id: _idAlertBase + level, title: 'Budget alert', body: body, notificationDetails: _details);
  }
}
