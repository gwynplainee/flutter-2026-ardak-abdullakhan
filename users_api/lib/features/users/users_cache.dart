import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final dir =
        await getApplicationDocumentsDirectory(); // never a hard-coded path
    return File('${dir.path}${Platform.pathSeparator}users.json');
  }

  Future<void> save(List<User> users) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode([for (final u in users) u.toJson()]));
    } on FileSystemException {
      // failing to remember must not break a good answer
    }
  }

  /// null = nothing saved or the file is unreadable.
  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [for (final m in raw) User.fromJson(m as Map<String, dynamic>)];
    } on FormatException {
      return null; // half-written file
    } on TypeError {
      return null; // file from an older shape of User
    }
  }
}
