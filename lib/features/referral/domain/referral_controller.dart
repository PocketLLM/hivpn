import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage/prefs.dart';
import 'referral_state.dart';

const _referralKey = 'referral.state';

class ReferralController extends StateNotifier<ReferralState> {
  ReferralController(this._ref) : super(_initialState()) {
    _hydrate();
  }

  final Ref _ref;
  final _random = Random();

  static ReferralState _initialState() {
    return ReferralState(referralCode: _generateCode(Random()));
  }

  static String _generateCode(Random random) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List<String>.generate(8, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> _hydrate() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    final raw = prefs.getString(_referralKey);
    if (raw == null) {
      final state = ReferralState(referralCode: _generateCode(_random));
      this.state = state;
      await prefs.setString(_referralKey, jsonEncode(state.toJson()));
      return;
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      state = ReferralState.fromJson(data);
      if (state.referralCode.isEmpty) {
        state = state.copyWith(referralCode: _generateCode(_random));
      }
    } catch (_) {
      state = ReferralState(referralCode: _generateCode(_random));
    }
  }

  Future<void> _persist() async {
    final prefs = await _ref.read(prefsStoreProvider.future);
    await prefs.setString(_referralKey, jsonEncode(state.toJson()));
  }

  Future<void> addReferral(String friendCode) async {
    if (state.referredUsers.contains(friendCode)) {
      return;
    }
    state = state.copyWith(
      referredUsers: [...state.referredUsers, friendCode],
      rewardsEarned: state.rewardsEarned + 1,
    );
    await _persist();
  }

  Future<void> resetRewards() async {
    state = state.copyWith(rewardsEarned: 0, referredUsers: const []);
    await _persist();
  }
}

final referralControllerProvider =
    StateNotifierProvider<ReferralController, ReferralState>((ref) {
  return ReferralController(ref);
});
