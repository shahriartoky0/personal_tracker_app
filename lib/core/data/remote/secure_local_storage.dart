import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists the Supabase session in Keystore/Keychain (not SharedPreferences).
class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage() : _s = const FlutterSecureStorage();
  final FlutterSecureStorage _s;
  static const _k = 'supabase_session';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async => (await _s.read(key: _k)) != null;

  @override
  Future<String?> accessToken() => _s.read(key: _k);

  @override
  Future<void> removePersistedSession() => _s.delete(key: _k);

  @override
  Future<void> persistSession(String persistSessionString) => _s.write(key: _k, value: persistSessionString);
}
