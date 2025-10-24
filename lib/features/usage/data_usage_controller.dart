import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/storage/prefs.dart';
import 'data_usage_state.dart';

const _usageKey = 'usage.state';
const _bytesPerSecondEstimate = 256 * 1024; // ~2 Mbps

class DataUsageController extends StateNotifier<DataUsageState> {
  DataUsageController(this._ref) : super(DataUsageState.initial()) {
    _hydrate();
  }

  final Ref _ref;

  Future<void> _hydrate() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final raw = prefs.getString(_usageKey);
    if (raw == null) {
      return;
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      state = DataUsageState.fromJson(data);
      _ensureCurrentPeriod();
    } catch (_) {
      state = DataUsageState.initial();
    }
  }

  Future<void> _persist() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    await prefs.setString(_usageKey, jsonEncode(state.toJson()));
  }

  void _ensureCurrentPeriod() {
    final now = DateTime.now().toUtc();
    final start = state.periodStart;
    if (start.year == now.year && start.month == now.month) {
      return;
    }
    state = DataUsageState(
      periodStart: DateTime.utc(now.year, now.month, 1),
      usedBytes: 0,
      monthlyLimitBytes: state.monthlyLimitBytes,
      lastUpdated: now,
    );
  }

  Future<void> recordTickUsage() async {
    _ensureCurrentPeriod();
    state = state.copyWith(
      usedBytes: state.usedBytes + _bytesPerSecondEstimate,
      lastUpdated: DateTime.now().toUtc(),
    );
    await _persist();
  }

  Future<void> addUsageBytes(int bytes) async {
    _ensureCurrentPeriod();
    state = state.copyWith(
      usedBytes: state.usedBytes + bytes,
      lastUpdated: DateTime.now().toUtc(),
    );
    await _persist();
  }

  Future<void> setMonthlyLimit(int? bytes) async {
    _ensureCurrentPeriod();
    state = state.copyWith(monthlyLimitBytes: bytes);
    await _persist();
  }

  Future<void> resetUsage() async {
    state = DataUsageState(
      periodStart: DateTime.now().toUtc(),
      usedBytes: 0,
      monthlyLimitBytes: state.monthlyLimitBytes,
      lastUpdated: DateTime.now().toUtc(),
    );
    await _persist();
  }
}

final dataUsageControllerProvider =
    StateNotifierProvider<DataUsageController, DataUsageState>((ref) {
  return DataUsageController(ref);
});
