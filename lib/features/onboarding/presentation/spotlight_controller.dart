import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../l10n/app_localizations.dart';

class SpotlightController {
  SpotlightController({required this.targets});

  final List<TargetFocus> targets;
  TutorialCoachMark? _coachMark;

  void show({
    required BuildContext context,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) {
    final l10n = context.l10n;
    _coachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black87,
      textSkip: l10n.tutorialSkip,
      onSkip: () {
        onSkip?.call();
        return true;
      },
      onFinish: () => onFinish?.call(),
    );
    final coachMark = _coachMark;
    coachMark?.show(context: context);
  }

  void dispose() {
    _coachMark?.finish();
    _coachMark = null;
  }
}
