import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/domain/money.dart';

class PlanActualRow {
  const PlanActualRow(this.label, this.planned, this.actual);
  final String label;
  final int planned;
  final int actual;
}

/// Planned vs actual per category as bullet bars: the fill is what you spent,
/// the tick marks the plan. Over plan = critical colour + icon + text.
class PlanVsActualBars extends StatelessWidget {
  const PlanVsActualBars({super.key, required this.rows});
  final List<PlanActualRow> rows;

  @override
  Widget build(BuildContext context) {
    final viz = VizColors.of(context);
    final theme = Theme.of(context);
    final maxV = rows.fold<int>(0, (m, r) => math.max(m, math.max(r.planned, r.actual)));
    return Column(children: [
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Semantics(
            label:
                '${r.label}: spent ${formatMoney(r.actual)} of ${formatMoney(r.planned)} planned${r.actual > r.planned ? ', over plan' : ''}',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(r.label, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)),
                if (r.actual > r.planned)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.error_outline, size: 14, color: viz.bad),
                  ),
                Text('${formatMoney(r.actual)} / ${formatMoney(r.planned)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: r.actual > r.planned ? viz.bad : viz.inkSecondary, fontFeatures: moneyFeatures)),
              ]),
              const SizedBox(height: 6),
              LayoutBuilder(builder: (c, box) {
                double x(int v) => maxV == 0 ? 0 : box.maxWidth * v / maxV;
                return SizedBox(
                  height: 12,
                  child: Stack(alignment: Alignment.centerLeft, children: [
                    Container(height: 8, decoration: BoxDecoration(color: viz.grid, borderRadius: BorderRadius.circular(4))),
                    Container(
                      height: 8,
                      width: math.max(x(r.actual), r.actual > 0 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: r.actual > r.planned ? viz.bad : viz.categorical[0],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned(
                      left: math.min(x(r.planned), box.maxWidth - 2),
                      child: Container(width: 2, height: 12, color: viz.inkPrimary),
                    ),
                  ]),
                );
              }),
            ]),
          ),
        ),
    ]);
  }
}

/// Delta vs previous period: arrow icon + signed % + colour (never colour alone).
class DeltaText extends StatelessWidget {
  const DeltaText({super.key, required this.percent, required this.upIsGood});
  final int? percent;
  final bool upIsGood;
  @override
  Widget build(BuildContext context) {
    final viz = VizColors.of(context);
    if (percent == null) return Text('—', style: TextStyle(color: viz.inkMuted));
    final up = percent! > 0;
    final flat = percent == 0;
    final good = flat ? null : (up == upIsGood);
    final color = good == null ? viz.inkSecondary : (good ? viz.good : viz.bad);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(flat ? Icons.remove : (up ? Icons.arrow_upward : Icons.arrow_downward), size: 14, color: color),
      const SizedBox(width: 2),
      Text('${up ? '+' : ''}$percent%', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
    ]);
  }
}
