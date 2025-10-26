import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../referral/domain/referral_controller.dart';
import '../../referral/domain/referral_state.dart';
import '../../usage/data_usage_controller.dart';
import '../../usage/data_usage_state.dart';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          _buildConnectionSection(context, preferences),
          const SizedBox(height: 24),
          _buildUsageSection(context, usage),
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

  Widget _buildConnectionSection(BuildContext context, PreferencesState preferences) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsConnection,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          context,
          child: Column(
            children: [
              _buildSwitchTile(
                context,
                value: preferences.autoServerSwitch,
                title: l10n.settingsAutoSwitch,
                subtitle: l10n.settingsAutoSwitchSubtitle,
                icon: Icons.auto_mode,
                onChanged: (value) {
                  unawaited(() async {
                    await ref.read(hapticsServiceProvider).selection();
                    await ref
                        .read(preferencesControllerProvider.notifier)
                        .toggleAutoServerSwitch(value);
                  }());
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                  color: theme.colorScheme.outline.withOpacity(0.12),
                  height: 1,
                  thickness: 1,
                ),
              ),
              _buildSwitchTile(
                context,
                value: preferences.hapticsEnabled,
                title: l10n.settingsHaptics,
                subtitle: l10n.settingsHapticsSubtitle,
                icon: Icons.vibration,
                onChanged: (value) {
                  unawaited(() async {
                    await ref.read(hapticsServiceProvider).selection();
                    await ref
                        .read(preferencesControllerProvider.notifier)
                        .toggleHaptics(value);
                  }());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageSection(BuildContext context, DataUsageState usage) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsUsage,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          context,
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DataUsageCard(
              onSetLimit: () => _handleLimitTap(context, usage.monthlyLimitBytes),
              onReset: () => _handleResetUsage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(24)}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required bool value,
    required String title,
    required String subtitle,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.65),
        ),
      ),
      secondary: CircleAvatar(
        radius: 22,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
        foregroundColor: theme.colorScheme.primary,
        child: Icon(icon),
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsBackup,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                    foregroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.cloud_sync_outlined),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${l10n.settingsCreateBackup} / ${l10n.settingsRestore}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.tonal(
                    onPressed: () => unawaited(_createBackup(context)),
                    child: Text(l10n.settingsCreateBackup),
                  ),
                  OutlinedButton(
                    onPressed: () => unawaited(_restoreBackup(context)),
                    child: Text(l10n.settingsRestore),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralSection(BuildContext context, ReferralState referral) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsReferral,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.12),
                    foregroundColor: theme.colorScheme.secondary,
                    child: const Icon(Icons.card_giftcard_outlined),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.settingsReferralSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        referral.referralCode,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      onPressed: () => _showAddReferralDialog(context),
                      child: Text(l10n.settingsAddReferral),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('${l10n.settingsRewards}: ${referral.rewardsEarned}',
                  style: theme.textTheme.bodyMedium),
              if (referral.referredUsers.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: referral.referredUsers
                      .map(
                        (code) => Chip(
                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.12),
                          label: Text(
                            code,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context, PreferencesState preferences) {
    final l10n = context.l10n;
    final locales = AppLocalizations.supportedLocales;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsLanguage,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                    foregroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.language),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.settingsLanguageSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: preferences.localeCode,
                isExpanded: true,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.settingsLanguageSystem),
                  ),
                  ...locales.map((locale) => DropdownMenuItem<String?>(
                        value: locale.languageCode,
                        child: Text(locale.languageCode.toUpperCase()),
                      )),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.colorScheme.primary.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
      ],
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
