import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  const SecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } on PlatformException {
      // Android can lose its Keystore key - "not signed in".
      await clear();
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
