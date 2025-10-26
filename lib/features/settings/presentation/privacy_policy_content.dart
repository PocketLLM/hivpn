import 'package:flutter/material.dart';

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final titleStyle = textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    final sectionTitleStyle =
        textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final bodyStyle = textTheme.bodyMedium;
    final captionStyle = textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );

    Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(text, style: titleStyle),
        );

    Widget section(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: sectionTitleStyle),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        );

    Widget paragraph(String text) => Text(text, style: bodyStyle);

    Widget bulletList(List<String> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('•'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item, style: bodyStyle)),
                  ],
                ),
              ),
          ],
        );

    Widget summaryBox(String text) => DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(text, style: bodyStyle),
          ),
        );

    Widget quote(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: summaryBox(text),
        );

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Privacy Policy'),
          quote(
            'Summary: HiVPN runs internet speed tests using Measurement Lab (M-Lab) servers. '
            'When you run a test, we send network performance data and your IP address to '
            'M-Lab, who publishes this data as part of their public research dataset. We do '
            'not require accounts or collect persistent identifiers beyond what is needed for the test.',
          ),
          section('1. Who we are and what this policy covers', [
            paragraph(
              'This Privacy Policy describes how HiVPN Labs ("we", "us", or "our") collects, '
              'uses, and shares information when you use the HiVPN mobile application ('
              '"the App"). The App is a network diagnostic tool that runs internet speed '
              'tests using Measurement Lab (M-Lab)\'s ndt7 service. The App is available on '
              'Android and iOS platforms, with potential future expansion to web and desktop environments.',
            ),
          ]),
          section('2. What data the App processes', [
            paragraph(
              'The App processes certain data locally on your device and transmits specific '
              'measurements to M-Lab when you choose to run a test.',
            ),
            const SizedBox(height: 12),
            Text('Local App Data', style: sectionTitleStyle),
            const SizedBox(height: 8),
            bulletList([
              'Network performance metrics (throughput, latency, packet loss) calculated in real-time.',
              'Temporary counters of bytes transferred for UI progress indicators.',
              'Test duration and status information. This local data is not persisted by default and is cleared when the test completes or you close the App.',
            ]),
            const SizedBox(height: 12),
            Text('Data Sent to M-Lab', style: sectionTitleStyle),
            const SizedBox(height: 8),
            bulletList([
              'Your public IP address.',
              'Network performance measurements (throughput, RTT, loss rate).',
              'Connection metadata (server location, test timestamps).',
              'WebSocket protocol metadata.',
              'Important: M-Lab publishes all test data as part of their public research datasets. '
                  'This means your IP address and test results will be publicly available and cannot be recalled once submitted.',
            ]),
          ]),
          section('3. Our purposes for processing', [
            bulletList([
              'Provide and operate the speed testing service.',
              'Display network performance metrics to you.',
              'Connect to the nearest available M-Lab server for accurate testing.',
              'Troubleshoot and improve the App\'s performance.',
              'Legal basis: Processing is based on your consent when you initiate a speed test. '
                  'You can withdraw consent by not running additional tests.',
            ]),
          ]),
          section('4. Device permissions', [
            bulletList([
              'Network access: Essential for running speed tests and connecting to M-Lab servers.',
              'Wi-Fi information (optional): Used locally to display basic Wi-Fi network details.',
            ]),
            paragraph(
              'The App does not collect device identifiers (such as advertising IDs) or other '
              'persistent identifiers that could be used to track you across services.',
            ),
          ]),
          section('5. Data sharing', [
            Text('With M-Lab', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'We share your test data with Measurement Lab (M-Lab) to perform the speed test. '
              'M-Lab\'s privacy policy governs their use of this data, including their practice '
              'of publishing test results in public research datasets.',
            ),
            const SizedBox(height: 16),
            Text('With Service Providers', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'If we use service providers for anonymized error reports or crash analytics, '
              'they are contractually obligated to protect this information. We do not sell or '
              'rent your personal information to third parties for marketing purposes.',
            ),
          ]),
          section('6. International transfers', [
            paragraph(
              'M-Lab is a global platform with servers in multiple countries. When you run a '
              'test, your data may be transferred to and processed in countries outside your region. '
              'For transfers from the EEA, UK, or Switzerland, we rely on Standard Contractual '
              'Clauses to ensure adequate protection.',
            ),
          ]),
          section('7. Data retention', [
            Text('App-Side Data', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'The App retains minimal local logs for troubleshooting only. These logs are '
              'automatically cleared after 7 days unless you configure the App to retain them longer.',
            ),
            const SizedBox(height: 16),
            Text('M-Lab Data', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'M-Lab retains and publishes test data according to their own policies. Once '
              'test data is contributed to M-Lab\'s public datasets, it becomes permanently available.',
            ),
          ]),
          section('8. User controls and rights', [
            Text('Your Rights', style: sectionTitleStyle),
            const SizedBox(height: 8),
            bulletList([
              'Access: Request a copy of personal data we hold about you.',
              'Deletion: Request deletion of app-side logs (M-Lab data cannot be recalled).',
              'Rectification: Request correction of inaccurate personal data.',
              'Portability: Request a machine-readable copy of your data.',
              'Objection: Object to processing based on legitimate interests.',
              'Restriction: Request limitation of processing.',
            ]),
            const SizedBox(height: 16),
            Text('GDPR (EEA, UK)', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'Processing is based on your consent (Article 6(1)(a) GDPR). Contact privacy@hivpn.app '
              'to exercise your rights or lodge a complaint with your local authority.',
            ),
            const SizedBox(height: 16),
            Text('India DPDP 2023', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'Processing is based on your consent. You may withdraw consent, request correction '
              'or deletion of your data, and nominate an individual to exercise rights on your behalf '
              'in case of death or incapacity. Contact grievance@hivpn.app for grievances.',
            ),
            const SizedBox(height: 16),
            Text('California (CCPA/CPRA)', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'California residents may request to know what personal information we collect, '
              'request deletion (excluding M-Lab\'s published test data), and opt out of the sale '
              'or sharing of personal information. Contact privacy@hivpn.app or visit '
              'hivpn.app/privacy-requests.',
            ),
            const SizedBox(height: 16),
            Text('Children\'s Data', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'The App is not directed to children under 13. We do not knowingly collect personal '
              'information from children. Parents or guardians may contact us to delete such data.',
            ),
          ]),
          section('9. Security practices', [
            paragraph(
              'We implement appropriate technical and organizational measures to protect your data: '
              'all communications with M-Lab use TLS encryption, locate API tokens are handled securely, '
              'and no secrets are hard-coded in the App. We regularly review and update our security practices.',
            ),
          ]),
          section('10. Contact information', [
            paragraph(
              'If you have questions about this Privacy Policy or our data practices, contact us at '
              'privacy@hivpn.app or by mail at HiVPN Labs, 221B Network Lane, Singapore. '
              'For India-specific inquiries, contact grievance@hivpn.app.',
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              'This Privacy Policy was last updated on April 1, 2024. References: '
              'M-Lab Privacy Policy (https://www.measurementlab.net/privacy/) and '
              'M-Lab Locate API v2 (https://www.measurementlab.net/develop/locate-v2/).',
              style: captionStyle,
            ),
          ),
          heading('Terms of Service'),
          quote(
            'Summary: This app provides internet speed tests using M-Lab servers. By using the app, '
            'you agree to M-Lab policies and understand that results are estimates. The app is '
            'provided "as is" without warranties.',
          ),
          section('1. Acceptance of terms', [
            paragraph(
              'By downloading, installing, or using the HiVPN mobile application, you agree to be '
              'bound by these Terms of Service. If you do not agree, do not use the App. HiVPN Labs '
              'may update these Terms at any time and will notify you of material changes through '
              'updated effective dates or in-app notifications.',
            ),
          ]),
          section('2. Who can use the App', [
            paragraph(
              'The App is available to users who are at least 13 years old. By using the App, you '
              'represent that you have the legal capacity to enter into these Terms.',
            ),
          ]),
          section('3. Description of the service', [
            bulletList([
              'Connects to the nearest available M-Lab server.',
              'Measures download and upload throughput, latency, and packet loss.',
              'Displays server-computed metrics including MeanThroughputMbps, MinRTT, and LossRate.',
            ]),
            const SizedBox(height: 12),
            paragraph(
              'Results may vary depending on device capabilities, network conditions, server load, '
              'and other factors. The App may stop a test early if performance stabilizes. The 250 MB '
              'data cap mentioned by M-Lab applies only to their Google Search integration and is not '
              'a universal limit.',
            ),
          ]),
          section('4. Acceptable use', [
            bulletList([
              'Do not use the App for automated testing or benchmarking without permission.',
              'Do not reverse engineer, decompile, or disassemble the App.',
              'Do not interfere with or disrupt the App, servers, or networks connected to the App.',
              'Do not use the App in a manner that could damage or impair the App or M-Lab\'s services.',
            ]),
            paragraph(
              'You must comply with M-Lab\'s Acceptable Use Policy when using their platform.',
            ),
          ]),
          section('5. Third-party services', [
            paragraph(
              'When you run a test, you are subject to M-Lab\'s Privacy Policy and Acceptable Use '
              'Policy. M-Lab servers collect and publish test data, including your IP address, as '
              'part of public research datasets.',
            ),
          ]),
          section('6. Disclaimers', [
            Text('Measurement Estimates', style: sectionTitleStyle),
            const SizedBox(height: 8),
            bulletList([
              'Device capabilities and configuration.',
              'Network congestion.',
              'Background applications and services.',
              'Server location and load.',
              'Wi-Fi signal strength (if applicable).',
            ]),
            const SizedBox(height: 16),
            Text('No Warranty', style: sectionTitleStyle),
            const SizedBox(height: 8),
            paragraph(
              'The App is provided "as is" without warranties of any kind, either express or '
              'implied. HiVPN Labs disclaims all warranties, including implied warranties of '
              'merchantability, fitness for a particular purpose, and non-infringement. We do '
              'not guarantee that the App will be uninterrupted, timely, secure, or error-free.',
            ),
          ]),
          section('7. Limitation of liability', [
            paragraph(
              'To the fullest extent permitted by law, HiVPN Labs shall not be liable for any '
              'indirect, incidental, special, consequential, or punitive damages, including loss '
              'of profits, data, or other intangible losses, resulting from your use of the App. '
              'Our total liability for any claims related to the App shall not exceed USD 100.',
            ),
          ]),
          section('8. Changes to the App or terms', [
            paragraph(
              'We may modify, suspend, or discontinue the App at any time. We may also update '
              'these Terms from time to time. Continued use after changes constitutes acceptance of the updated Terms.',
            ),
          ]),
          section('9. Termination', [
            paragraph(
              'We may terminate or suspend your access to the App immediately, without prior notice, '
              'for conduct that violates these Terms or is harmful to other users, us, or third parties. '
              'Upon termination, your right to use the App ceases immediately.',
            ),
          ]),
          section('10. Governing law and venue', [
            paragraph(
              'These Terms are governed by the laws of Singapore, without regard to conflict of '
              'law principles. Any legal action arising under these Terms will be subject to the '
              'exclusive jurisdiction of the courts located in Singapore.',
            ),
          ]),
          section('11. Contact information', [
            paragraph(
              'If you have questions about these Terms, contact support@hivpn.app or mail '
              'HiVPN Labs, 221B Network Lane, Singapore.',
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'These Terms of Service were last updated on April 1, 2024.',
              style: captionStyle,
            ),
          ),
        ],
      ),
    );
  }
}
