import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/domain/calculators.dart';
import '../../core/domain/entities.dart';
import '../../core/domain/local_date.dart';
import '../../core/domain/money.dart';
import '../../core/ui/skeleton.dart';
import '../common/charts.dart';
import '../common/widgets.dart';
import '../common/entry/add_sheet.dart';
import '../../core/ui/motion.dart';
import '../../core/error/app_error.dart';
import '../../core/ui/async_value_view.dart';
import '../../app/shell_controller.dart';
import '../../app/refresh_actions.dart';
import '../../core/ui/pull_refresh.dart';

/// Staggered entrance for the dashboard cards (spacers are left alone).
List<Widget> _stagger(BuildContext context, List<Widget> items) {
  var i = 0;
  return [
    for (final w in items) w is SizedBox ? w : w.enter(context, index: i++),
  ];
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tz = ref.watch(timezoneProvider);
    final txAsync = ref.watch(dashboardTxProvider);
    // First read of the local DB: show a layout-shaped placeholder, not a spinner.
    if (!txAsync.hasValue) {
      return txAsync.hasError
          ? ErrorState(
              message: friendlyMessage(txAsync.error!),
              onRetry: () => ref.invalidate(dashboardTxProvider),
            )
          : const SkeletonDashboard();
    }
    final txs = txAsync.valueOrNull ?? const <Tx>[];
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final cats =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final budgets =
        ref.watch(budgetsProvider).valueOrNull ?? const <DailyBudget>[];
    final payees = ref.watch(payeesProvider).valueOrNull ?? const <Payee>[];

    final today = todayIn(tz);
    final todayTxs = TransactionCalculator.onLocalDate(txs, today, tz).toList();
    final budget = budgets.where((b) => b.date == today.value).firstOrNull;
    final summary = BudgetCalculator.summarizeDay(
      budget: budget,
      dayTxs: todayTxs,
    );

    final mr = instantRange(today.startOfMonth, today.endOfMonth, tz);
    final monthTxs = txs.where((t) => mr.contains(t.occurredAtMs)).toList();
    final balance = ref.watch(totalBalanceProvider);
    final catMap = {for (final c in cats) c.id: c};
    final accMap = {for (final a in accounts) a.id: a};
    final payeeNames = {for (final p in payees) p.id: p.name};

    // Onboarding: guide the first-time user instead of showing empty zeros.
    final needsAccount = accounts.isEmpty;
    final needsCategory = cats.where((c) => c.type == 'expense').isEmpty;
    final firstRun = needsAccount || needsCategory;

    final byCat = <String, int>{};
    for (final t in todayTxs.where(TransactionCalculator.isExpense)) {
      final k = catMap[t.categoryId]?.name ?? 'Other';
      byCat[k] = (byCat[k] ?? 0) + t.amount;
    }
    final catItems = foldTail(
      (byCat.entries.map((e) => RankedItem(e.key, e.value)).toList()
        ..sort((a, b) => b.amount.compareTo(a.amount))),
    );

    final days = [for (var i = 6; i >= 0; i--) today.addDays(-i)];
    const wd = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayLabels = [for (final d in days) '${wd[d.weekday - 1]}${d.day}'];
    final perDay = [
      for (final d in days)
        TransactionCalculator.totalExpenses(
          TransactionCalculator.onLocalDate(txs, d, tz),
        ),
    ];
    final weekTotal = perDay.fold<int>(0, (s, v) => s + v);
    final bars = DailyBars(labels: dayLabels, values: perDay, focusIndex: 6);

    final recent = ref.watch(recentTxProvider).valueOrNull ?? const <Tx>[];

    return RefreshableList(
      onRefresh: () => refreshAndNotify(ref, context),
      padding: const EdgeInsets.fromLTRB(
        Tokens.s16,
        Tokens.s8,
        Tokens.s16,
        Tokens.s24,
      ),
      children: _stagger(context, [
        if (firstRun)
          _Onboarding(needsAccount: needsAccount, needsCategory: needsCategory),
        if (firstRun) const SizedBox(height: Tokens.s12),
        _LeftForToday(
          summary: summary,
          hasPlan: budget != null,
          onPlan: () => ref.read(shellTabProvider.notifier).goTo(1),
        ),
        const SizedBox(height: Tokens.s12),
        Row(
          children: [
            Expanded(
              child: _Stat(
                'Balance',
                balance,
                Icons.account_balance_wallet_outlined,
              ),
            ),
            const SizedBox(width: Tokens.s12),
            Expanded(
              child: _Stat('Spent today', summary.spent, Icons.north_east),
            ),
          ],
        ),
        const SizedBox(height: Tokens.s12),
        SectionCard(
          title: 'This month',
          child: Column(
            children: [
              _row(
                context,
                'Income',
                TransactionCalculator.totalIncome(monthTxs),
              ),
              _row(
                context,
                'Expenses',
                TransactionCalculator.totalExpenses(monthTxs),
              ),
              const Divider(height: 20),
              _row(
                context,
                'Net',
                TransactionCalculator.netCashFlow(monthTxs),
                bold: true,
                sign: true,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => context.push('/people'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sent to people (not in spending)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatMoney(
                              TransactionCalculator.totalSentToPeople(monthTxs),
                            ),
                            style: moneyStyle(context, weight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Tokens.s12),
        SectionCard(
          title: 'Today by category',
          child: catItems.isEmpty
              ? Text(
                  'No spending yet today.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : RankedBars(items: catItems, showPercent: false),
        ),
        const SizedBox(height: Tokens.s12),
        ChartCard(
          id: 'dashboard-week',
          title: 'Last 7 days',
          summary: weekTotal == 0
              ? 'No spending in the last 7 days.'
              : 'Spent ${formatMoney(weekTotal)} in 7 days, average ${formatMoney(weekTotal ~/ 7)} a day.',
          empty: weekTotal == 0,
          emptyMessage: 'No spending in the last 7 days.',
          chart: Semantics(
            label:
                'Daily spending, last 7 days. ${[for (var i = 0; i < 7; i++) '${dayLabels[i]} ${formatMoney(perDay[i])}'].join(', ')}',
            child: ExcludeSemantics(child: bars),
          ),
          table: DataTableView(
            headers: const ['Day', 'Spent'],
            rows: bars.rows,
          ),
        ),
        const SizedBox(height: Tokens.s12),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (recent.length >= 5)
                      TextButton(
                        onPressed: () =>
                            ref.read(shellTabProvider.notifier).goTo(2),
                        child: const Text('See all'),
                      ),
                  ],
                ),
              ),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Text(
                    firstRun
                        ? 'Finish the setup above, then tap Add to record your first expense.'
                        : 'No transactions yet. Tap Add to record one.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final t in recent)
                  TxTile(
                    tx: t,
                    categories: catMap,
                    accounts: accMap,
                    payeeNames: payeeNames,
                    tz: tz,
                    onTap: () =>
                        (t.type == TxType.income || t.type == TxType.expense)
                        ? showAddSheet(context, editing: t)
                        : ref.read(shellTabProvider.notifier).goTo(2),
                  ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    int minor, {
    bool bold = false,
    bool sign = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatMoney(minor, showSign: sign),
              style: moneyStyle(
                context,
                weight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.minor, this.icon);
  final String label;
  final int minor;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AnimatedMoney(
                minor,
                style: moneyStyle(
                  context,
                  size: 22,
                  weight: FontWeight.w700,
                  tabular: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dominant "Left for today" hero. Status = icon + label + colour.
class _LeftForToday extends StatelessWidget {
  const _LeftForToday({
    required this.summary,
    required this.hasPlan,
    required this.onPlan,
  });
  final DaySummary summary;
  final bool hasPlan;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final heroStyle = TextStyle(
      fontFamily: displayFont,
      fontSize: 46,
      height: 1.1,
      fontWeight: FontWeight.w700,
      color: summary.status == BudgetStatus.over
          ? scheme.error
          : scheme.onSurface,
    );
    final (String label, IconData icon, Color color) = switch (summary.status) {
      BudgetStatus.none => (
        'No plan for today',
        Icons.info_outline,
        scheme.outline,
      ),
      BudgetStatus.ok => (
        'On track',
        Icons.check_circle_outline,
        Tokens.statusGood,
      ),
      BudgetStatus.approaching => (
        'Approaching your limit',
        Icons.warning_amber_rounded,
        Tokens.warning,
      ),
      BudgetStatus.over => ('Over budget', Icons.error_outline, scheme.error),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Left for today',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Semantics(
              label: hasPlan
                  ? '${formatMoney(summary.remaining)} left for today. $label.'
                  : 'No plan set for today.',
              child: ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: hasPlan
                      ? AnimatedMoney(
                          summary.remaining,
                          duration: const Duration(milliseconds: 600),
                          style: heroStyle,
                        )
                      : Text('—', style: heroStyle),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (hasPlan) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    end: (summary.progressPercent / 100).clamp(0, 1).toDouble(),
                  ),
                  duration: growDuration(context),
                  curve: Motion.curve,
                  builder: (_, v, _) => TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: color),
                    duration: Motion.reduced(context)
                        ? Duration.zero
                        : Motion.normal,
                    builder: (_, c, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      color: c ?? color,
                      backgroundColor: VizColors.of(context).grid,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(label, style: theme.textTheme.bodyMedium),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${formatMoney(summary.spent)} of ${formatMoney(summary.limit)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (summary.unplanned > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Unplanned so far: ${formatMoney(summary.unplanned)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ] else ...[
              Text(
                'Set a daily limit to see how much you can still spend.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onPlan,
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('Plan today'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Checklist shown until there is at least one account and one expense category.
class _Onboarding extends StatelessWidget {
  const _Onboarding({required this.needsAccount, required this.needsCategory});
  final bool needsAccount;
  final bool needsCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget step(bool done, String title, String sub, String route) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? Tokens.statusGood : theme.colorScheme.outline,
      ),
      title: Text(
        title,
        style: TextStyle(decoration: done ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text(sub),
      trailing: done ? null : const Icon(Icons.chevron_right),
      onTap: done ? null : () => context.push(route),
    );
    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Let's get you set up", style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Two quick steps, then you can start tracking — it all works offline.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            step(
              !needsAccount,
              'Add an account',
              'Cash, bank, card or mobile wallet',
              '/accounts',
            ),
            step(
              !needsCategory,
              'Add expense categories',
              'Food, transport, bills…',
              '/categories',
            ),
          ],
        ),
      ),
    );
  }
}
