import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// Appends ops to the outbox with coalescing (§7). Must be called INSIDE the
/// same Drift transaction that writes the local row.
class OutboxService {
  OutboxService(this.db, {int Function()? nowMs}) : _now = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);
  final AppDatabase db;
  final int Function() _now;

  Future<void> enqueueUpsert(
    String entity,
    String entityId,
    Map<String, dynamic> payload, {
    String? baseUpdatedAt,
  }) async {
    final existing = await (db.select(db.outbox)
          ..where((o) =>
              o.entity.equals(entity) &
              o.entityId.equals(entityId) &
              o.op.equals('upsert') &
              o.status.isIn(const ['pending', 'failed', 'blocked'])))
        .get();
    if (existing.isNotEmpty) {
      // Replace the payload of the latest pending upsert; keep its position.
      final keep = existing.last;
      await (db.update(db.outbox)..where((o) => o.seq.equals(keep.seq))).write(OutboxCompanion(
        payload: Value(jsonEncode(payload)),
        status: const Value('pending'),
        attempts: const Value(0),
        nextAttemptAtMs: const Value(0),
        lastError: const Value(null),
      ));
      return;
    }
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          entity: entity,
          entityId: entityId,
          op: 'upsert',
          payload: jsonEncode(payload),
          baseUpdatedAt: Value(baseUpdatedAt),
          createdAtMs: _now(),
        ));
  }

  /// One op containing several rows that must land atomically (own-account
  /// transfer legs). [entityId] is the group id.
  Future<void> enqueueBatchUpsert(
    String entity,
    String groupId,
    List<Map<String, dynamic>> rows,
  ) async {
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          entity: entity,
          entityId: groupId,
          op: 'upsert_batch',
          payload: jsonEncode(rows),
          createdAtMs: _now(),
        ));
  }

  /// Queue a proof upload. Must be enqueued BEFORE the transaction upsert so
  /// the web app never sees a receipt_path that doesn't exist yet.
  Future<void> enqueueProofUpload(String txId, String path, String localFile) async {
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          entity: 'transactions',
          entityId: txId,
          op: 'upload_proof',
          payload: jsonEncode({'path': path, 'localFile': localFile}),
          createdAtMs: _now(),
        ));
  }

  /// Queue removal of an object. If its upload is still queued, cancel both.
  /// Returns true when the object was never uploaded (local file can go).
  Future<bool> enqueueProofDelete(String txId, String path) async {
    final uploads = await (db.select(db.outbox)
          ..where((o) => o.op.equals('upload_proof') & o.status.isNotValue('in_flight')))
        .get();
    final mine = uploads.where((o) => (jsonDecode(o.payload) as Map)['path'] == path).toList();
    if (mine.isNotEmpty) {
      for (final u in mine) {
        await (db.delete(db.outbox)..where((o) => o.seq.equals(u.seq))).go();
      }
      return true;
    }
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          entity: 'transactions',
          entityId: txId,
          op: 'delete_proof',
          payload: jsonEncode({'path': path}),
          createdAtMs: _now(),
        ));
    return false;
  }

  /// [neverSynced]: the local row has never reached the server (remote
  /// updated_at is null), so nothing needs to be sent.
  Future<void> enqueueDelete(String entity, String entityId, {required bool neverSynced}) async {
    // Drop queued (not in-flight) upserts for this entity.
    await (db.delete(db.outbox)
          ..where((o) =>
              o.entity.equals(entity) &
              o.entityId.equals(entityId) &
              o.op.equals('upsert') &
              o.status.isNotValue('in_flight')))
        .go();
    if (neverSynced) {
      final inFlight = await (db.select(db.outbox)
            ..where((o) => o.entity.equals(entity) & o.entityId.equals(entityId) & o.status.equals('in_flight')))
          .get();
      if (inFlight.isEmpty) return; // nothing ever reached the server
    }
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          entity: entity,
          entityId: entityId,
          op: 'delete',
          payload: '{}',
          createdAtMs: _now(),
        ));
  }

  Future<bool> hasPendingOps(String entity, String entityId) async {
    final rows = await (db.select(db.outbox)
          ..where((o) => o.entity.equals(entity) & o.entityId.equals(entityId))
          ..limit(1))
        .get();
    return rows.isNotEmpty;
  }

  Stream<int> watchPendingCount() {
    final q = db.selectOnly(db.outbox)..addColumns([db.outbox.seq.count()]);
    return q.watchSingle().map((r) => r.read(db.outbox.seq.count()) ?? 0);
  }

  Stream<int> watchAttentionCount() {
    final c = db.outbox.seq.count();
    final q = db.selectOnly(db.outbox)
      ..addColumns([c])
      ..where(db.outbox.status.isIn(const ['failed', 'blocked']));
    return q.watchSingle().map((r) => r.read(c) ?? 0);
  }

  Stream<List<OutboxRow>> watchAll() =>
      (db.select(db.outbox)..orderBy([(o) => OrderingTerm.asc(o.seq)])).watch();
}
