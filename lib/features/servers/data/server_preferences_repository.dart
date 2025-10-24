import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage/prefs.dart';

class ServerPreferencesRepository {
  ServerPreferencesRepository(this._prefs);

  final PrefsStore _prefs;

  static const _favoritesKey = 'server_favorites';
  static const _lastServerKey = 'server_last_selected';

  Set<String> loadFavorites() {
    final raw = _prefs.getString(_favoritesKey);
    if (raw == null) return <String>{};
    try {
      final decoded = (json.decode(raw) as List<dynamic>)
          .map((e) => e as String)
          .toSet();
      return decoded;
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    final encoded = json.encode(favorites.toList());
    await _prefs.setString(_favoritesKey, encoded);
  }

  String? loadLastServerId() => _prefs.getString(_lastServerKey);

  Future<void> saveLastServerId(String id) =>
      _prefs.setString(_lastServerKey, id);
}

final serverPreferencesRepositoryProvider =
    Provider<ServerPreferencesRepository?>((ref) {
  final prefsAsync = ref.watch(prefsStoreProvider);
  return prefsAsync.whenOrNull(data: ServerPreferencesRepository.new);
});
