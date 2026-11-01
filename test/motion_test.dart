import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker/core/domain/money.dart';
import 'package:personal_expense_tracker/core/ui/motion.dart';

Widget _host(int minor, {bool reduce = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduce),
        child: Scaffold(body: AnimatedMoney(minor)),
      ),
    );

void main() {
  testWidgets('AnimatedMoney animates old to new and lands exactly', (tester) async {
    await tester.pumpWidget(_host(1000));
    await tester.pumpAndSettle();
    expect(find.text(formatMoney(1000)), findsOneWidget);

    await tester.pumpWidget(_host(5000));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(formatMoney(1000)), findsNothing);
    expect(find.text(formatMoney(5000)), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text(formatMoney(5000)), findsOneWidget);
  });

  testWidgets('AnimatedMoney shows the final value at once when motion is reduced', (tester) async {
    await tester.pumpWidget(_host(7500, reduce: true));
    await tester.pump();
    expect(find.text(formatMoney(7500)), findsOneWidget);
  });
}
