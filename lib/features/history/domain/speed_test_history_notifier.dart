import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/speed_test_history_repository.dart';
import 'speed_test_record.dart';

class SpeedTestHistoryNotifier
    extends StateNotifier<AsyncValue<List<SpeedTestRecord>>> {
  SpeedTestHistoryNotifier(this._repository)
      : super(_repository == null
            ? const AsyncValue.loading()
            : const AsyncValue.data([])) {
    if (_repository != null) {
      _load();
    }
  }

  final SpeedTestHistoryRepository? _repository;

  bool get _ready => _repository != null;

  Future<void> _load() async {
    if (!_ready) return;
    state = const AsyncValue.loading();
    final records = await _repository!.load();
    state = AsyncValue.data(records);
  }

  Future<void> refresh() async => _load();

  Future<void> addRecord(SpeedTestRecord record) async {
    if (!_ready) return;
    await _repository!.addRecord(record);
    await _load();
  }

  Future<void> clear() async {
    if (!_ready) return;
    await _repository!.clear();
    state = const AsyncValue.data([]);
  }
}

final speedTestHistoryProvider =
    StateNotifierProvider<SpeedTestHistoryNotifier, AsyncValue<List<SpeedTestRecord>>>(
        (ref) {
  return SpeedTestHistoryNotifier(ref.watch(speedTestHistoryRepositoryProvider));
});
