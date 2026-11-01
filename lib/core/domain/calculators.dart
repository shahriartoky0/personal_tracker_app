import 'entities.dart';
import 'local_date.dart';
import 'money.dart';

/// Classification & totals. Transfers/person transfers are NEVER income/expense.
class TransactionCalculator {
  static bool isExpense(Tx t) => t.type == TxType.expense;
  static bool isIncome(Tx t) => t.type == TxType.income;

  static int totalExpenses(Iterable<Tx> txs) =>
      txs.where(isExpense).fold(0, (s, t) => s + t.amount);

  static int totalIncome(Iterable<Tx> txs) => txs.where(isIncome).fold(0, (s, t) => s + t.amount);

  static int totalUnplanned(Iterable<Tx> txs) =>
      txs.where((t) => isExpense(t) && t.isUnplanned).fold(0, (s, t) => s + t.amount);

  static int totalSentToPeople(Iterable<Tx> txs) => txs
      .where((t) => t.type == TxType.personTransfer && t.direction == TransferDirection.outbound)
      .fold(0, (s, t) => s + t.amount);

  static int totalReceivedFromPeople(Iterable<Tx> txs) => txs
      .where((t) => t.type == TxType.personTransfer && t.direction == TransferDirection.inbound)
      .fold(0, (s, t) => s + t.amount);

  static int netCashFlow(Iterable<Tx> txs) => totalIncome(txs) - totalExpenses(txs);

  static Iterable<Tx> onLocalDate(Iterable<Tx> txs, LocalDate d, String tz) =>
      txs.where((t) => localDateOf(t.occurredAtMs, tz) == d);

  /// Signed effect of a transaction on its account balance.
  static int balanceEffect(Tx t) {
    switch (t.type) {
      case TxType.income:
        return t.amount;
      case TxType.expense:
        return -t.amount;
      case TxType.transfer:
      case TxType.personTransfer:
        return t.direction == TransferDirection.inbound ? t.amount : -t.amount;
    }
  }
}

class BalanceCalculator {
  static int accountBalance(Account a, Iterable<Tx> txs, {int? beforeMs}) {
    var sum = a.openingBalance;
    for (final t in txs) {
      if (t.accountId != a.id) continue;
      if (beforeMs != null && t.occurredAtMs >= beforeMs) continue;
      sum += TransactionCalculator.balanceEffect(t);
    }
    return sum;
  }

  static int totalBalance(Iterable<Account> accounts, Iterable<Tx> txs, {int? beforeMs}) =>
      accounts.where((a) => !a.isArchived).fold(0, (s, a) => s + accountBalance(a, txs, beforeMs: beforeMs));
}

enum BudgetStatus { none, ok, approaching, over }

class DaySummary {
  const DaySummary({
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.planned,
    required this.unplanned,
    required this.status,
    required this.progressPercent,
  });
  final int limit;
  final int spent;
  final int remaining; // may be negative
  final int planned; // spent as planned
  final int unplanned;
  final BudgetStatus status;
  final int progressPercent;
}

class PlannedVsActualRow {
  const PlannedVsActualRow(this.categoryId, this.planned, this.actual);
  final String categoryId;
  final int planned;
  final int actual;
  int get variance => actual - planned;
}

class BudgetCalculator {
  /// [warnPercent] e.g. 75/90/100 (threshold compare: spent*100 >= warn*limit).
  static DaySummary summarizeDay({
    required DailyBudget? budget,
    required Iterable<Tx> dayTxs,
    int warnPercent = 90,
  }) {
    final expenses = dayTxs.where(TransactionCalculator.isExpense);
    final spent = expenses.fold(0, (s, t) => s + t.amount);
    final unplanned = expenses.where((t) => t.isUnplanned).fold(0, (s, t) => s + t.amount);
    if (budget == null || budget.totalLimit <= 0) {
      return DaySummary(
        limit: budget?.totalLimit ?? 0,
        spent: spent,
        remaining: (budget?.totalLimit ?? 0) - spent,
        planned: spent - unplanned,
        unplanned: unplanned,
        status: BudgetStatus.none,
        progressPercent: 0,
      );
    }
    final limit = budget.totalLimit;
    final BudgetStatus status;
    if (spent > limit) {
      status = BudgetStatus.over;
    } else if (spent * 100 >= warnPercent * limit) {
      status = BudgetStatus.approaching;
    } else {
      status = BudgetStatus.ok;
    }
    return DaySummary(
      limit: limit,
      spent: spent,
      remaining: limit - spent,
      planned: spent - unplanned,
      unplanned: unplanned,
      status: status,
      progressPercent: percentOf(spent, limit),
    );
  }

  /// Returns an error message, or null when allocations are valid.
  static String? validateAllocations(int totalLimit, Iterable<int> amounts) {
    var sum = 0;
    for (final a in amounts) {
      if (a < 0) return 'Allocations cannot be negative.';
      sum += a;
    }
    if (sum > totalLimit) {
      return 'Allocated ${formatMoney(sum)} is more than the daily limit of ${formatMoney(totalLimit)}.';
    }
    return null;
  }

  static List<PlannedVsActualRow> plannedVsActual(
      Iterable<Allocation> allocations, Iterable<Tx> dayTxs) {
    final actual = <String, int>{};
    for (final t in dayTxs.where(TransactionCalculator.isExpense)) {
      final c = t.categoryId;
      if (c != null) actual[c] = (actual[c] ?? 0) + t.amount;
    }
    final ids = {...allocations.map((a) => a.categoryId), ...actual.keys};
    return ids
        .map((id) => PlannedVsActualRow(
              id,
              allocations.where((a) => a.categoryId == id).fold(0, (s, a) => s + a.plannedAmount),
              actual[id] ?? 0,
            ))
        .toList();
  }
}
