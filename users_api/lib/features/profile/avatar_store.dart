import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarStore {
  AvatarStore(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _key = 'avatarPath';
  static const _fileName = 'avatar.jpg';

  Future<File> _target() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }

  /// Copy the picked file into Documents and remember it.
  Future<File> save(XFile picked) async {
    final target = await _target();
    await File(picked.path).copy(target.path);
    await _prefs.setString(_key, _fileName);
    return target;
  }

  /// null = no photo yet (or the file is gone).
  Future<File?> load() async {
    final name = await _prefs.getString(_key);
    if (name == null) return null;
    final file = await _target();
    return await file.exists() ? file : null;
  }
}
