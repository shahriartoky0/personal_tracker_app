import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'db/database.dart';

/// Online-only destructive operations (§12.7, §14.9).
class DataReset {
  DataReset(this.db, this.client);
  final AppDatabase db;
  final SupabaseClient client;

  static const _dataTables = [
    'transactions',
    'planned_expenses',
    'budget_allocations',
    'daily_budgets',
    'budget_templates',
  ];

  /// Deletes transactions and plans on the server (RLS scopes to the user),
  /// then removes them locally. Server deletes write tombstones, so other
  /// devices converge on their next pull. Proof objects are not removed here.
  Future<void> deleteTransactionsAndPlans() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    for (final t in _dataTables) {
      await client.from(t).delete().eq('user_id', uid);
    }
    await db.transaction(() async {
      for (final t in <TableInfo<Table, dynamic>>[
        db.transactions,
        db.plannedExpenses,
        db.budgetAllocations,
        db.dailyBudgets,
        db.budgetTemplates,
      ]) {
        await db.delete(t).go();
      }
      // Drop queued ops for the cleared tables so they aren't re-created.
      await (db.delete(db.outbox)..where((o) => o.entity.isIn(_dataTables))).go();
    });
  }

  /// Calls the `delete-account` Edge Function (service role lives server-side),
  /// then wipes all local data and signs out.
  Future<void> deleteAccount() async {
    final res = await client.functions.invoke('delete-account');
    if (res.status >= 300) throw StateError('Account deletion failed (${res.status})');
    await db.transaction(() async {
      for (final t in <TableInfo<Table, dynamic>>[
        db.transactions,
        db.plannedExpenses,
        db.budgetAllocations,
        db.dailyBudgets,
        db.budgetTemplates,
        db.reminderPreferences,
        db.payees,
        db.categories,
        db.accounts,
        db.profiles,
        db.outbox,
        db.syncCursors,
        db.conflictLog,
        db.localKv,
      ]) {
        await db.delete(t).go();
      }
    });
    await client.auth.signOut();
  }
}
