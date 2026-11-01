import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/data/db/database.dart';
import '../../core/data/remote/remote_gateway.dart';
import '../../core/domain/proof.dart';

class ProofException implements Exception {
  ProofException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Capture/compress/store proofs app-privately (never the gallery) and view
/// them online or offline (§13).
class ProofService {
  ProofService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;
  static const _uuid = Uuid();
  static const maxBytes = 4 * 1024 * 1024; // same cap as the web app
  static const _allowedExt = {'.jpg', '.jpeg', '.png', '.webp'};

  Future<Directory> _dir(String name) async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(base.path, name));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<XFile?> pick(ImageSource source) => _picker.pickImage(source: source, requestFullMetadata: false);

  /// Compress (longest side 1600 px, JPEG q80), enforce ≤ 4 MB and type, copy
  /// to app-private storage, and choose the final storage path now.
  Future<PreparedProof> prepare(String userId, XFile picked) async {
    final ext = p.extension(picked.path).toLowerCase();
    if (ext.isNotEmpty && !_allowedExt.contains(ext)) {
      throw ProofException('Only JPEG, PNG or WebP images can be attached.');
    }
    final id = _uuid.v4();
    final dir = await _dir('proofs');
    final target = p.join(dir.path, '$id.jpg');
    final out = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      target,
      quality: 80,
      minWidth: 1600,
      minHeight: 1600,
      format: CompressFormat.jpeg,
    );
    if (out == null) throw ProofException('Could not process that image.');
    final size = await File(out.path).length();
    if (size > maxBytes) {
      await File(out.path).delete();
      throw ProofException('That image is too large (max 4 MB).');
    }
    return PreparedProof(path: '$userId/$id.jpg', localFile: out.path);
  }

  /// Local file → cached download → download now (if online) → null.
  Future<List<int>?> load({
    required String? localFile,
    required String? remotePath,
    required RemoteGateway remote,
  }) async {
    if (localFile != null) {
      final f = File(localFile);
      if (await f.exists()) return f.readAsBytes();
    }
    if (remotePath == null) return null;
    final cacheDir = await _dir('proof_cache');
    final cached = File(p.join(cacheDir.path, remotePath.replaceAll('/', '_')));
    if (await cached.exists()) return cached.readAsBytes();
    if (!await remote.isReachable()) return null;
    try {
      final bytes = await remote.downloadProof(remotePath);
      await cached.writeAsBytes(bytes);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Delete local proof files not referenced by any row/op and older than 24 h.
  Future<void> cleanupOrphans(AppDatabase db) async {
    try {
      final dir = await _dir('proofs');
      final referenced = <String>{};
      final rows = await db.customSelect(
        'SELECT receipt_local_file AS f FROM transactions WHERE receipt_local_file IS NOT NULL',
        variables: const <Variable>[],
      ).get();
      for (final r in rows) {
        referenced.add(r.read<String>('f'));
      }
      final ops = await db.select(db.outbox).get();
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      await for (final e in dir.list()) {
        if (e is! File) continue;
        if (referenced.contains(e.path)) continue;
        if (ops.any((o) => o.payload.contains(p.basename(e.path)))) continue;
        if ((await e.stat()).modified.isAfter(cutoff)) continue;
        await e.delete();
      }
    } catch (_) {}
  }
}
