import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../logging/app_log.dart';
import '../db/database.dart';
import 'remote_failure.dart';

// Loaded from the git-ignored .env file (see .env.example).
String get supabaseUrl => dotenv.maybeGet('SUPABASE_URL') ?? '';
String get supabaseAnonKey => dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

/// Thin abstraction over Supabase so the sync engine can be driven by a fake.
abstract class RemoteGateway {
  Future<bool> isReachable();

  /// Upsert one row; returns server `updated_at`.
  Future<String?> upsert(String entity, Map<String, dynamic> row, String onConflict);

  /// Upsert several rows atomically (single request); returns updated_at per id.
  Future<Map<String, String?>> upsertBatch(String entity, List<Map<String, dynamic>> rows, String onConflict);

  Future<void> delete(String entity, String id);

  /// Keyset page ordered by (updated_at, id) after the cursor.
  Future<List<Map<String, dynamic>>> pullPage(
    String entity, {
    String? updatedAt,
    String? lastId,
    int limit = 1000,
  });

  Future<List<Map<String, dynamic>>> pullTombstones({String? deletedAt, int? lastId, int limit = 1000});

  Future<Map<String, dynamic>?> fetchByColumn(String entity, String column, Object value);

  Future<Map<String, dynamic>?> fetchAppConfig();

  /// Case-insensitive payee lookup (unique resolver).
  Future<Map<String, dynamic>?> fetchPayeeByName(String name);

  /// Refresh auth session. false => cannot refresh (offline or revoked).
  Future<bool> refreshSession();

  /// Uploads a proof to the private `receipts` bucket. "Already exists" is success.
  Future<void> uploadProof(String path, String localFile, String contentType);

  /// Best-effort removal of a proof object (missing object is fine).
  Future<void> deleteProof(String path);

  /// Downloads proof bytes (online viewing; caller caches them app-private).
  Future<List<int>> downloadProof(String path);
}

class SupabaseGateway implements RemoteGateway {
  SupabaseGateway(this.client);
  final SupabaseClient client;

  @override
  Future<bool> isReachable() async {
    if (supabaseUrl.isEmpty) return false;
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    try {
      final req = await http.getUrl(Uri.parse('$supabaseUrl/auth/v1/health'));
      final res = await req.close().timeout(const Duration(seconds: 4));
      await res.drain<void>();
      AppLog.line('http.probe', 'GET $supabaseUrl/auth/v1/health → ${res.statusCode}');
      return res.statusCode < 500;
    } catch (e) {
      AppLog.line('http.probe', 'GET $supabaseUrl/auth/v1/health ✗ $e');
      return false;
    } finally {
      http.close(force: true);
    }
  }

  @override
  Future<String?> upsert(String entity, Map<String, dynamic> row, String onConflict) async {
    try {
      final res = await client.from(entity).upsert(row, onConflict: onConflict).select('updated_at');
      return res.isEmpty ? null : res.first['updated_at'] as String?;
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<Map<String, String?>> upsertBatch(
      String entity, List<Map<String, dynamic>> rows, String onConflict) async {
    try {
      final res = await client.from(entity).upsert(rows, onConflict: onConflict).select('id,updated_at');
      return {for (final r in res) r['id'] as String: r['updated_at'] as String?};
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<void> delete(String entity, String id) async {
    try {
      await client.from(entity).delete().eq('id', id); // 0 rows == already gone
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> pullPage(String entity,
      {String? updatedAt, String? lastId, int limit = 1000}) async {
    try {
      var q = client.from(entity).select();
      if (updatedAt != null) {
        q = lastId == null
            ? q.gt('updated_at', updatedAt)
            : q.or('updated_at.gt.$updatedAt,and(updated_at.eq.$updatedAt,id.gt.$lastId)');
      }
      final res = await q.order('updated_at').order('id').limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> pullTombstones({String? deletedAt, int? lastId, int limit = 1000}) async {
    try {
      var q = client.from('sync_tombstones').select();
      if (deletedAt != null) {
        q = lastId == null
            ? q.gt('deleted_at', deletedAt)
            : q.or('deleted_at.gt.$deletedAt,and(deleted_at.eq.$deletedAt,id.gt.$lastId)');
      }
      final res = await q.order('deleted_at').order('id').limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchByColumn(String entity, String column, Object value) async {
    try {
      return await client.from(entity).select().eq(column, value).maybeSingle();
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchPayeeByName(String name) async {
    try {
      final escaped = name.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
      return await client.from('payees').select().ilike('name', escaped).maybeSingle();
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchAppConfig() async {
    try {
      return await client.from('app_config').select().maybeSingle();
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<bool> refreshSession() async {
    try {
      await client.auth.refreshSession();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> uploadProof(String path, String localFile, String contentType) async {
    final file = File(localFile);
    if (!await file.exists()) {
      throw RemoteFailure(FailureKind.permanent, 'Proof file is missing on this device.', code: 'missing_file');
    }
    try {
      await client.storage
          .from('receipts')
          .upload(path, file, fileOptions: FileOptions(contentType: contentType, upsert: false));
    } on StorageException catch (e) {
      final dup = e.statusCode == '409' || e.message.toLowerCase().contains('already exists');
      if (dup) return; // a previous attempt succeeded
      throw classifyError(e);
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<void> deleteProof(String path) async {
    try {
      await client.storage.from('receipts').remove([path]);
    } catch (e) {
      throw classifyError(e);
    }
  }

  @override
  Future<List<int>> downloadProof(String path) async {
    try {
      return await client.storage.from('receipts').download(path);
    } catch (e) {
      throw classifyError(e);
    }
  }
}

/// Local helper for dumping pending ops as JSON (export before discard).
Future<String> exportOutboxJson(AppDatabase db) async {
  final rows = await db.select(db.outbox).get();
  return const JsonEncoder.withIndent('  ').convert([
    for (final r in rows)
      {
        'seq': r.seq,
        'entity': r.entity,
        'entityId': r.entityId,
        'op': r.op,
        'status': r.status,
        'payload': jsonDecode(r.payload),
        'error': r.lastError,
      }
  ]);
}
