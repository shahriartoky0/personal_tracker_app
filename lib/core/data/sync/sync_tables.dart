import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// Per-entity glue between server JSON and the local Drift tables.
/// One adapter per synced table (Appendix C mappings live here).
abstract class SyncTable {
  SyncTable(this.db);
  final AppDatabase db;

  String get entity;

  /// PostgREST `onConflict` target for upserts.
  String get onConflict => 'id';

  /// Local row's raw remote updated_at (null if never synced / absent).
  Future<String?> remoteUpdatedAtOf(String id);
  Future<bool> exists(String id);

  /// Insert or overwrite from a server JSON row (pending=false).
  Future<void> applyServerRow(Map<String, dynamic> json);

  /// Record that server accepted our upsert.
  Future<void> markSynced(String id, String? remoteUpdatedAt);

  Future<void> deleteLocal(String id);
}

int? _int(Object? v) => v == null ? null : (v is int ? v : (v as num).toInt());

int _ms(Object? v) => DateTime.parse(v as String).toUtc().millisecondsSinceEpoch;

String _trimTime(String? t) {
  if (t == null) return '';
  return t.length >= 5 ? t.substring(0, 5) : t;
}

class AccountsSync extends SyncTable {
  AccountsSync(super.db);
  @override
  String get entity => 'accounts';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.accounts)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.accounts)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) => db.into(db.accounts).insertOnConflictUpdate(
        AccountsCompanion.insert(
          id: j['id'] as String,
          name: j['name'] as String,
          type: j['type'] as String,
          openingBalance: Value(_int(j['opening_balance']) ?? 0),
          isArchived: Value(j['is_archived'] as bool? ?? false),
          remoteUpdatedAt: Value(j['updated_at'] as String?),
          pending: const Value(false),
        ),
      );
  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.accounts)..where((t) => t.id.equals(id)))
      .write(AccountsCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) => (db.delete(db.accounts)..where((t) => t.id.equals(id))).go();
}

class CategoriesSync extends SyncTable {
  CategoriesSync(super.db);
  @override
  String get entity => 'categories';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.categories)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.categories)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) => db.into(db.categories).insertOnConflictUpdate(
        CategoriesCompanion.insert(
          id: j['id'] as String,
          name: j['name'] as String,
          type: j['type'] as String,
          icon: Value(j['icon'] as String?),
          color: Value(j['color'] as String?),
          isDefault: Value(j['is_default'] as bool? ?? false),
          isArchived: Value(j['is_archived'] as bool? ?? false),
          remoteUpdatedAt: Value(j['updated_at'] as String?),
          pending: const Value(false),
        ),
      );
  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.categories)..where((t) => t.id.equals(id)))
      .write(CategoriesCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) => (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
}

class PayeesSync extends SyncTable {
  PayeesSync(super.db);
  @override
  String get entity => 'payees';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.payees)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.payees)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) => db.into(db.payees).insertOnConflictUpdate(
        PayeesCompanion.insert(
          id: j['id'] as String,
          name: j['name'] as String,
          isArchived: Value(j['is_archived'] as bool? ?? false),
          remoteUpdatedAt: Value(j['updated_at'] as String?),
          pending: const Value(false),
        ),
      );
  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.payees)..where((t) => t.id.equals(id)))
      .write(PayeesCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) => (db.delete(db.payees)..where((t) => t.id.equals(id))).go();
}

class DailyBudgetsSync extends SyncTable {
  DailyBudgetsSync(super.db);
  @override
  String get entity => 'daily_budgets';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.dailyBudgets)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.dailyBudgets)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) async {
    // Unique (budget_date): if another local row holds this date under a
    // different id, the server wins on id (resolver normally handles this).
    final date = j['budget_date'] as String;
    await (db.delete(db.dailyBudgets)
          ..where((t) => t.budgetDate.equals(date) & t.id.equals(j['id'] as String).not()))
        .go();
    await db.into(db.dailyBudgets).insertOnConflictUpdate(
          DailyBudgetsCompanion.insert(
            id: j['id'] as String,
            budgetDate: date,
            totalLimit: _int(j['total_limit']) ?? 0,
            originalLimit: _int(j['original_limit']) ?? _int(j['total_limit']) ?? 0,
            notes: Value(j['notes'] as String?),
            isClosed: Value(j['is_closed'] as bool? ?? false),
            closedAt: Value(j['closed_at'] as String?),
            remoteUpdatedAt: Value(j['updated_at'] as String?),
            pending: const Value(false),
          ),
        );
  }

  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.dailyBudgets)..where((t) => t.id.equals(id)))
      .write(DailyBudgetsCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) async {
    // Mirror server cascade.
    await (db.delete(db.budgetAllocations)..where((t) => t.dailyBudgetId.equals(id))).go();
    await (db.delete(db.dailyBudgets)..where((t) => t.id.equals(id))).go();
  }
}

class BudgetAllocationsSync extends SyncTable {
  BudgetAllocationsSync(super.db);
  @override
  String get entity => 'budget_allocations';
  @override
  String get onConflict => 'daily_budget_id,category_id';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.budgetAllocations)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.budgetAllocations)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) async {
    final b = j['daily_budget_id'] as String;
    final c = j['category_id'] as String;
    await (db.delete(db.budgetAllocations)
          ..where((t) => t.dailyBudgetId.equals(b) & t.categoryId.equals(c) & t.id.equals(j['id'] as String).not()))
        .go();
    await db.into(db.budgetAllocations).insertOnConflictUpdate(
          BudgetAllocationsCompanion.insert(
            id: j['id'] as String,
            dailyBudgetId: b,
            categoryId: c,
            plannedAmount: _int(j['planned_amount']) ?? 0,
            originalAmount: _int(j['original_amount']) ?? _int(j['planned_amount']) ?? 0,
            remoteUpdatedAt: Value(j['updated_at'] as String?),
            pending: const Value(false),
          ),
        );
  }

  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.budgetAllocations)..where((t) => t.id.equals(id)))
      .write(BudgetAllocationsCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) =>
      (db.delete(db.budgetAllocations)..where((t) => t.id.equals(id))).go();
}

class BudgetTemplatesSync extends SyncTable {
  BudgetTemplatesSync(super.db);
  @override
  String get entity => 'budget_templates';
  @override
  String get onConflict => 'user_id';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.budgetTemplates)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.budgetTemplates)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) async {
    final alloc = j['allocations'];
    await db.into(db.budgetTemplates).insertOnConflictUpdate(
          BudgetTemplatesCompanion.insert(
            id: j['id'] as String,
            totalLimit: _int(j['total_limit']) ?? 0,
            allocationsJson: Value(alloc is String ? alloc : jsonEncode(alloc ?? [])),
            remoteUpdatedAt: Value(j['updated_at'] as String?),
            pending: const Value(false),
          ),
        );
  }

  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.budgetTemplates)..where((t) => t.id.equals(id)))
      .write(BudgetTemplatesCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) =>
      (db.delete(db.budgetTemplates)..where((t) => t.id.equals(id))).go();
}

class PlannedExpensesSync extends SyncTable {
  PlannedExpensesSync(super.db);
  @override
  String get entity => 'planned_expenses';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.plannedExpenses)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.plannedExpenses)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) => db.into(db.plannedExpenses).insertOnConflictUpdate(
        PlannedExpensesCompanion.insert(
          id: j['id'] as String,
          plannedDate: j['planned_date'] as String,
          categoryId: j['category_id'] as String,
          title: j['title'] as String,
          expectedAmount: _int(j['expected_amount']) ?? 0,
          status: Value(j['status'] as String? ?? 'planned'),
          remoteUpdatedAt: Value(j['updated_at'] as String?),
          pending: const Value(false),
        ),
      );
  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.plannedExpenses)..where((t) => t.id.equals(id)))
      .write(PlannedExpensesCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) =>
      (db.delete(db.plannedExpenses)..where((t) => t.id.equals(id))).go();
}

class TransactionsSync extends SyncTable {
  TransactionsSync(super.db);
  @override
  String get entity => 'transactions';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) => db.into(db.transactions).insertOnConflictUpdate(
        TransactionsCompanion.insert(
          id: j['id'] as String,
          accountId: j['account_id'] as String,
          categoryId: Value(j['category_id'] as String?),
          payeeId: Value(j['payee_id'] as String?),
          type: j['type'] as String,
          transferDirection: Value(j['transfer_direction'] as String?),
          transferGroupId: Value(j['transfer_group_id'] as String?),
          amount: _int(j['amount']) ?? 0,
          occurredAtMs: _ms(j['occurred_at']),
          merchant: Value(j['merchant'] as String?),
          note: Value(j['note'] as String?),
          plannedStatus: Value(j['planned_status'] as String? ?? 'unplanned'),
          receiptPath: Value(j['receipt_path'] as String?),
          remoteUpdatedAt: Value(j['updated_at'] as String?),
          pending: const Value(false),
        ),
      );
  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.transactions)..where((t) => t.id.equals(id)))
      .write(TransactionsCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) => (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
}

class ReminderPrefsSync extends SyncTable {
  ReminderPrefsSync(super.db);
  @override
  String get entity => 'reminder_preferences';
  @override
  String get onConflict => 'user_id,reminder_type';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.reminderPreferences)..where((t) => t.id.equals(id))).getSingleOrNull())
          ?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.reminderPreferences)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) async {
    final type = j['reminder_type'] as String;
    await (db.delete(db.reminderPreferences)
          ..where((t) => t.reminderType.equals(type) & t.id.equals(j['id'] as String).not()))
        .go();
    await db.into(db.reminderPreferences).insertOnConflictUpdate(
          ReminderPreferencesCompanion.insert(
            id: j['id'] as String,
            reminderType: type,
            enabled: Value(j['enabled'] as bool? ?? true),
            reminderTime: Value(j['reminder_time'] == null ? null : _trimTime(j['reminder_time'] as String)),
            thresholdPercent: Value(_int(j['threshold_percent'])),
            remoteUpdatedAt: Value(j['updated_at'] as String?),
            pending: const Value(false),
          ),
        );
  }

  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.reminderPreferences)..where((t) => t.id.equals(id)))
      .write(ReminderPreferencesCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) =>
      (db.delete(db.reminderPreferences)..where((t) => t.id.equals(id))).go();
}

class ProfilesSync extends SyncTable {
  ProfilesSync(super.db);
  @override
  String get entity => 'profiles';
  @override
  Future<String?> remoteUpdatedAtOf(String id) async =>
      (await (db.select(db.profiles)..where((t) => t.id.equals(id))).getSingleOrNull())?.remoteUpdatedAt;
  @override
  Future<bool> exists(String id) async =>
      (await (db.select(db.profiles)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;
  @override
  Future<void> applyServerRow(Map<String, dynamic> j) {
    final prefs = j['preferences'];
    return db.into(db.profiles).insertOnConflictUpdate(
          ProfilesCompanion.insert(
            id: j['id'] as String,
            displayName: Value(j['display_name'] as String?),
            currency: Value(j['currency'] as String? ?? 'BDT'),
            timezone: Value(j['timezone'] as String? ?? 'Asia/Dhaka'),
            preferencesJson: Value(prefs is String ? prefs : jsonEncode(prefs ?? {})),
            remoteUpdatedAt: Value(j['updated_at'] as String?),
            pending: const Value(false),
          ),
        );
  }

  @override
  Future<void> markSynced(String id, String? u) => (db.update(db.profiles)..where((t) => t.id.equals(id)))
      .write(ProfilesCompanion(pending: const Value(false), remoteUpdatedAt: Value(u)));
  @override
  Future<void> deleteLocal(String id) async {} // profiles are never deleted by clients
}

class SyncTables {
  SyncTables(AppDatabase db)
      : all = {
          for (final t in <SyncTable>[
            AccountsSync(db),
            CategoriesSync(db),
            PayeesSync(db),
            DailyBudgetsSync(db),
            BudgetAllocationsSync(db),
            BudgetTemplatesSync(db),
            PlannedExpensesSync(db),
            TransactionsSync(db),
            ReminderPrefsSync(db),
            ProfilesSync(db),
          ])
            t.entity: t,
        };
  final Map<String, SyncTable> all;
  SyncTable of(String entity) => all[entity]!;
}
