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
}

final prefsStoreProvider = FutureProvider<PrefsStore>((ref) async {
  return PrefsStore.create();
});
