import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/domain/money.dart';

/// Whether a chart card currently shows its table twin (per card id).
final chartTableModeProvider = StateProvider.autoDispose.family<bool, String>((ref, id) => false);

/// Card with a title, a one-line text summary (also the screen-reader
/// description) and a chart ⇄ table switch. Every chart has a table twin.
class ChartCard extends ConsumerWidget {
  const ChartCard({
    super.key,
    required this.id,
    required this.title,
    required this.summary,
    required this.chart,
    required this.table,
    this.legend,
    this.empty = false,
    this.emptyMessage = 'Nothing to show for this period.',
  });
  final String id;
  final String title;
  final String summary;
  final Widget chart;
  final Widget table;
  final Widget? legend;
  final bool empty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showTable = ref.watch(chartTableModeProvider(id));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
            if (!empty)
              IconButton(
                tooltip: showTable ? 'Show chart' : 'Show as table',
                visualDensity: VisualDensity.compact,
                icon: Icon(showTable ? Icons.bar_chart_rounded : Icons.table_rows_outlined, size: 20),
                onPressed: () => ref.read(chartTableModeProvider(id).notifier).state = !showTable,
              ),
          ]),
          if (!empty) ...[
            Text(summary, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: Tokens.s12),
            if (legend != null && !showTable) ...[legend!, const SizedBox(height: Tokens.s12)],
            AnimatedSwitcher(
              duration: MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 150),
              child: KeyedSubtree(key: ValueKey(showTable), child: showTable ? table : RepaintBoundary(child: chart)),
            ),
          ] else ...[
            const SizedBox(height: Tokens.s12),
            Text(emptyMessage, style: theme.textTheme.bodyMedium),
          ],
        ]),
      ),
    );
  }
}

class LegendItem {
  const LegendItem(this.label, this.color);
  final String label;
  final Color color;
}

/// Legend: always present for ≥ 2 series; text in ink, swatch carries identity.
class ChartLegend extends StatelessWidget {
  const ChartLegend(this.items, {super.key});
  final List<LegendItem> items;
  @override
  Widget build(BuildContext context) {
    final viz = VizColors.of(context);
    return Wrap(spacing: 16, runSpacing: 4, children: [
      for (final i in items)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: i.color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 6),
          Text(i.label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: viz.inkSecondary)),
        ]),
    ]);
  }
}

class RankedItem {
  const RankedItem(this.label, this.amount, {this.muted = false});
  final String label;
  final int amount;
  final bool muted;
}

/// Folds everything past [max] into a single muted "Other" (never new hues).
List<RankedItem> foldTail(List<RankedItem> sortedDesc, {int max = 6}) {
  if (sortedDesc.length <= max) return sortedDesc;
  final head = sortedDesc.take(max).toList();
  final rest = sortedDesc.skip(max).fold<int>(0, (s, i) => s + i.amount);
  return [...head, RankedItem('Other', rest, muted: true)];
}

/// Part-to-whole as ranked horizontal bars (clearer than a donut for
/// comparing values). One series → one colour; thin marks anchored at the
/// baseline with a 4px rounded data end; value labelled outside the bar end.
class RankedBars extends StatelessWidget {
  const RankedBars({super.key, required this.items, this.showPercent = true});
  final List<RankedItem> items;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final viz = VizColors.of(context);
    final theme = Theme.of(context);
    final total = items.fold<int>(0, (s, i) => s + i.amount);
    final maxV = items.fold<int>(0, (m, i) => math.max(m, i.amount));
    return Column(children: [
      for (final i in items)
        Semantics(
          label: '${i.label}: ${formatMoney(i.amount)}${showPercent ? ', ${percentOf(i.amount, total)} percent' : ''}',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(i.label, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)),
                Text(
                  showPercent ? '${formatMoney(i.amount)} · ${percentOf(i.amount, total)}%' : formatMoney(i.amount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: viz.inkSecondary, fontFeatures: moneyFeatures),
                ),
              ]),
              const SizedBox(height: 6),
              LayoutBuilder(builder: (c, box) {
                final w = maxV == 0 ? 0.0 : box.maxWidth * (i.amount / maxV);
                return Stack(children: [
                  Container(height: 8, decoration: BoxDecoration(color: viz.grid, borderRadius: BorderRadius.circular(4))),
                  Container(
                    height: 8,
                    width: math.max(w, i.amount > 0 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i.muted ? viz.inkMuted : viz.categorical[0],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ]);
              }),
            ]),
          ),
        ),
    ]);
  }
}

class TableRowData {
  const TableRowData(this.cells);
  final List<String> cells;
}

/// Table twin for any chart.
class DataTableView extends StatelessWidget {
  const DataTableView({super.key, required this.headers, required this.rows});
  final List<String> headers;
  final List<TableRowData> rows;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viz = VizColors.of(context);
    TextStyle? head = theme.textTheme.labelMedium?.copyWith(color: viz.inkSecondary);
    Widget cell(String t, int col, {TextStyle? style}) => Expanded(
          flex: col == 0 ? 2 : 3,
          child: Text(t,
              textAlign: col == 0 ? TextAlign.start : TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: (style ?? theme.textTheme.bodySmall)?.copyWith(fontFeatures: col == 0 ? null : moneyFeatures)),
        );
    return Column(children: [
      Row(children: [for (var i = 0; i < headers.length; i++) cell(headers[i], i, style: head)]),
      Divider(color: viz.grid),
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [for (var i = 0; i < r.cells.length; i++) cell(r.cells[i], i)]),
        ),
    ]);
  }
}

/// A single series of per-day totals as thin rounded bars; the focus bar is
/// at full colour and the rest recede (emphasis, not a rainbow). Touch shows
/// the exact value; max and focus are labelled directly.
class DailyBars extends StatelessWidget {
  const DailyBars({super.key, required this.labels, required this.values, required this.focusIndex, this.height = 160});
  final List<String> labels; // x labels (short)
  final List<int> values; // minor units
  final int focusIndex;
  final double height;

  @override
  Widget build(BuildContext context) {
    final viz = VizColors.of(context);
    final theme = Theme.of(context);
    final maxV = values.fold<int>(0, (m, v) => math.max(m, v));
    final top = maxV == 0 ? 100.0 : maxV / 100 * 1.25;
    final color = viz.categorical[0];
    return SizedBox(
      height: height + 24, // plot + x-axis band, so labels never clip
      child: BarChart(
        BarChartData(
          maxY: top,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: top / 3,
            getDrawingHorizontalLine: (_) => FlLine(color: viz.grid, strokeWidth: 1),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(bottom: BorderSide(color: viz.axis, width: 1)),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: top / 3,
                getTitlesWidget: (v, m) => v == 0 || v > top
                    ? const SizedBox.shrink()
                    : Text(formatCompact((v * 100).round()),
                        style: theme.textTheme.labelSmall?.copyWith(color: viz.inkMuted)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, m) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i],
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: i == focusIndex ? viz.inkPrimary : viz.inkMuted,
                          fontWeight: i == focusIndex ? FontWeight.w700 : FontWeight.w400,
                        )),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => viz.inkPrimary,
              getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                '${labels[gi]}\n${formatMoney(values[gi])}',
                TextStyle(color: viz.surface, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                showingTooltipIndicators: const [],
                barRods: [
                  BarChartRodData(
                    toY: values[i] / 100,
                    width: 18,
                    color: i == focusIndex ? color : color.withValues(alpha: 0.42),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
          extraLinesData: const ExtraLinesData(),
        ),
        duration: MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 200),
      ),
    );
  }

  /// Text twin: label + value.
  List<TableRowData> get rows =>
      [for (var i = 0; i < values.length; i++) TableRowData([labels[i], formatMoney(values[i])])];
}

class TrendPoint {
  const TrendPoint(this.label, this.income, this.expense);
  final String label;
  final int income;
  final int expense;
}

/// Two-series line trend (expenses = slot 1, income = slot 2): 2px lines,
/// no dots until touched, hairline grid, labelled y-axis and endpoint
/// x-labels, crosshair tooltip with both values.
class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.points, this.height = 180});
  final List<TrendPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final viz = VizColors.of(context);
    final theme = Theme.of(context);
    final maxV = points.fold<int>(0, (m, p) => math.max(m, math.max(p.income, p.expense)));
    final top = maxV == 0 ? 100.0 : maxV / 100 * 1.2;
    final expenseColor = viz.categorical[0];
    final incomeColor = viz.categorical[1];
    LineChartBarData line(List<double> ys, Color c) => LineChartBarData(
          spots: [for (var i = 0; i < ys.length; i++) FlSpot(i.toDouble(), ys[i])],
          color: c,
          barWidth: 2,
          isCurved: false,
          dotData: const FlDotData(show: false),
        );
    return SizedBox(
      height: height + 24,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: top,
          minX: 0,
          maxX: math.max(points.length - 1, 1).toDouble(),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: top / 3,
            getDrawingHorizontalLine: (_) => FlLine(color: viz.grid, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: viz.axis))),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: top / 3,
                getTitlesWidget: (v, m) => v == 0 || v > top
                    ? const SizedBox.shrink()
                    : Text(formatCompact((v * 100).round()),
                        style: theme.textTheme.labelSmall?.copyWith(color: viz.inkMuted)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (v, m) {
                  final i = v.toInt();
                  final last = points.length - 1;
                  if (i < 0 || i > last || (i != 0 && i != last && i != last ~/ 2)) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(points[i].label, style: theme.textTheme.labelSmall?.copyWith(color: viz.inkMuted)),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => viz.inkPrimary,
              getTooltipItems: (spots) {
                if (spots.isEmpty) return [];
                final p = points[spots.first.x.toInt()];
                return [
                  for (var k = 0; k < spots.length; k++)
                    LineTooltipItem(
                      k == 0
                          ? '${p.label}\nExpenses ${formatMoney(p.expense)}'
                          : 'Income ${formatMoney(p.income)}',
                      TextStyle(color: viz.surface, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                ];
              },
            ),
            getTouchedSpotIndicator: (bar, idx) => [
              for (final _ in idx)
                TouchedSpotIndicatorData(
                  FlLine(color: viz.axis, strokeWidth: 1),
                  FlDotData(
                    getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                      radius: 4,
                      color: b.color ?? expenseColor,
                      strokeWidth: 2,
                      strokeColor: viz.surface,
                    ),
                  ),
                ),
            ],
          ),
          lineBarsData: [
            line([for (final p in points) p.expense / 100], expenseColor),
            line([for (final p in points) p.income / 100], incomeColor),
          ],
        ),
        duration: MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 200),
      ),
    );
  }
}
