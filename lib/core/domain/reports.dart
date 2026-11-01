import 'calculators.dart';
import 'entities.dart';
import 'local_date.dart';
import 'money.dart';

class CategoryShare {
  const CategoryShare(this.categoryId, this.amount, this.percent);
  final String? categoryId;
  final int amount;
  final int percent;
}

class TrendBucket {
  const TrendBucket(this.start, this.income, this.expense);
  final LocalDate start;
  final int income;
  final int expense;
}

class MerchantTotal {
  const MerchantTotal(this.merchant, this.amount, this.count);
  final String merchant;
  final int amount;
  final int count;
}

class PeriodComparison {
  const PeriodComparison({
    required this.previousExpenses,
    required this.previousIncome,
    required this.expenseChangePercent,
    required this.incomeChangePercent,
  });
  final int previousExpenses;
  final int previousIncome;
  final int? expenseChangePercent;
  final int? incomeChangePercent;
}

class PeriodReport {
  const PeriodReport({
    required this.range,
    required this.openingBalance,
    required this.closingBalance,
    required this.income,
    required this.expenses,
    required this.net,
    required this.unplanned,
    required this.sentToPeople,
    required this.receivedFromPeople,
    required this.categoryShares,
    required this.accountShares,
    required this.trend,
    required this.trendIsDaily,
    required this.topMerchants,
    required this.plannedVsActual,
    required this.comparison,
    required this.txCount,
  });
  final DateRange range;
  final int openingBalance;
  final int closingBalance;
  final int income;
  final int expenses;
  final int net;
  final int unplanned;
  final int sentToPeople;
  final int receivedFromPeople;
  final List<CategoryShare> categoryShares;
  final List<CategoryShare> accountShares; // categoryId field holds the account id
  final List<TrendBucket> trend;
  final bool trendIsDaily;
  final List<MerchantTotal> topMerchants;
  final List<PlannedVsActualRow> plannedVsActual;
  final PeriodComparison comparison;
  final int txCount;
}

class PeriodReportBuilder {
  static PeriodReport build({
    required DateRange range,
    required String tz,
    required List<Account> accounts,
    required List<Tx> allTxs,
    required List<DailyBudget> budgets,
  }) {
    final ir = instantRange(range.from, range.to, tz);
    final inRange = allTxs.where((t) => ir.contains(t.occurredAtMs)).toList();
    final expenses = inRange.where(TransactionCalculator.isExpense).toList();

    final totalExp = TransactionCalculator.totalExpenses(inRange);
    final totalInc = TransactionCalculator.totalIncome(inRange);

    // Category shares (expenses).
    final byCat = <String?, int>{};
    for (final t in expenses) {
      byCat[t.categoryId] = (byCat[t.categoryId] ?? 0) + t.amount;
    }
    final shares = byCat.entries
        .map((e) => CategoryShare(e.key, e.value, percentOf(e.value, totalExp)))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // Payment-method (account) shares.
    final byAcc = <String?, int>{};
    for (final t in expenses) {
      byAcc[t.accountId] = (byAcc[t.accountId] ?? 0) + t.amount;
    }
    final accShares = byAcc.entries
        .map((e) => CategoryShare(e.key, e.value, percentOf(e.value, totalExp)))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // Trend: daily up to 45 days, else weekly (Mon start).
    final daily = range.days <= 45;
    final buckets = <LocalDate, List<int>>{};
    var cursor = daily ? range.from : range.from.startOfWeek;
    while (!cursor.isAfter(range.to)) {
      buckets[cursor] = [0, 0];
      cursor = cursor.addDays(daily ? 1 : 7);
    }
    for (final t in inRange) {
      if (t.type != TxType.income && t.type != TxType.expense) continue;
      final d = localDateOf(t.occurredAtMs, tz);
      final key = daily ? d : d.startOfWeek;
      final b = buckets[key];
      if (b == null) continue;
      if (t.type == TxType.income) {
        b[0] += t.amount;
      } else {
        b[1] += t.amount;
      }
    }
    final trend = buckets.entries.map((e) => TrendBucket(e.key, e.value[0], e.value[1])).toList();

    // Top merchants.
    final merch = <String, List<int>>{};
    for (final t in expenses) {
      final m = t.merchant?.trim();
      if (m == null || m.isEmpty) continue;
      final k = m.toLowerCase();
      merch.putIfAbsent(k, () => [0, 0]);
      merch[k]![0] += t.amount;
      merch[k]![1] += 1;
    }
    final names = <String, String>{};
    for (final t in expenses) {
      final m = t.merchant?.trim();
      if (m != null && m.isNotEmpty) names.putIfAbsent(m.toLowerCase(), () => m);
    }
    final top = merch.entries
        .map((e) => MerchantTotal(names[e.key]!, e.value[0], e.value[1]))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // Planned vs actual across budgets in range.
    final rangeBudgets = budgets.where((b) {
      final d = LocalDate.parse(b.date);
      return !d.isBefore(range.from) && !d.isAfter(range.to);
    });
    final allocs = rangeBudgets.expand((b) => b.allocations);
    final pva = BudgetCalculator.plannedVsActual(allocs, expenses);

    // Previous period comparison.
    final prev = previousRange(range);
    final pIr = instantRange(prev.from, prev.to, tz);
    final prevTxs = allTxs.where((t) => pIr.contains(t.occurredAtMs)).toList();
    final pExp = TransactionCalculator.totalExpenses(prevTxs);
    final pInc = TransactionCalculator.totalIncome(prevTxs);

    final opening = BalanceCalculator.totalBalance(accounts, allTxs, beforeMs: ir.startMs);
    final closing = BalanceCalculator.totalBalance(accounts, allTxs, beforeMs: ir.endMs);

    return PeriodReport(
      range: range,
      openingBalance: opening,
      closingBalance: closing,
      income: totalInc,
      expenses: totalExp,
      net: totalInc - totalExp,
      unplanned: TransactionCalculator.totalUnplanned(inRange),
      sentToPeople: TransactionCalculator.totalSentToPeople(inRange),
      receivedFromPeople: TransactionCalculator.totalReceivedFromPeople(inRange),
      categoryShares: shares,
      accountShares: accShares,
      trend: trend,
      trendIsDaily: daily,
      topMerchants: top.take(5).toList(),
      plannedVsActual: pva,
      comparison: PeriodComparison(
        previousExpenses: pExp,
        previousIncome: pInc,
        expenseChangePercent: percentChange(totalExp, pExp),
        incomeChangePercent: percentChange(totalInc, pInc),
      ),
      txCount: inRange.length,
    );
  }
}

/// CSV export matching the web format.
class TransactionCsv {
  static const header = 'Date,Time,Type,Amount,Category,Account,Planned,Person,Merchant,Note,Transfer group';

  static String _guard(String s) {
    if (s.isEmpty) return s;
    return RegExp(r'^[=+\-@\t\r]').hasMatch(s) ? "'$s" : s;
  }

  static String _q(String s) {
    final g = _guard(s);
    if (g.contains(',') || g.contains('"') || g.contains('\n') || g.contains('\r')) {
      return '"${g.replaceAll('"', '""')}"';
    }
    return g;
  }

  static int _signed(Tx t) => TransactionCalculator.balanceEffect(t);

  static String build({
    required List<Tx> txs,
    required String tz,
    required Map<String, String> categoryNames,
    required Map<String, String> accountNames,
    required Map<String, String> payeeNames,
  }) {
    final lines = <String>[header];
    final sorted = [...txs]..sort((a, b) => a.occurredAtMs.compareTo(b.occurredAtMs));
    for (final t in sorted) {
      final z = instantToZonedLocal(t.occurredAtMs, tz);
      final date = LocalDate(z.year, z.month, z.day).value;
      final time = '${z.hour.toString().padLeft(2, '0')}:${z.minute.toString().padLeft(2, '0')}';
      // Signed amount, un-guarded numeric column.
      final amount = toDecimalString(_signed(t));
      lines.add([
        date,
        time,
        t.type.wire,
        amount,
        _q(categoryNames[t.categoryId] ?? ''),
        _q(accountNames[t.accountId] ?? ''),
        t.type == TxType.expense ? t.plannedStatus : '',
        _q(payeeNames[t.payeeId] ?? ''),
        _q(t.merchant ?? ''),
        _q(t.note ?? ''),
        t.transferGroupId ?? '',
      ].join(','));
    }
    return lines.join('\r\n');
  }

  /// UTF-8 BOM prefix to add when writing the file.
  static const bom = '﻿';
}
