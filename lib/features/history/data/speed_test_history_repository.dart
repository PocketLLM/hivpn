import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage/prefs.dart';
import '../domain/speed_test_record.dart';

class SpeedTestHistoryRepository {
  SpeedTestHistoryRepository(this._prefs);

  final PrefsStore _prefs;

  static const _historyKey = 'speedtest_history';

  Future<List<SpeedTestRecord>> load() async {
    final jsonString = _prefs.getString(_historyKey);
    if (jsonString == null) {
      return const [];
    }
    try {
      final decoded = json.decode(jsonString) as List<dynamic>;
      return decoded
          .map((e) => SpeedTestRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<SpeedTestRecord> history) async {
    final encoded = json.encode(history.map((e) => e.toJson()).toList());
    await _prefs.setString(_historyKey, encoded);
  }

  Future<void> addRecord(SpeedTestRecord record) async {
    final history = await load();
    final updated = [record, ...history];
    await save(updated.take(200).toList());
  }

  Future<void> clear() => _prefs.remove(_historyKey);
}

final speedTestHistoryRepositoryProvider =
    Provider<SpeedTestHistoryRepository?>((ref) {
  final prefsAsync = ref.watch(prefsStoreProvider);
  return prefsAsync.whenOrNull(
    data: SpeedTestHistoryRepository.new,
  );
});
