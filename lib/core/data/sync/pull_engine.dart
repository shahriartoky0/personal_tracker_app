import 'dart:convert';

import 'package:drift/drift.dart';

import '../../logging/app_log.dart';
import '../db/database.dart';
import '../remote/remote_gateway.dart';
import 'sync_tables.dart';

/// Supabase → device delta pull (§9).
class PullEngine {
  PullEngine({
    required this.db,
    required this.remote,
    required this.tables,
    int Function()? nowMs,
  }) : _now = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final AppDatabase db;
  final RemoteGateway remote;
  final SyncTables tables;
  final int Function() _now;

  static const pageSize = 1000;
  static const overlap = Duration(minutes: 2);
  static const tombstoneRetention = Duration(days: 90);
  static const _kTombstoneCursor = 'tombstone_cursor';

  /// Dependency order, profile first.
  static final pullOrder = ['profiles', ...syncEntitiesInOrder];

  bool cancelled = false;

  Future<SyncCursorRow?> _cursor(String entity) =>
      (db.select(db.syncCursors)..where((c) => c.entity.equals(entity))).getSingleOrNull();

  DateTime? _parse(String? s) => s == null ? null : DateTime.tryParse(s);

  /// Delta pull of every table, then tombstones. [fullBootstrap] ignores
  /// stored cursors (used for first sign-in / rebuild).
  Future<void> pullAll({bool fullBootstrap = false, void Function(String entity, int index, int total)? onTable}) async {
    for (var i = 0; i < pullOrder.length; i++) {
      if (cancelled) return;
      onTable?.call(pullOrder[i], i, pullOrder.length);
      await _pullEntity(pullOrder[i], fullBootstrap: fullBootstrap);
    }
    if (cancelled) return;
    await _pullTombstones(fullBootstrap: fullBootstrap);
  }

  Future<void> _pullEntity(String entity, {required bool fullBootstrap}) async {
    final table = tables.of(entity);
    final stored = fullBootstrap ? null : await _cursor(entity);
    String? updatedAt = stored?.updatedAt;
    String? lastId = stored?.lastId;
    var first = true;
    while (!cancelled) {
      String? qUpdated = updatedAt;
      String? qId = lastId;
      if (first && updatedAt != null) {
        // Overlap window: re-read the last couple of minutes (idempotent apply).
        final t = _parse(updatedAt);
        if (t != null) {
          qUpdated = t.subtract(overlap).toUtc().toIso8601String();
          qId = null;
        }
      }
      first = false;
      final page = await remote.pullPage(entity, updatedAt: qUpdated, lastId: qId, limit: pageSize);
      AppLog.line('sync.pull', '$entity: ${page.length} row(s)');
      if (page.isEmpty) break;
      await db.transaction(() async {
        for (final row in page) {
          await _applyRow(table, entity, row);
        }
        final last = page.last;
        final newU = last['updated_at'] as String;
        final prev = _parse(updatedAt);
        final cur = _parse(newU);
        final advance = prev == null || (cur != null && !cur.isBefore(prev));
        if (advance) {
          updatedAt = newU;
          lastId = last['id'] as String;
        }
        await db.into(db.syncCursors).insertOnConflictUpdate(SyncCursorsCompanion.insert(
              entity: entity,
              updatedAt: Value(updatedAt),
              lastId: Value(lastId),
              lastSuccessMs: Value(_now()),
            ));
      });
      if (page.length < pageSize) break;
    }
    // Record success even when nothing changed.
    final c = await _cursor(entity);
    await db.into(db.syncCursors).insertOnConflictUpdate(SyncCursorsCompanion.insert(
          entity: entity,
          updatedAt: Value(c?.updatedAt),
          lastId: Value(c?.lastId),
          lastSuccessMs: Value(_now()),
        ));
  }

  /// §9.3: server rows never clobber a row with unsent local changes.
  Future<void> _applyRow(SyncTable table, String entity, Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final groupId = row['transfer_group_id'] as String?;
    final ops = await (db.select(db.outbox)
          ..where((o) =>
              o.entity.equals(entity) & (o.entityId.equals(id) | (groupId == null ? const Constant(false) : o.entityId.equals(groupId)))))
        .get();
    if (ops.isEmpty) {
      await table.applyServerRow(row);
      return;
    }
    // Local row has pending changes → local wins; log if the server moved on.
    final serverAt = row['updated_at'] as String?;
    final upsert = ops.where((o) => o.op.startsWith('upsert')).firstOrNull;
    if (upsert != null && serverAt != null && upsert.baseUpdatedAt != serverAt) {
      await db.into(db.conflictLog).insert(ConflictLogCompanion.insert(
            entity: entity,
            entityId: id,
            serverVersionJson: jsonEncode(row),
            resolution: 'local_won',
            atMs: _now(),
          ));
      await (db.update(db.outbox)..where((o) => o.seq.equals(upsert.seq)))
          .write(OutboxCompanion(baseUpdatedAt: Value(serverAt)));
    }
  }

  Future<void> _pullTombstones({required bool fullBootstrap}) async {
    final stored = fullBootstrap ? null : await db.kvGet(_kTombstoneCursor);
    String? deletedAt;
    int? lastId;
    if (stored != null) {
      final parts = stored.split('|');
      deletedAt = parts[0];
      lastId = int.tryParse(parts.length > 1 ? parts[1] : '');
    }
    var first = true;
    while (!cancelled) {
      String? qAt = deletedAt;
      int? qId = lastId;
      if (first && deletedAt != null) {
        final t = _parse(deletedAt);
        if (t != null) {
          qAt = t.subtract(overlap).toUtc().toIso8601String();
          qId = null;
        }
      }
      first = false;
      final page = await remote.pullTombstones(deletedAt: qAt, lastId: qId, limit: pageSize);
      AppLog.line('sync.pull', 'tombstones: ${page.length} row(s)');
      if (page.isEmpty) break;
      await db.transaction(() async {
        for (final t in page) {
          await _applyTombstone(t);
        }
        final last = page.last;
        final newAt = last['deleted_at'] as String;
        final prev = _parse(deletedAt);
        final cur = _parse(newAt);
        if (prev == null || (cur != null && !cur.isBefore(prev))) {
          deletedAt = newAt;
          lastId = (last['id'] as num).toInt();
          await db.kvSet(_kTombstoneCursor, '$deletedAt|$lastId');
        }
      });
      if (page.length < pageSize) break;
    }
  }

  Future<void> _applyTombstone(Map<String, dynamic> t) async {
    final name = t['table_name'] as String;
    final id = t['row_id'] as String;
    final table = tables.all[name];
    if (table == null) return;
    final pending = await (db.select(db.outbox)
          ..where((o) => o.entity.equals(name) & o.entityId.equals(id) & o.op.like('upsert%')))
        .get();
    if (pending.isNotEmpty) {
      // Remote delete vs local pending edit → edit wins; row is re-created on push.
      await db.into(db.conflictLog).insert(ConflictLogCompanion.insert(
            entity: name,
            entityId: id,
            serverVersionJson: jsonEncode({'deleted': true}),
            resolution: 'local_won',
            atMs: _now(),
          ));
      return;
    }
    await table.deleteLocal(id);
  }

  /// True when the last successful pull is older than the tombstone window
  /// (minus a safety margin) — a full re-bootstrap is required.
  Future<bool> retentionExceeded() async {
    final c = await _cursor('transactions');
    final last = c?.lastSuccessMs;
    if (last == null) return false;
    return _now() - last > (tombstoneRetention - const Duration(days: 10)).inMilliseconds;
  }

  Future<bool> isBootstrapped() async => (await db.kvGet('bootstrapped')) == '1';
  Future<void> markBootstrapped() => db.kvSet('bootstrapped', '1');
}
