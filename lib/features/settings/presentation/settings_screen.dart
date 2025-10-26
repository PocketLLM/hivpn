import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../referral/domain/referral_controller.dart';
import '../../referral/domain/referral_state.dart';
import '../../usage/data_usage_controller.dart';
import '../../usage/data_usage_state.dart';
import '../domain/preferences_controller.dart';
import '../domain/preferences_state.dart';
import '../../../services/haptics/haptics_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preferences = ref.watch(preferencesControllerProvider);
    final referral = ref.watch(referralControllerProvider);
    final usage = ref.watch(dataUsageControllerProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 160),
      children: [
        Text(
          l10n.settingsTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        _buildConnectionSection(context, preferences),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        _buildUsageSection(context, usage),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        _buildReferralSection(context, referral),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        _buildLanguageSection(context, preferences),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildConnectionSection(BuildContext context, PreferencesState preferences) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, l10n.settingsConnection),
        const SizedBox(height: 12),
        _buildSwitchTile(
          context,
          value: preferences.autoServerSwitch,
          title: l10n.settingsAutoSwitch,
          subtitle: l10n.settingsAutoSwitchSubtitle,
          icon: Icons.auto_mode,
          onChanged: (value) {
            unawaited(() async {
              await ref.read(hapticsServiceProvider).selection();
              await ref.read(preferencesControllerProvider.notifier).toggleAutoServerSwitch(value);
            }());
          },
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
              await ref.read(preferencesControllerProvider.notifier).toggleHaptics(value);
            }());
          },
        ),
      ],
    );
  }

  Widget _buildUsageSection(BuildContext context, DataUsageState usage) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final usedGb = usage.usedBytes / (1024 * 1024 * 1024);
    final limitGb = usage.monthlyLimitBytes != null
        ? usage.monthlyLimitBytes! / (1024 * 1024 * 1024)
        : null;
    final summary = l10n.usageSummaryText(usedGb, limitGb);
    final progress = usage.hasLimit ? usage.utilization.clamp(0, 1).toDouble() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, l10n.settingsUsage),
        const SizedBox(height: 12),
        Text(
          l10n.settingsUsageSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress ?? 0,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          summary,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonal(
              onPressed: () => _handleLimitTap(context, usage.monthlyLimitBytes),
              child: Text(usage.hasLimit ? l10n.settingsUsageLimit : l10n.settingsSetLimit),
            ),
            OutlinedButton(
              onPressed: _handleResetUsage,
              child: Text(l10n.settingsResetUsage),
            ),
            if (usage.limitExceeded)
              Chip(
                backgroundColor: theme.colorScheme.error.withOpacity(0.12),
                label: Text(
                  '${((progress ?? 1) * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildReferralSection(BuildContext context, ReferralState referral) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, l10n.settingsReferral),
        const SizedBox(height: 12),
        Text(
          l10n.settingsReferralSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        SelectableText(
          referral.referralCode,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonal(
              onPressed: () => _showAddReferralDialog(context),
              child: Text(l10n.settingsAddReferral),
            ),
            Text(
              '${l10n.settingsRewards}: ${referral.rewardsEarned}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        if (referral.referredUsers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: referral.referredUsers
                .map(
                  (code) => Chip(
                    label: Text(code),
                  ),
                )
                .toList(),
          ),
        ],
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
        _buildSectionTitle(context, l10n.settingsLanguage),
        const SizedBox(height: 12),
        Text(
          l10n.settingsLanguageSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          value: preferences.localeCode,
          isExpanded: true,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n.settingsLanguageSystem),
            ),
            ...locales.map(
              (locale) => DropdownMenuItem<String?>(
                value: locale.languageCode,
                child: Text(locale.languageCode.toUpperCase()),
              ),
            ),
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            unawaited(() async {
              await ref.read(hapticsServiceProvider).selection();
              await ref.read(preferencesControllerProvider.notifier).setLocale(value);
            }());
          },
        ),
      ],
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
      contentPadding: EdgeInsets.zero,
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
      secondary: Icon(icon, color: theme.colorScheme.primary),
    );
  }

  Future<void> _showAddReferralDialog(BuildContext context) async {
    final l10n = context.l10n;
    await ref.read(hapticsServiceProvider).selection();
    final controller = TextEditingController();
    try {
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
    } finally {
      controller.dispose();
    }
  }

  Future<_LimitDialogResult?> _showLimitDialog(BuildContext context, int? currentLimit) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(
      text: currentLimit != null
          ? (currentLimit / (1024 * 1024 * 1024)).toStringAsFixed(2)
          : '',
    );
    try {
      final result = await showDialog<_LimitDialogResult?>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.settingsUsageLimit),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'GB',
                helperText: 'Enter monthly data limit in gigabytes.',
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Please enter a value greater than 0';
                }
                final parsed = double.tryParse(trimmed);
                if (parsed == null || parsed <= 0) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
          ),
          actions: [
            if (currentLimit != null)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(const _LimitDialogResult.clear()),
                child: Text(l10n.settingsRemoveLimit),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final parsed = double.parse(controller.text.trim());
                  final bytes = (parsed * 1024 * 1024 * 1024).round();
                  Navigator.of(ctx).pop(_LimitDialogResult(bytes));
                }
              },
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return result;
    } finally {
      controller.dispose();
    }
  }

  Future<void> _handleLimitTap(BuildContext context, int? currentLimit) async {
    await ref.read(hapticsServiceProvider).selection();
    final result = await _showLimitDialog(context, currentLimit);
    if (!mounted || result == null) {
      return;
    }
    final notifier = ref.read(dataUsageControllerProvider.notifier);
    if (result.clear) {
      await notifier.setMonthlyLimit(null);
    } else if (result.limitBytes != null) {
      await notifier.setMonthlyLimit(result.limitBytes);
    }
    if (!mounted) return;
    final l10n = context.l10n;
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.snackbarLimitSaved)));
    }
  }

  Future<void> _handleResetUsage() async {
    await ref.read(hapticsServiceProvider).selection();
    await ref.read(dataUsageControllerProvider.notifier).resetUsage();
  }
}

class _LimitDialogResult {
  const _LimitDialogResult(this.limitBytes) : clear = false;
  const _LimitDialogResult.clear()
      : limitBytes = null,
        clear = true;

  final int? limitBytes;
  final bool clear;
}
