import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsStore {
  PrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<PrefsStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsStore(prefs);
  }

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) => _prefs.remove(key);

  Map<String, Object?> exportAll() {
    final keys = _prefs.getKeys();
    final data = <String, Object?>{};
    for (final key in keys) {
      data[key] = _prefs.get(key);
    }
    return data;
  }

  Future<void> restoreAll(Map<String, Object?> data) async {
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is bool) {
        await _prefs.setBool(entry.key, value);
      } else if (value is int) {
        await _prefs.setInt(entry.key, value);
      } else if (value is double) {
        await _prefs.setDouble(entry.key, value);
      } else if (value is String) {
        await _prefs.setString(entry.key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(entry.key, value);
      }
    }
  }
}

final prefsStoreProvider = FutureProvider<PrefsStore>((ref) async {
  return PrefsStore.create();
});
