import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'privacy_policy_content.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicyDialogTitle),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: const [
              PrivacyPolicyContent(),
            ],
          ),
        ),
      ),
    );
  }
}
