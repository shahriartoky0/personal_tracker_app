import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/platform/notification_service.dart';

final reminderPrefsProvider = StreamProvider<List<ReminderPref>>(
  (ref) => ref.watch(ledgerProvider).watchReminderPrefs(),
);

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  ReminderPref _pref(List<ReminderPref> l, String type) =>
      l.where((p) => p.type == type).firstOrNull ??
      ReminderPref(
        type: type,
        enabled: false,
        time: type == 'plan_day' ? '08:00' : '21:00',
        thresholdPercent: 90,
      );

  Future<void> _save(WidgetRef ref, ReminderPref p) async {
    if (p.enabled) await NotificationService.instance.requestPermission();
    await ref.read(ledgerProvider).saveReminderPref(p);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(reminderPrefsProvider).valueOrNull ?? const <ReminderPref>[];
    final plan = _pref(prefs, 'plan_day');
    final close = _pref(prefs, 'close_day');
    final thr = _pref(prefs, 'budget_threshold');

    Widget timed(String title, String sub, ReminderPref p) {
      return Column(
        children: [
          SwitchListTile(
            title: Text(title),
            subtitle: Text(sub),
            value: p.enabled,
            onChanged: (v) => _save(
              ref,
              ReminderPref(
                type: p.type,
                enabled: v,
                time: p.time,
                thresholdPercent: p.thresholdPercent,
              ),
            ),
          ),
          if (p.enabled)
            ListTile(
              contentPadding: const EdgeInsets.only(left: 72, right: 16),
              title: const Text('Time'),
              trailing: Text(p.time),
              onTap: () async {
                final parts = p.time.split(':');
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.parse(parts[0]),
                    minute: int.parse(parts[1]),
                  ),
                );
                if (t != null) {
                  final hh = t.hour.toString().padLeft(2, '0');
                  final mm = t.minute.toString().padLeft(2, '0');
                  await _save(
                    ref,
                    ReminderPref(type: p.type, enabled: true, time: '$hh:$mm'),
                  );
                }
              },
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders & alerts'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        children: [
          timed('Plan the day', 'Daily reminder to set your limit', plan),
          timed('Close the day', 'Daily reminder to review and close', close),
          SwitchListTile(
            title: const Text('Budget alerts'),
            subtitle: const Text('Notify when spending nears today\'s limit'),
            value: thr.enabled,
            onChanged: (v) => _save(
              ref,
              ReminderPref(
                type: 'budget_threshold',
                enabled: v,
                thresholdPercent: thr.thresholdPercent ?? 90,
              ),
            ),
          ),
          if (thr.enabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 75, label: Text('75%')),
                  ButtonSegment(value: 90, label: Text('90%')),
                  ButtonSegment(value: 100, label: Text('100%')),
                ],
                selected: {thr.thresholdPercent ?? 90},
                onSelectionChanged: (s) => _save(
                  ref,
                  ReminderPref(
                    type: 'budget_threshold',
                    enabled: true,
                    thresholdPercent: s.first,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
