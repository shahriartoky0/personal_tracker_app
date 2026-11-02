enum TxType { income, expense, transfer, personTransfer }

extension TxTypeX on TxType {
  String get wire => switch (this) {
        TxType.income => 'income',
        TxType.expense => 'expense',
        TxType.transfer => 'transfer',
        TxType.personTransfer => 'person_transfer',
      };
  static TxType parse(String s) => switch (s) {
        'income' => TxType.income,
        'expense' => TxType.expense,
        'transfer' => TxType.transfer,
        'person_transfer' => TxType.personTransfer,
        _ => throw FormatException('Unknown transaction type: $s'),
      };
}

enum TransferDirection { inbound, outbound }

extension TransferDirectionX on TransferDirection {
  String get wire => this == TransferDirection.inbound ? 'in' : 'out';
  static TransferDirection? parse(String? s) => switch (s) {
        'in' => TransferDirection.inbound,
        'out' => TransferDirection.outbound,
        _ => null,
      };
}

class Tx {
  const Tx({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.occurredAtMs,
    this.categoryId,
    this.payeeId,
    this.direction,
    this.transferGroupId,
    this.merchant,
    this.note,
    this.plannedStatus = 'unplanned',
    this.receiptPath,
    this.pending = false,
  });

  final String id;
  final String accountId;
  final TxType type;
  final int amount; // > 0 minor units
  final int occurredAtMs;
  final String? categoryId;
  final String? payeeId;
  final TransferDirection? direction;
  final String? transferGroupId;
  final String? merchant;
  final String? note;
  final String plannedStatus; // planned | unplanned
  final String? receiptPath;
  final bool pending;

  bool get isUnplanned => plannedStatus == 'unplanned';
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    this.isArchived = false,
  });
  final String id;
  final String name;
  final String type; // cash|bank|card|mobile|other
  final int openingBalance;
  final bool isArchived;
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.isArchived = false,
  });
  final String id;
  final String name;
  final String type; // income|expense
  final String? icon;
  final String? color;
  final bool isArchived;
}

class Allocation {
  const Allocation({required this.categoryId, required this.plannedAmount, required this.originalAmount});
  final String categoryId;
  final int plannedAmount;
  final int originalAmount;
}

class DailyBudget {
  const DailyBudget({
    required this.id,
    required this.date,
    required this.totalLimit,
    required this.originalLimit,
    this.isClosed = false,
    this.notes,
    this.allocations = const [],
  });
  final String id;
  final String date; // YYYY-MM-DD
  final int totalLimit;
  final int originalLimit;
  final bool isClosed;
  final String? notes;
  final List<Allocation> allocations;
}

/// The user's single reusable daily plan: a limit plus category amounts, with
/// no date. Loading it into a day only fills the form.
class BudgetTemplate {
  const BudgetTemplate({required this.totalLimit, this.allocations = const {}});
  final int totalLimit;
  final Map<String, int> allocations; // categoryId -> planned (minor units)
}

class PlannedExpense {
  const PlannedExpense({
    required this.id,
    required this.date,
    required this.categoryId,
    required this.title,
    required this.expectedAmount,
    required this.status,
  });
  final String id;
  final String date;
  final String categoryId;
  final String title;
  final int expectedAmount;
  final String status; // planned|completed|skipped
}

class Profile {
  const Profile({required this.id, this.displayName, this.currency = 'BDT', this.timezone = 'Asia/Dhaka'});
  final String id;
  final String? displayName;
  final String currency;
  final String timezone;
}

class Payee {
  const Payee({required this.id, required this.name, this.isArchived = false});
  final String id;
  final String name;
  final bool isArchived;
}
