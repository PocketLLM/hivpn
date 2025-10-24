import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';

class PreferencesBackupService {
  PreferencesBackupService(this._ref);

  final Ref _ref;

  Future<String> export() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final snapshot = prefs.exportAll();
    final encoded = jsonEncode(snapshot);
    return base64Encode(utf8.encode(encoded));
  }

  Future<void> restore(String backup) async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final decoded = utf8.decode(base64Decode(backup.trim()));
    final data = jsonDecode(decoded) as Map<String, dynamic>;
    await prefs.restoreAll(data);
  }
}

final preferencesBackupServiceProvider = Provider<PreferencesBackupService>((ref) {
  return PreferencesBackupService(ref);
});
