import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/data/sync/sync_status.dart';
import '../core/platform/notification_service.dart';
import '../core/ui/app_snackbar.dart';
import '../core/ui/docked_nav_bar.dart';
import '../core/ui/motion.dart';
import '../core/ui/responsive.dart';
import '../features/budgets/plan_screen.dart';
import '../features/common/entry/add_sheet.dart';
import '../features/reports/reports_screen.dart';
import '../features/settings/reminders_screen.dart';
import '../features/transactions/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';
import 'providers.dart';
import 'shell_controller.dart';

const _titles = ['Today', 'Plan', 'History', 'Reports'];

const _destinations = [
  NavDestinationData('Today', Icons.today_outlined, Icons.today_rounded),
  NavDestinationData(
    'Plan',
    Icons.event_note_outlined,
    Icons.event_note_rounded,
  ),
  NavDestinationData(
    'History',
    Icons.receipt_long_outlined,
    Icons.receipt_long_rounded,
  ),
  NavDestinationData(
    'Reports',
    Icons.insights_outlined,
    Icons.insights_rounded,
  ),
];

/// The four screens behind the bar. PageView.builder creates each page the
/// first time it scrolls into view; [_KeepAlive] then holds it so scroll
/// position and filters survive tab switches.
const _pages = <Widget>[
  DashboardScreen(),
  PlanScreen(),
  TransactionsScreen(),
  ReportsScreen(),
];

/// Subtle parallax while swiping or animating between tabs: the page drifts
/// a little, fades to 70% and shrinks to 97% as it leaves the centre.
class _PageParallax extends StatelessWidget {
  const _PageParallax({
    required this.controller,
    required this.index,
    required this.child,
  });
  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final page = controller.hasClients && controller.position.haveDimensions
            ? (controller.page ?? index.toDouble())
            : index.toDouble();
        final delta = (index - page).clamp(-1.0, 1.0);
        final d = delta.abs();
        if (d == 0) return child!;
        return Opacity(
          opacity: 1 - 0.3 * d,
          child: Transform.translate(
            offset: Offset(delta * 24, 0),
            child: Transform.scale(scale: 1 - 0.03 * d, child: child),
          ),
        );
      },
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(shellTabProvider);
    final controller = ref.read(shellTabProvider.notifier);
    final needsAttention = ref.watch(
      syncStatusProvider.select((s) => s.valueOrNull is SyncAttention),
    );

    ref.listen(reminderPrefsProvider, (_, n) {
      final prefs = n.valueOrNull;
      if (prefs != null) {
        NotificationService.instance.reschedule(
          prefs,
          ref.read(timezoneProvider),
        );
      }
    });
    ref.listen(timezoneProvider, (_, zone) {
      final prefs = ref.read(reminderPrefsProvider).valueOrNull;
      if (prefs != null) NotificationService.instance.reschedule(prefs, zone);
    });

    final pageView = PageView.builder(
      controller: controller.pages,
      onPageChanged: controller.onPageChanged,
      itemCount: _pages.length,
      itemBuilder: (_, i) => _KeepAlive(
        child: _PageParallax(
          controller: controller.pages,
          index: i,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.contentMaxWidth,
              ),
              child: _pages[i],
            ),
          ),
        ),
      ),
    );

    final appBar = AppBar(
      title: AnimatedSwitcher(
        duration: Motion.reduced(context) ? Duration.zero : Motion.fast,
        switchInCurve: Motion.curve,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        child: Text(_titles[tab], key: ValueKey(tab)),
      ),
      actions: [
        const SyncChip(),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
        const SizedBox(width: 4),
      ],
    );

    void add() => showAddSheet(context);

    // Hide the docked "+" and bar while typing: they would float over the keyboard.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    // Back on another tab returns to Today; only Today can start an exit.
    bool canStartExit() {
      if (tab == 0) return true;
      controller.goTo(0);
      return false;
    }

    return _DoubleBackToExit(
      canStartExit: canStartExit,
      child: ResponsiveBuilder(
        phone: (_) => Scaffold(
          appBar: appBar,
          body: pageView,
          floatingActionButton: keyboardOpen
              ? null
              : DockedAddButton(onPressed: add),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: keyboardOpen
              ? null
              : DockedNavBar(
                  destinations: _destinations,
                  selectedIndex: tab,
                  onSelected: controller.goTo,
                  badgeIndex: needsAttention ? 2 : null,
                ),
        ),
        tablet: (_) => Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: tab,
                onDestinationSelected: controller.goTo,
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FloatingActionButton(
                    tooltip: 'Add',
                    onPressed: add,
                    child: const Icon(Icons.add_rounded),
                  ),
                ),
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pageView),
            ],
          ),
        ),
      ),
    );
  }
}

/// Swallows the system back gesture: the first press shows a hint, a second
/// press within [_window] closes the app.
class _DoubleBackToExit extends StatefulWidget {
  const _DoubleBackToExit({required this.child, required this.canStartExit});
  final Widget child;

  /// Return false to consume the back press (e.g. after switching tabs).
  final bool Function() canStartExit;

  @override
  State<_DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<_DoubleBackToExit> {
  static const _window = Duration(seconds: 2);
  DateTime? _lastBack;

  void _onBack(bool didPop, Object? result) {
    if (didPop || !widget.canStartExit()) return;
    final now = DateTime.now();
    final last = _lastBack;
    if (last != null && now.difference(last) < _window) {
      SystemNavigator.pop();
      return;
    }
    _lastBack = now;
    AppSnack.info(context, 'Press back again to exit');
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: _onBack,
    child: widget.child,
  );
}

/// Keeps a PageView page alive once built.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;
  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Small status chip: offline / syncing / "3 pending" / needs attention.
class SyncChip extends ConsumerWidget {
  const SyncChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(syncStatusProvider).valueOrNull ?? const SyncOffline();
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, String label, Color color) = switch (status) {
      SyncOffline(:final pending) => (
        Icons.cloud_off,
        pending > 0 ? 'Offline · $pending' : 'Offline',
        scheme.outline,
      ),
      SyncIdle() => (Icons.cloud_done_outlined, 'Synced', scheme.primary),
      SyncSyncing(:final done, :final total) => (
        Icons.sync,
        total > 0 ? 'Syncing $done/$total' : 'Syncing',
        scheme.primary,
      ),
      SyncPending(:final count) => (
        Icons.cloud_upload_outlined,
        '$count pending',
        scheme.tertiary,
      ),
      SyncAttention(:final failed) => (
        Icons.error_outline,
        '$failed need attention',
        scheme.error,
      ),
      SyncAuthRequired() => (Icons.lock_outline, 'Sign in again', scheme.error),
      SyncUpdateRequired() => (
        Icons.system_update,
        'Update required',
        scheme.error,
      ),
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
