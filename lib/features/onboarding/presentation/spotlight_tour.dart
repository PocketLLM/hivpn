import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class SpotlightStep {
  SpotlightStep({required this.key, required this.text, this.align});

  final GlobalKey key;
  final String text;
  final ContentAlign? align;

  TargetFocus toTarget() {
    return TargetFocus(
      identify: key.toString(),
      keyTarget: key,
      contents: [
        TargetContent(
          align: align ?? ContentAlign.bottom,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
