import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.privacyPolicySummaryTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.privacyPolicySummaryBody,
              style: textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _Section(
          title: '1. ${l10n.privacyPolicySectionWhoWeAreTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionWhoWeAreBody,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        _Section(
          title: '2. ${l10n.privacyPolicySectionDataTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionDataIntro,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionDataLocal,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _BulletList(items: l10n.privacyPolicySectionDataLocalItems),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionDataMLab,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _BulletList(items: l10n.privacyPolicySectionDataMLabItems),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionDataOptional,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _BulletList(items: l10n.privacyPolicySectionDataOptionalItems),
          ],
        ),
        _Section(
          title: '3. ${l10n.privacyPolicySectionPurposeTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionPurposeIntro,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            _BulletList(items: l10n.privacyPolicySectionPurposeItems),
          ],
        ),
        _Section(
          title: '4. ${l10n.privacyPolicySectionPermissionsTitle}',
          children: [
            _BulletList(items: l10n.privacyPolicySectionPermissionsItems),
          ],
        ),
        _Section(
          title: '5. ${l10n.privacyPolicySectionSharingTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionSharingIntro,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionSharingMLab,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacyPolicySectionSharingMLabBody,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionSharingVendors,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacyPolicySectionSharingVendorsBody,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        _Section(
          title: '6. ${l10n.privacyPolicySectionTransfersTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionTransfersBody,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        _Section(
          title: '7. ${l10n.privacyPolicySectionRetentionTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionRetentionBody,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        _Section(
          title: '8. ${l10n.privacyPolicySectionRightsTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionRightsIntro,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionRightsGlobal,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _BulletList(items: l10n.privacyPolicySectionRightsGlobalItems),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionRightsGDPR,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacyPolicySectionRightsGDPRBody,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionRightsIndia,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacyPolicySectionRightsIndiaBody,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionRightsCalifornia,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacyPolicySectionRightsCaliforniaBody,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.privacyPolicySectionRightsChildren,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacyPolicySectionRightsChildrenBody,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        _Section(
          title: '9. ${l10n.privacyPolicySectionSecurityTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionSecurityBody,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        _Section(
          title: '10. ${l10n.privacyPolicySectionContactTitle}',
          children: [
            Text(
              l10n.privacyPolicySectionContactBody,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.privacyPolicyFooter,
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(
                  child: Text(
                    item,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

extension on AppLocalizations {
  List<String> get privacyPolicySectionDataLocalItems => [
        privacyPolicySectionDataLocalItem1,
        privacyPolicySectionDataLocalItem2,
        privacyPolicySectionDataLocalItem3,
      ];

  List<String> get privacyPolicySectionDataMLabItems => [
        privacyPolicySectionDataMLabItem1,
        privacyPolicySectionDataMLabItem2,
        privacyPolicySectionDataMLabItem3,
        privacyPolicySectionDataMLabItem4,
      ];

  List<String> get privacyPolicySectionDataOptionalItems => [
        privacyPolicySectionDataOptionalItem1,
        privacyPolicySectionDataOptionalItem2,
      ];

  List<String> get privacyPolicySectionPurposeItems => [
        privacyPolicySectionPurposeItem1,
        privacyPolicySectionPurposeItem2,
        privacyPolicySectionPurposeItem3,
        privacyPolicySectionPurposeItem4,
      ];

  List<String> get privacyPolicySectionPermissionsItems => [
        privacyPolicySectionPermissionsItem1,
        privacyPolicySectionPermissionsItem2,
        privacyPolicySectionPermissionsItem3,
      ];

  List<String> get privacyPolicySectionRightsGlobalItems => [
        privacyPolicySectionRightsGlobalItem1,
        privacyPolicySectionRightsGlobalItem2,
        privacyPolicySectionRightsGlobalItem3,
        privacyPolicySectionRightsGlobalItem4,
        privacyPolicySectionRightsGlobalItem5,
      ];
}
