import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh); // remember the last good answer
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow; // nothing to show
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetch() async {
    final response = await _api.get(Uri.https(_api.host, '/users'));
    final json = _api.decode(response);
    return _parse(
      'users',
      () => (json as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<User> getById(int id) async {
    final response = await _api.get(Uri.https(_api.host, '/users/$id'));
    return _parseUser('users/$id', response);
  }

  Future<User> create(User draft) async {
    // The server assigns the id, so we do not send ours.
    final body = draft.toJson()..remove('id');
    final response = await _api.post(
      Uri.https(_api.host, '/users'),
      jsonEncode(body),
    );
    if (response.statusCode != 201) {
      throw BadResponseException(
        'POST users: expected 201, got ${response.statusCode}',
      );
    }
    return _parseUser('POST users', response);
  }

  User _parseUser(String what, http.Response response) {
    final json = _api.decode(response);
    return _parse(what, () => User.fromJson(json as Map<String, dynamic>));
  }

  /// A cast that throws inside fromJson becomes our own exception.
  T _parse<T>(String what, T Function() build) {
    try {
      return build();
    } on TypeError catch (e) {
      throw BadResponseException('$what: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$what: $e');
    }
  }
}
