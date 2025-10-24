import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage/prefs.dart';
import 'preferences_state.dart';

const _prefsKey = 'settings.preferences';

class PreferencesController extends StateNotifier<PreferencesState> {
  PreferencesController(this._ref) : super(const PreferencesState()) {
    _hydrate();
  }

  final Ref _ref;

  Future<void> _hydrate() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      return;
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      state = PreferencesState.fromJson(data);
    } catch (_) {
      // ignore corrupt preferences
    }
  }

  Future<void> _persist() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
  }

  Future<void> toggleAutoServerSwitch(bool enabled) async {
    state = state.copyWith(autoServerSwitch: enabled);
    await _persist();
  }

  Future<void> toggleHaptics(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    await _persist();
  }

  Future<void> setLocale(String? code) async {
    state = state.copyWith(localeCode: code);
    await _persist();
  }
}

final preferencesControllerProvider =
    StateNotifierProvider<PreferencesController, PreferencesState>((ref) {
  return PreferencesController(ref);
});
