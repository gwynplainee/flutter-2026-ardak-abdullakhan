import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class LoginFailed implements Exception {
  const LoginFailed();
}

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {required bool signedIn}) : _signedIn = signedIn;

  final SecureStore _store;
  bool _signedIn;

  bool get signedIn => _signedIn;

  /// any password of 8+ characters works, after one second.
  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) throw const LoginFailed();

    await _store.saveToken('tok_${email.hashCode}');
    _signedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _signedIn = false;
    notifyListeners();
  }
}
