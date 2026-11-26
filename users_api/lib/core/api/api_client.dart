import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  /// The real client for the app.
  factory ApiClient.real(SecureStore store) => ApiClient(http.Client(), store);

  final http.Client _client;
  final SecureStore _store;
  final String host;

  //The token is added here and nowhere else.
  Future<Map<String, String>> _headers() async => {
    'Accept': 'application/json',
    if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
  };

  Future<http.Response> get(Uri uri) async {
    final headers = await _headers();
    final response = await _send(() => _client.get(uri, headers: headers));
    _log(response);
    _check(response); // status first, body second
    return response;
  }

  Future<http.Response> post(Uri uri, String jsonBody) async {
    final headers = await _headers();
    final response = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonBody,
      ),
    );
    _log(response);
    _check(response);
    return response;
  }

  /// FormatException -> BadResponseException.
  dynamic decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('invalid JSON: ${e.message}');
    }
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    final code = r.statusCode;
    if (code == 401) throw const UnauthorizedException();
    if (code == 404) throw const NotFoundException();
    if (code >= 500) throw ServerException(code);
    if (code < 200 || code >= 300) throw BadResponseException('HTTP $code');
  }

  // Method, URL and status only.
  void _log(http.Response r) {
    if (kDebugMode) {
      log(
        '${r.request?.method} ${r.request?.url} -> ${r.statusCode}',
        name: 'api',
      );
    }
  }
}
