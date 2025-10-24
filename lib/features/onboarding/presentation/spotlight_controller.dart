import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class SpotlightController {
  SpotlightController({required this.targets});

  final List<TargetFocus> targets;
  TutorialCoachMark? _coachMark;

  Future<void> show(
    BuildContext context, {
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) async {
    _coachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black87,
      textSkip: 'Skip',
      onSkip: () => onSkip?.call(),
      onFinish: () => onFinish?.call(),
    );
    await _coachMark?.show(context: context);
  }

  void dispose() {
    _coachMark?.finish();
    _coachMark = null;
  }
}
