import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Generates (once) and returns the DB encryption key as 64 hex chars.
class DbKeyStore {
  DbKeyStore([FlutterSecureStorage? storage]) : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;
  static const _k = 'db_key_v1';

  Future<String> getOrCreate() async {
    final existing = await _s.read(key: _k);
    if (existing != null && existing.length == 64) return existing;
    final rnd = Random.secure();
    final key = List.generate(32, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    await _s.write(key: _k, value: key);
    return key;
  }
}
