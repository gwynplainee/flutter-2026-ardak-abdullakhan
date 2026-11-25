import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<http.Response> get(Uri uri) async {
    final response = await _send(() => _client.get(uri, headers: _headers));
    _log(response);
    _check(response);
    return response;
  }

  Future<http.Response> post(Uri uri, String jsonBody) async {
    final response = await _send(
      () => _client.post(
        uri,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonBody,
      ),
    );
    _log(response);
    _check(response);
    return response;
  }

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

  void _log(http.Response r) {
    if (kDebugMode) {
      log(
        '${r.request?.method} ${r.request?.url} -> ${r.statusCode}',
        name: 'api',
      );
    }
  }
}
