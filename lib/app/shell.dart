import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/data/sync/sync_status.dart';
import '../features/budgets/plan_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/transactions/add_sheet.dart';
import '../features/transactions/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../core/platform/notification_service.dart';
import '../features/settings/reminders_screen.dart';
import '../core/ui/responsive.dart';
import 'providers.dart';
import '../core/ui/motion.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _titles = ['Today', 'Plan', 'Transactions', 'Reports', 'Settings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(shellTabProvider.select((s) => s.index));
    final visited = ref.watch(shellTabProvider.select((s) => s.visited));
    ref.listen(reminderPrefsProvider, (_, n) {
      final prefs = n.valueOrNull;
      if (prefs != null) NotificationService.instance.reschedule(prefs, ref.read(timezoneProvider));
    });
    ref.listen(timezoneProvider, (_, zone) {
      final prefs = ref.read(reminderPrefsProvider).valueOrNull;
      if (prefs != null) NotificationService.instance.reschedule(prefs, zone);
    });
    // Built on first visit only (lazy), then kept alive by the IndexedStack.
    const builders = <Widget>[
      DashboardScreen(),
      PlanScreen(),
      TransactionsScreen(),
      ReportsScreen(),
      SettingsScreen(),
    ];
    final pages = [for (var i = 0; i < builders.length; i++) visited.contains(i) ? builders[i] : const SizedBox.shrink()];
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.contentMaxWidth),
        child: IndexedStack(index: tab, children: pages),
      ),
    );
    void select(int i) => ref.read(shellTabProvider.notifier).select(i);
    final fab = FloatingActionButton.extended(
      onPressed: () => showAddSheet(context),
      icon: const Icon(Icons.add),
      label: const Text('Add'),
    ).pop(context, index: 3);
    final appBar = AppBar(
      title: Text(_titles[tab]),
      actions: const [SyncChip(), SizedBox(width: 8)],
    );

    // Phone: bottom navigation. Tablet: a navigation rail beside the content.
    return ResponsiveBuilder(
      phone: (_) => Scaffold(
        appBar: appBar,
        body: content,
        floatingActionButton: fab,
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: select,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
          ],
        ),
      ),
      tablet: (_) => Scaffold(
        appBar: appBar,
        floatingActionButton: fab,
        body: Row(children: [
          NavigationRail(
            selectedIndex: tab,
            onDestinationSelected: select,
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: Text(d.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ]),
      ),
    );
  }
}

class _Dest {
  const _Dest(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _Dest('Today', Icons.today_outlined, Icons.today),
  _Dest('Plan', Icons.event_note_outlined, Icons.event_note),
  _Dest('Transactions', Icons.receipt_long_outlined, Icons.receipt_long),
  _Dest('Reports', Icons.bar_chart_outlined, Icons.bar_chart),
  _Dest('Settings', Icons.settings_outlined, Icons.settings),
];

/// Small status chip: offline / syncing / "3 pending" / needs attention.
class SyncChip extends ConsumerWidget {
  const SyncChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).valueOrNull ?? const SyncOffline();
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, String label, Color color) = switch (status) {
      SyncOffline(:final pending) => (Icons.cloud_off, pending > 0 ? 'Offline · $pending' : 'Offline', scheme.outline),
      SyncIdle() => (Icons.cloud_done_outlined, 'Synced', scheme.primary),
      SyncSyncing(:final done, :final total) =>
        (Icons.sync, total > 0 ? 'Syncing $done/$total' : 'Syncing', scheme.primary),
      SyncPending(:final count) => (Icons.cloud_upload_outlined, '$count pending', scheme.tertiary),
      SyncAttention(:final failed) => (Icons.error_outline, '$failed need attention', scheme.error),
      SyncAuthRequired() => (Icons.lock_outline, 'Sign in again', scheme.error),
      SyncUpdateRequired() => (Icons.system_update, 'Update required', scheme.error),
    };
    return Semantics(
      label: 'Sync status: $label',
      button: true,
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: color),
        label: Text(label),
        onPressed: () => context.push('/diagnostics'),
      ),
    );
  }
}
