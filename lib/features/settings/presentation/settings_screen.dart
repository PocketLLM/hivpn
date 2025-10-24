import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../referral/domain/referral_controller.dart';
import '../../referral/domain/referral_state.dart';
import '../../usage/data_usage_controller.dart';
import '../../usage/presentation/data_usage_card.dart';
import '../domain/preferences_controller.dart';
import '../domain/preferences_state.dart';
import '../../../services/backup/preferences_backup_service.dart';
import '../../../services/haptics/haptics_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _restoreController = TextEditingController();

  @override
  void dispose() {
    _restoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preferences = ref.watch(preferencesControllerProvider);
    final referral = ref.watch(referralControllerProvider);
    final usage = ref.watch(dataUsageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.settingsConnection, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: preferences.autoServerSwitch,
            title: Text(l10n.settingsAutoSwitch),
            subtitle: Text(l10n.settingsAutoSwitchSubtitle),
            onChanged: (value) {
              unawaited(() async {
                await ref.read(hapticsServiceProvider).selection();
                await ref
                    .read(preferencesControllerProvider.notifier)
                    .toggleAutoServerSwitch(value);
              }());
            },
          ),
          SwitchListTile.adaptive(
            value: preferences.hapticsEnabled,
            title: Text(l10n.settingsHaptics),
            subtitle: Text(l10n.settingsHapticsSubtitle),
            onChanged: (value) {
              unawaited(() async {
                await ref.read(hapticsServiceProvider).selection();
                await ref
                    .read(preferencesControllerProvider.notifier)
                    .toggleHaptics(value);
              }());
            },
          ),
          const SizedBox(height: 24),
          DataUsageCard(
            onSetLimit: () => _handleLimitTap(context, usage.monthlyLimitBytes),
            onReset: () => _handleResetUsage(),
          ),
          const SizedBox(height: 24),
          _buildBackupSection(context),
          const SizedBox(height: 24),
          _buildReferralSection(context, referral),
          const SizedBox(height: 24),
          _buildLanguageSection(context, preferences),
        ],
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsBackup,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => unawaited(_createBackup(context)),
                  child: Text(l10n.settingsCreateBackup),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => unawaited(_restoreBackup(context)),
                  child: Text(l10n.settingsRestore),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralSection(BuildContext context, ReferralState referral) {
    final l10n = context.l10n;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsReferral,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l10n.settingsReferralSubtitle,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    referral.referralCode,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _showAddReferralDialog(context),
                  child: Text(l10n.settingsAddReferral),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${l10n.settingsRewards}: ${referral.rewardsEarned}'),
            if (referral.referredUsers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: referral.referredUsers
                    .map((code) => Chip(label: Text(code)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, PreferencesState preferences) {
    final l10n = context.l10n;
    final locales = AppLocalizations.supportedLocales;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsLanguage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l10n.settingsLanguageSubtitle,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            DropdownButton<String?>(
              value: preferences.localeCode,
              items: [
                DropdownMenuItem<String?>
                    (value: null, child: Text(l10n.settingsLanguageSystem)),
                ...locales.map((locale) => DropdownMenuItem<String?>(
                      value: locale.languageCode,
                      child: Text(locale.languageCode.toUpperCase()),
                    )),
              ],
              onChanged: (value) {
                unawaited(() async {
                  await ref.read(hapticsServiceProvider).selection();
                  await ref
                      .read(preferencesControllerProvider.notifier)
                      .setLocale(value);
                }());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    final l10n = context.l10n;
    await ref.read(hapticsServiceProvider).selection();
    final backupService = ref.read(preferencesBackupServiceProvider);
    final backup = await backupService.export();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsCreateBackup),
        content: SelectableText(backup),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.snackbarBackupCopied)));
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final l10n = context.l10n;
    await ref.read(hapticsServiceProvider).selection();
    final backupService = ref.read(preferencesBackupServiceProvider);
    _restoreController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRestore),
        content: TextField(
          controller: _restoreController,
          decoration: const InputDecoration(hintText: 'Paste backup code'),
          minLines: 2,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.settingsRestore),
          ),
        ],
      ),
    );
    if (result == true && _restoreController.text.trim().isNotEmpty) {
      try {
        await backupService.restore(_restoreController.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.snackbarRestoreComplete)));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.snackbarRestoreFailed)));
      }
    }
  }

  Future<void> _showAddReferralDialog(BuildContext context) async {
    final l10n = context.l10n;
    await ref.read(hapticsServiceProvider).selection();
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsAddReferral),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Friend code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await ref.read(referralControllerProvider.notifier).addReferral(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.snackbarReferralAdded)));
    }
  }

  Future<void> _showLimitDialog(BuildContext context, int? currentLimit) async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: currentLimit != null
          ? (currentLimit / (1024 * 1024 * 1024)).toStringAsFixed(2)
          : '',
    );
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsUsageLimit),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'GB'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    if (result != null) {
      final trimmed = result.trim();
      int? bytes;
      if (trimmed.isNotEmpty) {
        final parsed = double.tryParse(trimmed);
        if (parsed != null && parsed > 0) {
          bytes = (parsed * 1024 * 1024 * 1024).round();
        }
      }
      await ref
          .read(dataUsageControllerProvider.notifier)
          .setMonthlyLimit(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.snackbarLimitSaved)));
    }
  }

  Future<void> _handleLimitTap(BuildContext context, int? currentLimit) async {
    await ref.read(hapticsServiceProvider).selection();
    await _showLimitDialog(context, currentLimit);
  }

  Future<void> _handleResetUsage() async {
    await ref.read(hapticsServiceProvider).selection();
    await ref.read(dataUsageControllerProvider.notifier).resetUsage();
  }
}
