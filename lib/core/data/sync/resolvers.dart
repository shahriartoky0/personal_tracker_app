import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../remote/remote_gateway.dart';
import 'sync_tables.dart';

/// Unique-constraint resolvers (§8.6) — the only id remapping in the system.
class UniqueResolvers {
  UniqueResolvers(this.db, this.remote, this.tables, {int Function()? nowMs})
      : _now = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);
  final AppDatabase db;
  final RemoteGateway remote;
  final SyncTables tables;
  final int Function() _now;

  /// Returns true if resolved (caller retries), false if it can't be.
  Future<bool> resolve(OutboxRow op) async {
    switch (op.entity) {
      case 'payees':
        return _payeeCollision(op);
      case 'daily_budgets':
        return _budgetDateCollision(op);
      default:
        return false;
    }
  }

  /// Replace every occurrence of [from] with [to] inside all outbox payloads.
  Future<void> _remapOutbox(String from, String to) async {
    final rows = await db.select(db.outbox).get();
    for (final r in rows) {
      if (r.payload.contains(from) || r.entityId == from) {
        await (db.update(db.outbox)..where((o) => o.seq.equals(r.seq))).write(OutboxCompanion(
          payload: Value(r.payload.replaceAll(from, to)),
          entityId: Value(r.entityId == from ? to : r.entityId),
        ));
      }
    }
  }

  Future<bool> _payeeCollision(OutboxRow op) async {
    if (op.op != 'upsert') return false;
    final payload = jsonDecode(op.payload) as Map<String, dynamic>;
    final name = payload['name'] as String;
    final localId = payload['id'] as String;
    final server = await remote.fetchPayeeByName(name);
    if (server == null) return false;
    final serverId = server['id'] as String;
    if (serverId == localId) return false;
    await db.transaction(() async {
      // Drop the failing op, then re-point everything at the server payee.
      await (db.delete(db.outbox)..where((o) => o.seq.equals(op.seq))).go();
      await (db.delete(db.payees)..where((t) => t.id.equals(localId))).go();
      await tables.of('payees').applyServerRow(server);
      await (db.update(db.transactions)..where((t) => t.payeeId.equals(localId)))
          .write(TransactionsCompanion(payeeId: Value(serverId)));
      await _remapOutbox(localId, serverId);
      await _log('payees', localId, server, 'merged');
    });
    return true;
  }

  Future<bool> _budgetDateCollision(OutboxRow op) async {
    if (op.op != 'upsert') return false;
    final payload = jsonDecode(op.payload) as Map<String, dynamic>;
    final date = payload['budget_date'] as String;
    final localId = payload['id'] as String;
    final server = await remote.fetchByColumn('daily_budgets', 'budget_date', date);
    if (server == null) return false;
    final serverId = server['id'] as String;
    if (serverId == localId) return false;
    await db.transaction(() async {
      final local = await (db.select(db.dailyBudgets)..where((t) => t.id.equals(localId))).getSingleOrNull();
      await (db.delete(db.dailyBudgets)..where((t) => t.id.equals(localId))).go();
      await tables.of('daily_budgets').applyServerRow(server);
      await (db.update(db.budgetAllocations)..where((t) => t.dailyBudgetId.equals(localId)))
          .write(BudgetAllocationsCompanion(dailyBudgetId: Value(serverId)));
      await _remapOutbox(localId, serverId);
      // Local intent wins: keep user's values, but the server's original_limit.
      payload['id'] = serverId;
      payload['original_limit'] = server['original_limit'];
      await (db.update(db.outbox)..where((o) => o.seq.equals(op.seq))).write(OutboxCompanion(
        payload: Value(jsonEncode(payload)),
        baseUpdatedAt: Value(server['updated_at'] as String?),
        status: const Value('pending'),
        attempts: const Value(0),
        nextAttemptAtMs: const Value(0),
      ));
      if (local != null) {
        await (db.update(db.dailyBudgets)..where((t) => t.id.equals(serverId))).write(DailyBudgetsCompanion(
          totalLimit: Value(local.totalLimit),
          notes: Value(local.notes),
          isClosed: Value(local.isClosed),
          closedAt: Value(local.closedAt),
          pending: const Value(true),
        ));
      }
      await _log('daily_budgets', serverId, server, 'local_won');
    });
    return true;
  }

  Future<void> _log(String entity, String id, Map<String, dynamic> server, String resolution) =>
      db.into(db.conflictLog).insert(ConflictLogCompanion.insert(
            entity: entity,
            entityId: id,
            serverVersionJson: jsonEncode(server),
            resolution: resolution,
            atMs: _now(),
          ));
}
