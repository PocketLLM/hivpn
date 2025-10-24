import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/domain/preferences_controller.dart';

class HapticsService {
  HapticsService(this._ref);

  final Ref _ref;

  Future<void> impact() async {
    final enabled = _ref.read(
      preferencesControllerProvider.select((state) => state.hapticsEnabled),
    );
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> selection() async {
    final enabled = _ref.read(
      preferencesControllerProvider.select((state) => state.hapticsEnabled),
    );
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }
}

final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsService(ref);
});
