import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker/app/theme.dart';
import 'package:personal_expense_tracker/core/ui/app_tabs.dart';
import 'package:personal_expense_tracker/features/common/charts.dart';
import 'package:personal_expense_tracker/features/common/charts_plan.dart';
import 'package:personal_expense_tracker/features/common/widgets.dart';

Future<void> _pump(WidgetTester t, Widget child) async {
  t.view.physicalSize = const Size(320, 568);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    theme: buildTheme(Brightness.light),
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
      child: c!,
    ),
    home: Scaffold(body: child),
  ));
  // Not pumpAndSettle: EmptyIllustration loops an animation forever.
  await t.pump(const Duration(milliseconds: 800));
}

void main() {
  const longLabel = 'A very long category name that cannot possibly fit on one line';

  testWidgets('RankedBars survives large text and long amounts', (t) async {
    await _pump(
      t,
      const SingleChildScrollView(
        child: RankedBars(items: [RankedItem(longLabel, 123456789012), RankedItem('Food', 5)]),
      ),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('PlanVsActualBars survives large text and long amounts', (t) async {
    await _pump(
      t,
      const SingleChildScrollView(child: PlanVsActualBars(rows: [PlanActualRow(longLabel, 200000000, 123456789012)])),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('EmptyState fits a short viewport', (t) async {
    await _pump(
      t,
      const EmptyState('Tap Add to record your first expense or income.',
          title: 'No transactions yet', actionLabel: 'Add a transaction'),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('AppTabs grows with text scale', (t) async {
    await _pump(
      t,
      const AppTabs<int>(
        tabs: [AppTab(0, 'Expense'), AppTab(1, 'Income'), AppTab(2, 'Transfer')],
        value: 0,
        onChanged: _noop,
      ),
    );
    expect(t.takeException(), isNull);
  });
}

void _noop(int _) {}
