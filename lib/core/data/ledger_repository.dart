import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities.dart';
import '../domain/money.dart';
import '../platform/notification_service.dart';
import '../domain/local_date.dart';
import '../domain/result.dart';
import '../domain/validation.dart';
import '../domain/proof.dart';
import 'db/database.dart';
import 'sync/outbox_service.dart';

/// Offline write path (§7): validate → ONE Drift txn (row pending=true +
/// outbox op) → kick sync. UI reads exclusively via the watch* streams.
class LedgerRepository {
  LedgerRepository({
    required this.db,
    required this.outbox,
    required this.userId,
    required this.onLocalWrite,
  });

  final AppDatabase db;
  final OutboxService outbox;
  final String Function() userId;
  final void Function() onLocalWrite;
  static const _uuid = Uuid();

  String newId() => _uuid.v4();

  // ── Mappers: row → domain ────────────────────────────────────────────────
  Account _acc(AccountRow r) => Account(
      id: r.id, name: r.name, type: r.type, openingBalance: r.openingBalance, isArchived: r.isArchived);
  Category _cat(CategoryRow r) => Category(
      id: r.id, name: r.name, type: r.type, icon: r.icon, color: r.color, isArchived: r.isArchived);
  Tx _tx(TransactionRow r) => Tx(
        id: r.id,
        accountId: r.accountId,
        type: TxTypeX.parse(r.type),
        amount: r.amount,
        occurredAtMs: r.occurredAtMs,
        categoryId: r.categoryId,
        payeeId: r.payeeId,
        direction: TransferDirectionX.parse(r.transferDirection),
        transferGroupId: r.transferGroupId,
        merchant: r.merchant,
        note: r.note,
        plannedStatus: r.plannedStatus,
        receiptPath: r.receiptPath,
        pending: r.pending,
      );

  // ── Server JSON builders ────────────────────────────────────────────────
  Map<String, dynamic> accountJson(AccountRow r) => {
        'id': r.id,
        'user_id': userId(),
        'name': r.name,
        'type': r.type,
        'opening_balance': r.openingBalance,
        'is_archived': r.isArchived,
      };
  Map<String, dynamic> categoryJson(CategoryRow r) => {
        'id': r.id,
        'user_id': userId(),
        'name': r.name,
        'icon': r.icon,
        'color': r.color,
        'type': r.type,
        'is_default': r.isDefault,
        'is_archived': r.isArchived,
      };
  Map<String, dynamic> txJson(TransactionRow r) {
    final type = r.type;
    final isCat = type == 'income' || type == 'expense';
    return {
      'id': r.id,
      'user_id': userId(),
      'account_id': r.accountId,
      // CHECK-shape: only send what the type allows.
      'category_id': isCat ? r.categoryId : null,
      'payee_id': type == 'person_transfer' ? r.payeeId : null,
      'type': type,
      'transfer_direction': isCat ? null : r.transferDirection,
      'transfer_group_id': type == 'transfer' ? r.transferGroupId : null,
      'amount': r.amount,
      'occurred_at': DateTime.fromMillisecondsSinceEpoch(r.occurredAtMs, isUtc: true).toIso8601String(),
      'merchant': r.merchant,
      'note': r.note,
      'planned_status': r.plannedStatus,
      'receipt_path': r.receiptPath,
    };
  }

  Map<String, dynamic> budgetJson(DailyBudgetRow r) => {
        'id': r.id,
        'user_id': userId(),
        'budget_date': r.budgetDate,
        'total_limit': r.totalLimit,
        'original_limit': r.originalLimit,
        'notes': r.notes,
        'is_closed': r.isClosed,
        'closed_at': r.closedAt,
      };
  Map<String, dynamic> allocationJson(BudgetAllocationRow r) => {
        'id': r.id,
        'user_id': userId(),
        'daily_budget_id': r.dailyBudgetId,
        'category_id': r.categoryId,
        'planned_amount': r.plannedAmount,
        'original_amount': r.originalAmount,
      };
  Map<String, dynamic> templateJson(BudgetTemplateRow r) => {
        'id': r.id,
        'user_id': userId(),
        'total_limit': r.totalLimit,
        'allocations': _decodeAllocations(r.allocationsJson)
            .entries
            .map((e) => {'category_id': e.key, 'amount': e.value})
            .toList(),
      };

  /// `[{"category_id": "...", "amount": 1200}, ...]` -> map. Bad rows are skipped.
  static Map<String, int> _decodeAllocations(String json) {
    try {
      final raw = jsonDecode(json);
      if (raw is! List) return const {};
      return {
        for (final e in raw)
          if (e is Map && e['category_id'] is String && e['amount'] is num)
            e['category_id'] as String: (e['amount'] as num).toInt(),
      };
    } catch (_) {
      return const {};
    }
  }

  Map<String, dynamic> plannedJson(PlannedExpenseRow r) => {
        'id': r.id,
        'user_id': userId(),
        'planned_date': r.plannedDate,
        'category_id': r.categoryId,
        'title': r.title,
        'expected_amount': r.expectedAmount,
        'status': r.status,
      };

  // ── Streams (UI source of truth) ─────────────────────────────────────────
  Stream<List<Account>> watchAccounts({bool includeArchived = false}) {
    final q = db.select(db.accounts)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeArchived) q.where((t) => t.isArchived.equals(false));
    return q.watch().map((l) => l.map(_acc).toList());
  }

  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    final q = db.select(db.categories)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeArchived) q.where((t) => t.isArchived.equals(false));
    return q.watch().map((l) => l.map(_cat).toList());
  }

  Stream<List<Tx>> watchTransactions() =>
      (db.select(db.transactions)..orderBy([(t) => OrderingTerm.desc(t.occurredAtMs)]))
          .watch()
          .map((l) => l.map(_tx).toList());

  /// Transactions from [sinceMs] on (dashboard window) — an indexed range
  /// query instead of loading the whole table.
  Stream<List<Tx>> watchTransactionsSince(int sinceMs) =>
      (db.select(db.transactions)
            ..where((t) => t.occurredAtMs.isBiggerOrEqualValue(sinceMs))
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAtMs)]))
          .watch()
          .map((l) => l.map(_tx).toList());

  /// The newest [n] transactions.
  Stream<List<Tx>> watchRecent(int n) =>
      (db.select(db.transactions)
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAtMs)])
            ..limit(n))
          .watch()
          .map((l) => l.map(_tx).toList());

  /// Newest-first page; [limit] null loads everything (used while filtering).
  Stream<List<Tx>> watchTransactionsLimited(int? limit) {
    final q = db.select(db.transactions)..orderBy([(t) => OrderingTerm.desc(t.occurredAtMs)]);
    if (limit != null) q.limit(limit);
    return q.watch().map((l) => l.map(_tx).toList());
  }

  /// Per-account net movement computed by SQLite (no Dart loop over rows).
  Stream<Map<String, int>> watchAccountNet() => db
      .customSelect(
        "SELECT account_id AS a, SUM(CASE type WHEN 'income' THEN amount WHEN 'expense' THEN -amount "
        "ELSE CASE transfer_direction WHEN 'in' THEN amount ELSE -amount END END) AS net "
        'FROM transactions GROUP BY account_id',
        readsFrom: {db.transactions},
      )
      .watch()
      .map((rows) => {for (final r in rows) r.read<String>('a'): r.read<int>('net')});

  Stream<Profile?> watchProfile() => db.select(db.profiles).watch().map((l) {
        if (l.isEmpty) return null;
        final r = l.first;
        return Profile(id: r.id, displayName: r.displayName, currency: r.currency, timezone: r.timezone);
      });

  Stream<List<DailyBudget>> watchBudgets() => db
      .customSelect('SELECT 1', readsFrom: {db.dailyBudgets, db.budgetAllocations})
      .watch()
      .asyncMap((_) async {
    final budgets = await db.select(db.dailyBudgets).get();
    final allocs = await db.select(db.budgetAllocations).get();
    return _joinBudgets(budgets, allocs);
  });

  List<DailyBudget> _joinBudgets(List<DailyBudgetRow> budgets, List<BudgetAllocationRow> allocs) => budgets
      .map((b) => DailyBudget(
            id: b.id,
            date: b.budgetDate,
            totalLimit: b.totalLimit,
            originalLimit: b.originalLimit,
            isClosed: b.isClosed,
            notes: b.notes,
            allocations: allocs
                .where((a) => a.dailyBudgetId == b.id)
                .map((a) => Allocation(
                    categoryId: a.categoryId, plannedAmount: a.plannedAmount, originalAmount: a.originalAmount))
                .toList(),
          ))
      .toList();

  Stream<List<PlannedExpense>> watchPlannedExpenses(String date) =>
      (db.select(db.plannedExpenses)..where((t) => t.plannedDate.equals(date))).watch().map((l) => l
          .map((r) => PlannedExpense(
              id: r.id,
              date: r.plannedDate,
              categoryId: r.categoryId,
              title: r.title,
              expectedAmount: r.expectedAmount,
              status: r.status))
          .toList());

  Future<List<Account>> activeAccounts() async =>
      (await (db.select(db.accounts)..where((t) => t.isArchived.equals(false))).get()).map(_acc).toList();
  Future<List<Category>> activeCategories() async =>
      (await (db.select(db.categories)..where((t) => t.isArchived.equals(false))).get()).map(_cat).toList();

  // ── Transactions ────────────────────────────────────────────────────────
  Future<Result<Tx>> createTransaction(TxInput i) async {
    final failure = validateTxInput(i, accounts: await activeAccounts(), categories: await activeCategories());
    if (failure != null) return Err(failure);
    final id = newId();
    final row = TransactionRow(
      id: id,
      remoteUpdatedAt: null,
      pending: true,
      accountId: i.accountId,
      categoryId: i.categoryId,
      payeeId: null,
      type: i.type.wire,
      transferDirection: null,
      transferGroupId: null,
      amount: i.amount,
      occurredAtMs: i.occurredAtMs,
      merchant: trimOrNull(i.merchant),
      note: trimOrNull(i.note),
      plannedStatus: i.type == TxType.expense ? i.plannedStatus : 'unplanned',
      receiptPath: null,
      receiptLocalFile: null,
    );
    await db.transaction(() async {
      await db.into(db.transactions).insert(row);
      await outbox.enqueueUpsert('transactions', id, txJson(row));
    });
    onLocalWrite();
    if (i.type == TxType.expense) unawaited(_checkBudgetAlert(i.occurredAtMs));
    return Ok(_tx(row));
  }

  Future<Result<Tx>> updateTransaction(String id, TxInput i) async {
    final existing = await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) return Err(Failure.notFound('Transaction not found.'));
    if (existing.type == 'transfer' || existing.type == 'person_transfer') {
      return Err(Failure.validation('Transfers cannot be edited here.'));
    }
    final failure = validateTxInput(i, accounts: await activeAccounts(), categories: await activeCategories());
    if (failure != null) return Err(failure);
    final updated = existing.copyWith(
      pending: true,
      accountId: i.accountId,
      categoryId: Value(i.categoryId),
      type: i.type.wire,
      amount: i.amount,
      occurredAtMs: i.occurredAtMs,
      merchant: Value(trimOrNull(i.merchant)),
      note: Value(trimOrNull(i.note)),
      plannedStatus: i.type == TxType.expense ? i.plannedStatus : 'unplanned',
    );
    await db.transaction(() async {
      await db.update(db.transactions).replace(updated);
      await outbox.enqueueUpsert('transactions', id, txJson(updated), baseUpdatedAt: existing.remoteUpdatedAt);
    });
    onLocalWrite();
    return Ok(_tx(updated));
  }

  Future<Result<Tx>> duplicateTransaction(String id, {int? occurredAtMs}) async {
    final e = await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (e == null) return Err(Failure.notFound('Transaction not found.'));
    if (e.type != 'income' && e.type != 'expense') {
      return Err(Failure.validation('Only income and expense can be duplicated.'));
    }
    return createTransaction(TxInput(
      type: TxTypeX.parse(e.type),
      amount: e.amount,
      accountId: e.accountId,
      categoryId: e.categoryId,
      occurredAtMs: occurredAtMs ?? DateTime.now().millisecondsSinceEpoch,
      merchant: e.merchant,
      note: e.note,
      plannedStatus: e.plannedStatus,
    ));
  }

  /// Deleting one leg of an own-account transfer deletes both legs.
  Future<Result<void>> deleteTransaction(String id) async {
    final e = await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (e == null) return Err(Failure.notFound('Transaction not found.'));
    final victims = (e.type == 'transfer' && e.transferGroupId != null)
        ? await (db.select(db.transactions)..where((t) => t.transferGroupId.equals(e.transferGroupId!))).get()
        : [e];
    await db.transaction(() async {
      for (final v in victims) {
        await (db.delete(db.transactions)..where((t) => t.id.equals(v.id))).go();
        await outbox.enqueueDelete('transactions', v.id, neverSynced: v.remoteUpdatedAt == null);
        if (v.receiptPath != null) {
          // Best-effort object removal AFTER the row delete (or cancel a queued upload).
          final neverUploaded = await outbox.enqueueProofDelete(v.id, v.receiptPath!);
          if (neverUploaded || v.receiptLocalFile != null) await _deleteLocalFile(v.receiptLocalFile);
        }
      }
    });
    onLocalWrite();
    return const Ok(null);
  }

  /// Own-account transfer: 2 rows, one batched outbox op (§8.5).
  Future<Result<String>> createTransfer({
    required String fromId,
    required String toId,
    required int amount,
    required int occurredAtMs,
    String? note,
  }) async {
    final failure =
        validateTransfer(fromId: fromId, toId: toId, amount: amount, accounts: await activeAccounts());
    if (failure != null) return Err(failure);
    final groupId = newId();
    TransactionRow leg(String account, String dir) => TransactionRow(
          id: newId(),
          remoteUpdatedAt: null,
          pending: true,
          accountId: account,
          categoryId: null,
          payeeId: null,
          type: 'transfer',
          transferDirection: dir,
          transferGroupId: groupId,
          amount: amount,
          occurredAtMs: occurredAtMs,
          merchant: null,
          note: trimOrNull(note),
          plannedStatus: 'unplanned',
          receiptPath: null,
          receiptLocalFile: null,
        );
    final out = leg(fromId, 'out');
    final inn = leg(toId, 'in');
    await db.transaction(() async {
      await db.into(db.transactions).insert(out);
      await db.into(db.transactions).insert(inn);
      await outbox.enqueueBatchUpsert('transactions', groupId, [txJson(out), txJson(inn)]);
    });
    onLocalWrite();
    return Ok(groupId);
  }

  // ── People (payees) & person transfers ──────────────────────────────────
  Map<String, dynamic> payeeJson(PayeeRow r) => {
        'id': r.id,
        'user_id': userId(),
        'name': r.name,
        'is_archived': r.isArchived,
      };

  Stream<List<Payee>> watchPayees() => (db.select(db.payees)..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch()
      .map((l) => l.map((r) => Payee(id: r.id, name: r.name, isArchived: r.isArchived)).toList());

  Future<void> _deleteLocalFile(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Finds a payee by case-insensitive name (restoring it if archived) or
  /// creates one. Runs inside the caller's transaction.
  Future<PayeeRow> _findOrCreatePayee(String rawName) async {
    final name = rawName.trim();
    final all = await db.select(db.payees).get();
    final hit = all.where((p) => p.name.toLowerCase() == name.toLowerCase()).firstOrNull;
    if (hit != null) {
      if (!hit.isArchived) return hit;
      final restored = hit.copyWith(isArchived: false, pending: true);
      await db.update(db.payees).replace(restored);
      await outbox.enqueueUpsert('payees', restored.id, payeeJson(restored), baseUpdatedAt: hit.remoteUpdatedAt);
      return restored;
    }
    final row = PayeeRow(id: newId(), remoteUpdatedAt: null, pending: true, name: name, isArchived: false);
    await db.into(db.payees).insert(row);
    await outbox.enqueueUpsert('payees', row.id, payeeJson(row));
    return row;
  }

  /// Person transfer (I sent / I received). Order in the outbox:
  /// payee upsert → upload_proof → transaction upsert.
  Future<Result<Tx>> recordPersonTransfer(PersonTransferInput i, {PreparedProof? proof}) async {
    final failure = validatePersonTransfer(i, accounts: await activeAccounts());
    if (failure != null) return Err(failure);
    late TransactionRow row;
    await db.transaction(() async {
      final payee = await _findOrCreatePayee(i.personName);
      row = TransactionRow(
        id: newId(),
        remoteUpdatedAt: null,
        pending: true,
        accountId: i.accountId,
        categoryId: null,
        payeeId: payee.id,
        type: 'person_transfer',
        transferDirection: i.direction.wire,
        transferGroupId: null,
        amount: i.amount,
        occurredAtMs: i.occurredAtMs,
        merchant: null,
        note: trimOrNull(i.note),
        plannedStatus: 'unplanned',
        receiptPath: proof?.path,
        receiptLocalFile: proof?.localFile,
      );
      await db.into(db.transactions).insert(row);
      if (proof != null) await outbox.enqueueProofUpload(row.id, proof.path, proof.localFile);
      await outbox.enqueueUpsert('transactions', row.id, txJson(row));
    });
    onLocalWrite();
    return Ok(_tx(row));
  }

  /// Edit a person transfer. [removeProof] drops the current proof;
  /// [newProof] replaces it. Old object is deleted AFTER the row update.
  Future<Result<Tx>> updatePersonTransfer(
    String id,
    PersonTransferInput i, {
    PreparedProof? newProof,
    bool removeProof = false,
  }) async {
    final e = await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (e == null || e.type != 'person_transfer') return Err(Failure.notFound('Transfer not found.'));
    final failure = validatePersonTransfer(i, accounts: await activeAccounts());
    if (failure != null) return Err(failure);
    late TransactionRow updated;
    await db.transaction(() async {
      final payee = await _findOrCreatePayee(i.personName);
      final replacing = newProof != null || removeProof;
      updated = e.copyWith(
        pending: true,
        accountId: i.accountId,
        payeeId: Value(payee.id),
        transferDirection: Value(i.direction.wire),
        amount: i.amount,
        occurredAtMs: i.occurredAtMs,
        note: Value(trimOrNull(i.note)),
        receiptPath: Value(replacing ? newProof?.path : e.receiptPath),
        receiptLocalFile: Value(replacing ? newProof?.localFile : e.receiptLocalFile),
      );
      await db.update(db.transactions).replace(updated);
      if (newProof != null) await outbox.enqueueProofUpload(id, newProof.path, newProof.localFile);
      await outbox.enqueueUpsert('transactions', id, txJson(updated), baseUpdatedAt: e.remoteUpdatedAt);
      if (replacing && e.receiptPath != null) {
        final neverUploaded = await outbox.enqueueProofDelete(id, e.receiptPath!);
        if (neverUploaded || e.receiptLocalFile != null) await _deleteLocalFile(e.receiptLocalFile);
      }
    });
    onLocalWrite();
    return Ok(_tx(updated));
  }

  /// Local file for a proof (if still on this device).
  Future<String?> localProofFile(String txId) async =>
      (await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingleOrNull())?.receiptLocalFile;

  // ── Reminder preferences ────────────────────────────────────────────────
  Stream<List<ReminderPref>> watchReminderPrefs() => db.select(db.reminderPreferences).watch().map((l) => l
      .map((r) => ReminderPref(
          type: r.reminderType,
          enabled: r.enabled,
          time: r.reminderTime ?? '20:00',
          thresholdPercent: r.thresholdPercent))
      .toList());

  Future<void> saveReminderPref(ReminderPref p) async {
    final e = await (db.select(db.reminderPreferences)..where((t) => t.reminderType.equals(p.type))).getSingleOrNull();
    final row = ReminderPrefRow(
      id: e?.id ?? newId(),
      remoteUpdatedAt: e?.remoteUpdatedAt,
      pending: true,
      reminderType: p.type,
      enabled: p.enabled,
      reminderTime: p.type == 'budget_threshold' ? null : p.time,
      thresholdPercent: p.type == 'budget_threshold' ? (p.thresholdPercent ?? 90) : null,
    );
    await db.transaction(() async {
      await db.into(db.reminderPreferences).insertOnConflictUpdate(row);
      await outbox.enqueueUpsert(
        'reminder_preferences',
        row.id,
        {
          'id': row.id,
          'user_id': userId(),
          'reminder_type': row.reminderType,
          'enabled': row.enabled,
          'reminder_time': row.reminderTime == null ? null : '${row.reminderTime}:00',
          'threshold_percent': row.thresholdPercent,
        },
        baseUpdatedAt: e?.remoteUpdatedAt,
      );
    });
    onLocalWrite();
  }

  /// §15: one alert per level per day, using spent*100 >= warn*limit.
  Future<void> _checkBudgetAlert(int occurredAtMs) async {
    try {
      final profile = await db.select(db.profiles).getSingleOrNull();
      final zone = profile?.timezone ?? 'Asia/Dhaka';
      final date = localDateOf(occurredAtMs, zone);
      final pref = await (db.select(db.reminderPreferences)..where((t) => t.reminderType.equals('budget_threshold')))
          .getSingleOrNull();
      if (pref == null || !pref.enabled) return;
      final warn = pref.thresholdPercent ?? 90;
      final b = await (db.select(db.dailyBudgets)..where((t) => t.budgetDate.equals(date.value))).getSingleOrNull();
      if (b == null || b.totalLimit <= 0) return;
      final all = await db.select(db.transactions).get();
      final ir = instantRange(date, date, zone);
      final spent = all
          .where((t) => t.type == 'expense' && ir.contains(t.occurredAtMs))
          .fold<int>(0, (s, t) => s + t.amount);
      final level = spent > b.totalLimit ? 100 : (spent * 100 >= warn * b.totalLimit ? warn : 0);
      if (level == 0) return;
      final key = 'alerted:${date.value}';
      final prev = int.tryParse(await db.kvGet(key) ?? '0') ?? 0;
      if (level <= prev) return;
      await db.kvSet(key, '$level');
      final used = '${formatMoney(spent)} of ${formatMoney(b.totalLimit)}';
      await NotificationService.instance.showBudgetAlert(
        level,
        level >= 100 ? "You are over today's limit ($used)." : "You have used $level% of today's limit ($used).",
      );
    } catch (_) {}
  }

  // ── Accounts & categories ────────────────────────────────────────────────
  Future<Result<Account>> saveAccount({
    String? id,
    required String name,
    required String type,
    required int openingBalance,
  }) async {
    final n = name.trim();
    if (n.isEmpty) return Err(Failure.validation('Enter a name.', fields: {'name': 'Enter a name.'}));
    if (!const ['cash', 'bank', 'card', 'mobile', 'other'].contains(type)) {
      return Err(Failure.validation('Invalid account type.'));
    }
    final existing = id == null
        ? null
        : await (db.select(db.accounts)..where((t) => t.id.equals(id))).getSingleOrNull();
    final row = AccountRow(
      id: existing?.id ?? newId(),
      remoteUpdatedAt: existing?.remoteUpdatedAt,
      pending: true,
      name: n,
      type: type,
      openingBalance: openingBalance,
      isArchived: existing?.isArchived ?? false,
    );
    await db.transaction(() async {
      await db.into(db.accounts).insertOnConflictUpdate(row);
      await outbox.enqueueUpsert('accounts', row.id, accountJson(row), baseUpdatedAt: existing?.remoteUpdatedAt);
    });
    onLocalWrite();
    return Ok(_acc(row));
  }

  Future<void> setAccountArchived(String id, bool archived) async {
    final e = await (db.select(db.accounts)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (e == null) return;
    final row = e.copyWith(isArchived: archived, pending: true);
    await db.transaction(() async {
      await db.update(db.accounts).replace(row);
      await outbox.enqueueUpsert('accounts', id, accountJson(row), baseUpdatedAt: e.remoteUpdatedAt);
    });
    onLocalWrite();
  }

  Future<Result<Category>> saveCategory({
    String? id,
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    final n = name.trim();
    if (n.isEmpty) return Err(Failure.validation('Enter a name.', fields: {'name': 'Enter a name.'}));
    if (type != 'income' && type != 'expense') return Err(Failure.validation('Invalid category type.'));
    final existing = id == null
        ? null
        : await (db.select(db.categories)..where((t) => t.id.equals(id))).getSingleOrNull();
    final row = CategoryRow(
      id: existing?.id ?? newId(),
      remoteUpdatedAt: existing?.remoteUpdatedAt,
      pending: true,
      name: n,
      icon: icon ?? existing?.icon,
      color: color ?? existing?.color,
      type: existing?.type ?? type,
      isDefault: existing?.isDefault ?? false,
      isArchived: existing?.isArchived ?? false,
    );
    await db.transaction(() async {
      await db.into(db.categories).insertOnConflictUpdate(row);
      await outbox.enqueueUpsert('categories', row.id, categoryJson(row), baseUpdatedAt: existing?.remoteUpdatedAt);
    });
    onLocalWrite();
    return Ok(_cat(row));
  }

  Future<void> setCategoryArchived(String id, bool archived) async {
    final e = await (db.select(db.categories)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (e == null) return;
    final row = e.copyWith(isArchived: archived, pending: true);
    await db.transaction(() async {
      await db.update(db.categories).replace(row);
      await outbox.enqueueUpsert('categories', id, categoryJson(row), baseUpdatedAt: e.remoteUpdatedAt);
    });
    onLocalWrite();
  }

  // ── Profile ─────────────────────────────────────────────────────────────
  Future<void> saveProfile({String? displayName, String? currency, String? timezone}) async {
    final uid = userId();
    final e = await (db.select(db.profiles)..where((t) => t.id.equals(uid))).getSingleOrNull();
    final row = ProfileRow(
      id: uid,
      remoteUpdatedAt: e?.remoteUpdatedAt,
      pending: true,
      displayName: displayName ?? e?.displayName,
      currency: currency ?? e?.currency ?? 'BDT',
      timezone: timezone ?? e?.timezone ?? 'Asia/Dhaka',
      preferencesJson: e?.preferencesJson ?? '{}',
    );
    await db.transaction(() async {
      await db.into(db.profiles).insertOnConflictUpdate(row);
      await outbox.enqueueUpsert(
        'profiles',
        uid,
        {
          'id': uid,
          'display_name': row.displayName,
          'currency': row.currency,
          'timezone': row.timezone,
          'preferences': jsonDecode(row.preferencesJson),
        },
        baseUpdatedAt: e?.remoteUpdatedAt,
      );
    });
    onLocalWrite();
  }

  // ── Daily plan ──────────────────────────────────────────────────────────
  /// Saves the plan for [date]. NEVER touches original_* of an existing row.
  Future<Result<void>> savePlan({
    required LocalDate date,
    required int totalLimit,
    required Map<String, int> allocations, // categoryId -> planned
    String? notes,
  }) async {
    if (totalLimit < 0) return Err(Failure.validation('Limit cannot be negative.'));
    final sum = allocations.values.fold(0, (s, a) => s + a);
    if (allocations.values.any((a) => a < 0)) return Err(Failure.validation('Allocations cannot be negative.'));
    if (sum > totalLimit) {
      return Err(Failure.validation('Allocations exceed the daily limit.'));
    }
    final existing = await (db.select(db.dailyBudgets)..where((t) => t.budgetDate.equals(date.value)))
        .getSingleOrNull();
    final budget = DailyBudgetRow(
      id: existing?.id ?? newId(),
      remoteUpdatedAt: existing?.remoteUpdatedAt,
      pending: true,
      budgetDate: date.value,
      totalLimit: totalLimit,
      originalLimit: existing?.originalLimit ?? totalLimit,
      notes: trimOrNull(notes),
      isClosed: existing?.isClosed ?? false,
      closedAt: existing?.closedAt,
    );
    final oldAllocs = await (db.select(db.budgetAllocations)..where((t) => t.dailyBudgetId.equals(budget.id))).get();
    await db.transaction(() async {
      await db.into(db.dailyBudgets).insertOnConflictUpdate(budget);
      await outbox.enqueueUpsert('daily_budgets', budget.id, budgetJson(budget),
          baseUpdatedAt: existing?.remoteUpdatedAt);
      final keep = <String>{};
      for (final e in allocations.entries) {
        if (e.value == 0) continue;
        final old = oldAllocs.where((a) => a.categoryId == e.key).firstOrNull;
        final row = BudgetAllocationRow(
          id: old?.id ?? newId(),
          remoteUpdatedAt: old?.remoteUpdatedAt,
          pending: true,
          dailyBudgetId: budget.id,
          categoryId: e.key,
          plannedAmount: e.value,
          originalAmount: old?.originalAmount ?? e.value,
        );
        keep.add(row.id);
        await db.into(db.budgetAllocations).insertOnConflictUpdate(row);
        await outbox.enqueueUpsert('budget_allocations', row.id, allocationJson(row),
            baseUpdatedAt: old?.remoteUpdatedAt);
      }
      for (final old in oldAllocs.where((a) => !keep.contains(a.id))) {
        await (db.delete(db.budgetAllocations)..where((t) => t.id.equals(old.id))).go();
        await outbox.enqueueDelete('budget_allocations', old.id, neverSynced: old.remoteUpdatedAt == null);
      }
    });
    onLocalWrite();
    return const Ok(null);
  }

  // ── Plan template (one per user) ────────────────────────────────────────
  Stream<BudgetTemplate?> watchTemplate() => db.select(db.budgetTemplates).watch().map((l) {
        if (l.isEmpty) return null;
        final r = l.first;
        return BudgetTemplate(totalLimit: r.totalLimit, allocations: _decodeAllocations(r.allocationsJson));
      });

  /// Saves (overwrites) the user's single template. Never touches any day's plan.
  Future<Result<void>> saveTemplate({
    required int totalLimit,
    required Map<String, int> allocations, // categoryId -> planned
  }) async {
    if (totalLimit < 0) return Err(Failure.validation('Limit cannot be negative.'));
    if (allocations.values.any((a) => a < 0)) return Err(Failure.validation('Allocations cannot be negative.'));
    if (allocations.values.fold(0, (s, a) => s + a) > totalLimit) {
      return Err(Failure.validation('Allocations exceed the daily limit.'));
    }
    final existing = await db.select(db.budgetTemplates).get();
    final first = existing.isEmpty ? null : existing.first;
    final row = BudgetTemplateRow(
      id: first?.id ?? newId(),
      remoteUpdatedAt: first?.remoteUpdatedAt,
      pending: true,
      totalLimit: totalLimit,
      allocationsJson: jsonEncode([
        for (final e in allocations.entries)
          if (e.value > 0) {'category_id': e.key, 'amount': e.value},
      ]),
    );
    await db.transaction(() async {
      await db.into(db.budgetTemplates).insertOnConflictUpdate(row);
      await outbox.enqueueUpsert('budget_templates', row.id, templateJson(row),
          baseUpdatedAt: first?.remoteUpdatedAt);
    });
    onLocalWrite();
    return const Ok(null);
  }

  Future<void> setDayClosed(String budgetId, bool closed) async {
    final e = await (db.select(db.dailyBudgets)..where((t) => t.id.equals(budgetId))).getSingleOrNull();
    if (e == null) return;
    final row = e.copyWith(
      isClosed: closed,
      closedAt: Value(closed ? DateTime.now().toUtc().toIso8601String() : null),
      pending: true,
    );
    await db.transaction(() async {
      await db.update(db.dailyBudgets).replace(row);
      await outbox.enqueueUpsert('daily_budgets', budgetId, budgetJson(row), baseUpdatedAt: e.remoteUpdatedAt);
    });
    onLocalWrite();
  }

  /// Copies yesterday's limit/allocations into [date] (as a new plan).
  Future<Result<void>> copyPreviousPlan(LocalDate date) async {
    final prev = await (db.select(db.dailyBudgets)..where((t) => t.budgetDate.equals(date.addDays(-1).value)))
        .getSingleOrNull();
    if (prev == null) return Err(Failure.notFound('No plan for the previous day.'));
    final allocs = await (db.select(db.budgetAllocations)..where((t) => t.dailyBudgetId.equals(prev.id))).get();
    return savePlan(
      date: date,
      totalLimit: prev.totalLimit,
      allocations: {for (final a in allocs) a.categoryId: a.plannedAmount},
    );
  }

  Future<void> addPlannedExpense({
    required LocalDate date,
    required String categoryId,
    required String title,
    required int expectedAmount,
  }) async {
    final row = PlannedExpenseRow(
      id: newId(),
      remoteUpdatedAt: null,
      pending: true,
      plannedDate: date.value,
      categoryId: categoryId,
      title: title.trim(),
      expectedAmount: expectedAmount,
      status: 'planned',
    );
    await db.transaction(() async {
      await db.into(db.plannedExpenses).insert(row);
      await outbox.enqueueUpsert('planned_expenses', row.id, plannedJson(row));
    });
    onLocalWrite();
  }

  Future<void> setPlannedExpenseStatus(String id, String status) async {
    final e = await (db.select(db.plannedExpenses)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (e == null) return;
    final row = e.copyWith(status: status, pending: true);
    await db.transaction(() async {
      await db.update(db.plannedExpenses).replace(row);
      await outbox.enqueueUpsert('planned_expenses', id, plannedJson(row), baseUpdatedAt: e.remoteUpdatedAt);
    });
    onLocalWrite();
  }

  Future<void> deletePlannedExpense(String id) async {
    final e = await (db.select(db.plannedExpenses)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (e == null) return;
    await db.transaction(() async {
      await (db.delete(db.plannedExpenses)..where((t) => t.id.equals(id))).go();
      await outbox.enqueueDelete('planned_expenses', id, neverSynced: e.remoteUpdatedAt == null);
    });
    onLocalWrite();
  }
}
