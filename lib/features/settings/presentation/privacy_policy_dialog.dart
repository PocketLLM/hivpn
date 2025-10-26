import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'privacy_policy_content.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  final ScrollController _controller = ScrollController();
  bool _hasReachedEnd = false;
  bool _isChecked = false;
  String? _helperMessage;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    final threshold = 24.0;
    final atBottom = position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent - threshold;
    if (atBottom && !_hasReachedEnd) {
      setState(() {
        _hasReachedEnd = true;
        _helperMessage = context.l10n.privacyPolicyCheckboxReady;
      });
    }
  }

  void _handleCheckboxChanged(bool? value) {
    if (!_hasReachedEnd) {
      setState(() {
        _helperMessage = context.l10n.privacyPolicyScrollWarning;
      });
      return;
    }
    setState(() {
      _isChecked = value ?? false;
      _helperMessage = null;
    });
  }

  void _handleContinue() {
    final l10n = context.l10n;
    if (!_hasReachedEnd) {
      setState(() {
        _helperMessage = l10n.privacyPolicyScrollWarning;
      });
      return;
    }
    if (!_isChecked) {
      setState(() {
        _helperMessage = l10n.privacyPolicyAgreementRequired;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final dialogHeight = media.size.height * 0.65;
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text(l10n.privacyPolicyDialogTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: dialogHeight,
                child: Scrollbar(
                  controller: _controller,
                  thumbVisibility: true,
                  child: ListView(
                    controller: _controller,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: const [
                      PrivacyPolicyContent(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _isChecked,
                onChanged: _handleCheckboxChanged,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.privacyPolicyCheckboxLabel),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.privacyPolicyAvailableInSettings,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              if (_helperMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _helperMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _helperMessage = l10n.privacyPolicyScrollHint;
              });
            },
            child: Text(l10n.privacyPolicyScrollHintAction),
          ),
          FilledButton(
            onPressed: _handleContinue,
            child: Text(l10n.privacyPolicyAgreeButton),
          ),
        ],
      ),
    );
  }
}
