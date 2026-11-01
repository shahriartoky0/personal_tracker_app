import 'entities.dart';
import 'money.dart';
import 'result.dart';

class TxInput {
  const TxInput({
    required this.type, // income | expense
    required this.amount,
    required this.accountId,
    required this.categoryId,
    required this.occurredAtMs,
    this.merchant,
    this.note,
    this.plannedStatus = 'unplanned',
  });
  final TxType type;
  final int amount;
  final String accountId;
  final String? categoryId;
  final int occurredAtMs;
  final String? merchant;
  final String? note;
  final String plannedStatus;
}

String? trimOrNull(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// Validates income/expense input. Returns null when valid.
Failure? validateTxInput(
  TxInput i, {
  required List<Account> accounts,
  required List<Category> categories,
}) {
  final fields = <String, String>{};
  if (i.type != TxType.income && i.type != TxType.expense) {
    return Failure.validation('Unsupported transaction type.');
  }
  if (i.amount <= 0) fields['amount'] = 'Enter an amount greater than zero.';
  if (i.amount > maxMinor) fields['amount'] = 'That amount is too large.';
  final acc = accounts.where((a) => a.id == i.accountId && !a.isArchived);
  if (acc.isEmpty) fields['accountId'] = 'Choose an account.';
  if (i.categoryId == null) {
    fields['categoryId'] = 'Choose a category.';
  } else {
    final wanted = i.type == TxType.expense ? 'expense' : 'income';
    final cat = categories.where((c) => c.id == i.categoryId && !c.isArchived && c.type == wanted);
    if (cat.isEmpty) fields['categoryId'] = 'Choose a valid $wanted category.';
  }
  if ((i.merchant?.length ?? 0) > 120) fields['merchant'] = 'Merchant is too long (max 120).';
  if ((i.note?.length ?? 0) > 500) fields['note'] = 'Note is too long (max 500).';
  if (!const ['planned', 'unplanned'].contains(i.plannedStatus)) {
    fields['plannedStatus'] = 'Invalid planned status.';
  }
  if (fields.isNotEmpty) return Failure.validation('Please fix the highlighted fields.', fields: fields);
  return null;
}

Failure? validateTransfer({
  required String fromId,
  required String toId,
  required int amount,
  required List<Account> accounts,
}) {
  final fields = <String, String>{};
  if (fromId == toId) fields['toId'] = 'Choose two different accounts.';
  if (amount <= 0) fields['amount'] = 'Enter an amount greater than zero.';
  if (amount > maxMinor) fields['amount'] = 'That amount is too large.';
  bool active(String id) => accounts.any((a) => a.id == id && !a.isArchived);
  if (!active(fromId)) fields['fromId'] = 'Choose a source account.';
  if (!active(toId)) fields['toId'] = 'Choose a destination account.';
  if (fields.isNotEmpty) return Failure.validation('Please fix the highlighted fields.', fields: fields);
  return null;
}

class PersonTransferInput {
  const PersonTransferInput({
    required this.personName,
    required this.direction,
    required this.amount,
    required this.accountId,
    required this.occurredAtMs,
    this.note,
  });
  final String personName;
  final TransferDirection direction;
  final int amount;
  final String accountId;
  final int occurredAtMs;
  final String? note;
}

Failure? validatePersonTransfer(PersonTransferInput i, {required List<Account> accounts}) {
  final fields = <String, String>{};
  final name = i.personName.trim();
  if (name.isEmpty) fields['personName'] = 'Enter who this is with.';
  if (name.length > 80) fields['personName'] = 'Name is too long (max 80).';
  if (i.amount <= 0) fields['amount'] = 'Enter an amount greater than zero.';
  if (i.amount > maxMinor) fields['amount'] = 'That amount is too large.';
  if (!accounts.any((a) => a.id == i.accountId && !a.isArchived)) fields['accountId'] = 'Choose an account.';
  if ((i.note?.length ?? 0) > 500) fields['note'] = 'Note is too long (max 500).';
  if (fields.isNotEmpty) return Failure.validation('Please fix the highlighted fields.', fields: fields);
  return null;
}
