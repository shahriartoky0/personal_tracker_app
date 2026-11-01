import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Accounts,
  Categories,
  Payees,
  DailyBudgets,
  BudgetAllocations,
  BudgetTemplates,
  PlannedExpenses,
  Transactions,
  ReminderPreferences,
  Profiles,
  Outbox,
  SyncCursors,
  ConflictLog,
  LocalKv,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the encrypted on-device database. [hexKey] is generated on first
  /// launch and kept in secure storage (see key_store.dart).
  factory AppDatabase.open(String hexKey) {
    return AppDatabase(driftDatabase(
      name: 'taka_tracker',
      native: DriftNativeOptions(
        setup: (db) {
          // SQLite3 Multiple Ciphers: raw hex key.
          db.execute("PRAGMA key = \"x'$hexKey'\";");
        },
      ),
    ));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Add stepwise migrations here. NEVER drop the outbox table.
        onUpgrade: (m, from, to) async {},
        beforeOpen: (details) async {
          // Pull-apply order across pages is arbitrary; FKs are not declared.
          await customStatement('PRAGMA foreign_keys = OFF');
        },
      );

  // ── Key/value helpers ────────────────────────────────────────────────────
  Future<String?> kvGet(String key) async {
    final r = await (select(localKv)..where((t) => t.key.equals(key))).getSingleOrNull();
    return r?.value;
  }

  Future<void> kvSet(String key, String value) =>
      into(localKv).insertOnConflictUpdate(LocalKvCompanion.insert(key: key, value: value));
}

/// Names of tables that are synced, in dependency order (§8.4).
const syncEntitiesInOrder = <String>[
  'accounts',
  'categories',
  'payees',
  'daily_budgets',
  'budget_allocations',
  'budget_templates',
  'planned_expenses',
  'transactions',
  'reminder_preferences',
];
