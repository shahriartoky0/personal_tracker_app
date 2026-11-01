import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/domain/entities.dart';
import '../../core/domain/local_date.dart';
import '../../core/domain/money.dart';
import '../../core/domain/reports.dart';
import '../../core/error/app_error.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/async_value_view.dart';
import '../../core/ui/motion.dart';
import '../common/charts.dart';
import '../common/charts_plan.dart';
import '../common/widgets.dart';
import 'application/report_controller.dart';

const _labels = {
  RangePreset.today: 'Today',
  RangePreset.yesterday: 'Yesterday',
  RangePreset.thisWeek: 'This week',
  RangePreset.lastWeek: 'Last week',
  RangePreset.thisMonth: 'This month',
  RangePreset.lastMonth: 'Last month',
  RangePreset.last7: 'Last 7 days',
  RangePreset.last30: 'Last 30 days',
  RangePreset.thisYear: 'This year',
};

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(reportProvider);
    return Column(children: [
      const _RangeBar(),
      Expanded(
        child: AsyncValueView<ReportView>(
          value: view,
          onRetry: () => ref.invalidate(transactionsProvider),
          data: (v) => _ReportBody(view: v),
        ),
      ),
    ]);
  }
}

class _RangeBar extends ConsumerWidget {
  const _RangeBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(reportRangeProvider);
    final n = ref.read(reportRangeProvider.notifier);
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Tokens.s16, vertical: 6),
        children: [
          for (final e in _labels.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(e.value),
                selected: sel.custom == null && sel.preset == e.key,
                onSelected: (_) => n.setPreset(e.key),
              ),
            ),
          ActionChip(
            avatar: const Icon(Icons.date_range, size: 18),
            label: Text(sel.custom == null ? 'Custom' : '${sel.custom!.from} → ${sel.custom!.to}'),
            onPressed: () async {
              final r = await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (r != null) {
                n.setCustom(DateRange(
                  LocalDate(r.start.year, r.start.month, r.start.day),
                  LocalDate(r.end.year, r.end.month, r.end.day),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends ConsumerWidget {
  const _ReportBody({required this.view});
  final ReportView view;

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      final tz = ref.read(timezoneProvider);
      final txs = ref.read(transactionsProvider).valueOrNull ?? const <Tx>[];
      final range = view.range;
      final ir = instantRange(range.from, range.to, tz);
      final csv = TransactionCsv.build(
        txs: txs.where((t) => ir.contains(t.occurredAtMs)).toList(),
        tz: tz,
        categoryNames: view.categoryNames,
        accountNames: view.accountNames,
        payeeNames: {for (final p in ref.read(payeesProvider).valueOrNull ?? const <Payee>[]) p.id: p.name},
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/taka-${range.from}_${range.to}.csv');
      await file.writeAsString('${TransactionCsv.bom}$csv');
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Taka Tracker export'));
    } catch (e, st) {
      if (context.mounted) AppSnack.error(context, toFailure(e, st).message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = view.report;
    final theme = Theme.of(context);
    final catName = view.categoryNames;
    final accName = view.accountNames;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, 96),
      children: [
        Text('${view.range.from} → ${view.range.to}',
            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: Tokens.s8),
        if (report.txCount == 0)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: EmptyState(
              'Pick another range or add a transaction to see your report.',
              title: 'No activity in this period',
              icon: Icons.bar_chart_outlined,
            ),
          )
        else ...[
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _StatCard('Opening', report.openingBalance).pop(context, index: 0),
              _StatCard('Closing', report.closingBalance).pop(context, index: 1),
              _StatCard('Income', report.income).pop(context, index: 2),
              _StatCard('Expenses', report.expenses).pop(context, index: 3),
              _StatCard('Net', report.net, sign: true).pop(context, index: 4),
              _StatCard('Unplanned', report.unplanned).pop(context, index: 5),
            ],
          ),
          if (report.sentToPeople > 0 || report.receivedFromPeople > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sent to people ${formatMoney(report.sentToPeople)} · received ${formatMoney(report.receivedFromPeople)} — not counted as spending or income.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ]),
            ),
          const SizedBox(height: 12),
          RepaintBoundary(
            child: _rankedCard('Spending by category',
                [for (final c in report.categoryShares) RankedItem(catName[c.categoryId] ?? 'Uncategorised', c.amount)],
                empty: 'No expenses in this period.'),
          ),
          const SizedBox(height: 12),
          RepaintBoundary(child: _TrendCard(report: report)),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Planned vs actual',
            child: report.plannedVsActual.isEmpty
                ? Text('No plans in this period.', style: theme.textTheme.bodyMedium)
                : PlanVsActualBars(rows: [
                    for (final r in report.plannedVsActual) PlanActualRow(catName[r.categoryId] ?? 'Category', r.planned, r.actual)
                  ]),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Compared with previous period',
            child: Column(children: [
              _CompareRow('Expenses', report.expenses, report.comparison.previousExpenses,
                  report.comparison.expenseChangePercent, upIsGood: false),
              _CompareRow('Income', report.income, report.comparison.previousIncome,
                  report.comparison.incomeChangePercent, upIsGood: true),
            ]),
          ),
          const SizedBox(height: 12),
          _rankedCard('Payment methods',
              [for (final s in report.accountShares) RankedItem(accName[s.categoryId] ?? 'Account', s.amount)],
              empty: 'No expenses in this period.'),
          const SizedBox(height: 12),
          _rankedCard('Top merchants', [for (final m in report.topMerchants) RankedItem('${m.merchant} (${m.count})', m.amount)],
              empty: 'Add a merchant to expenses to see them here.', percent: false),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.ios_share),
          label: const Text('Export CSV'),
          onPressed: report.txCount == 0 ? null : () => _export(context, ref),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.minor, {this.sign = false});
  final String label;
  final int minor;
  final bool sign;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatMoney(minor, showSign: sign),
                style: moneyStyle(context, size: 19, tabular: false, display: true, weight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

/// Ranked bars (up to 6 plus a muted "Other") with a table twin.
Widget _rankedCard(String title, List<RankedItem> raw, {required String empty, bool percent = true}) {
  final items = foldTail(raw);
  return ChartCard(
    id: 'report-$title',
    title: title,
    empty: items.isEmpty,
    emptyMessage: empty,
    summary: items.isEmpty ? '' : 'Top: ${items.first.label}, ${formatMoney(items.first.amount)}.',
    chart: RankedBars(items: items, showPercent: percent),
    table: DataTableView(
      headers: const ['Name', 'Amount'],
      rows: [for (final i in items) TableRowData([i.label, formatMoney(i.amount)])],
    ),
  );
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.report});
  final PeriodReport report;
  @override
  Widget build(BuildContext context) {
    final viz = VizColors.of(context);
    final points = [for (final t in report.trend) TrendPoint('${t.start.day}/${t.start.month}', t.income, t.expense)];
    final hasData = points.any((p) => p.income > 0 || p.expense > 0);
    return ChartCard(
      id: 'report-trend',
      title: report.trendIsDaily ? 'Daily trend' : 'Weekly trend',
      empty: !hasData,
      emptyMessage: 'No income or expenses to plot.',
      summary: 'Expenses ${formatMoney(report.expenses)} · income ${formatMoney(report.income)}.',
      legend: ChartLegend([LegendItem('Expenses', viz.categorical[0]), LegendItem('Income', viz.categorical[1])]),
      chart: Semantics(
        label:
            'Trend chart of income and expenses over ${points.length} ${report.trendIsDaily ? 'days' : 'weeks'}. Use the table view for exact values.',
        child: ExcludeSemantics(child: TrendChart(points: points)),
      ),
      table: DataTableView(
        headers: const ['Date', 'Expenses', 'Income'],
        rows: [for (final p in points) TableRowData([p.label, formatMoney(p.expense), formatMoney(p.income)])],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow(this.label, this.now, this.prev, this.pct, {required this.upIsGood});
  final String label;
  final int now;
  final int prev;
  final int? pct;
  final bool upIsGood;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(label)),
          Text('${formatMoney(now)} vs ${formatMoney(prev)}  ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFeatures: moneyFeatures)),
          DeltaText(percent: pct, upIsGood: upIsGood),
        ]),
      );
}
