import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_record.dart';
import '../data/connection_history_repository.dart';

class ConnectionHistoryNotifier
    extends StateNotifier<AsyncValue<List<ConnectionRecord>>> {
  ConnectionHistoryNotifier(this._repository)
      : super(_repository == null
            ? const AsyncValue.loading()
            : const AsyncValue.data([])) {
    if (_repository != null) {
      _load();
    }
  }

  final ConnectionHistoryRepository? _repository;

  bool get _ready => _repository != null;

  Future<void> _load() async {
    if (!_ready) return;
    state = const AsyncValue.loading();
    final records = await _repository!.load();
    state = AsyncValue.data(records);
  }

  Future<void> refresh() async => _load();

  Future<void> addRecord(ConnectionRecord record) async {
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

final connectionHistoryProvider = StateNotifierProvider<ConnectionHistoryNotifier,
    AsyncValue<List<ConnectionRecord>>>((ref) {
  return ConnectionHistoryNotifier(ref.watch(connectionHistoryRepositoryProvider));
});
