import 'dart:async';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/utils/time.dart';
import '../../features/connection/presentation/connection_quality_indicator.dart';
import '../../services/storage/prefs.dart';
import '../../services/haptics/haptics_service.dart';
import '../../theme/colors.dart';
import '../../theme/theme.dart';
import '../../widgets/home_status_widget.dart';
import '../../widgets/connect_control.dart';
import '../../widgets/status_pill.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/presentation/spotlight_controller.dart';
import '../onboarding/presentation/spotlight_tour.dart';
import '../servers/domain/server.dart';
import '../servers/domain/server_providers.dart';
import '../servers/presentation/server_picker_sheet.dart';
import '../session/domain/session_controller.dart';
import '../session/domain/session_state.dart';
import '../session/domain/session_status.dart';
import '../session/presentation/countdown.dart';
import '../speedtest/domain/speedtest_controller.dart';
import '../speedtest/presentation/speedtest_screen.dart';
import '../usage/data_usage_controller.dart';
import '../usage/data_usage_state.dart';
import '../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _serverCarouselKey = GlobalKey();
  final GlobalKey _connectKey = GlobalKey();
  final GlobalKey _statusKey = GlobalKey();
  final GlobalKey _speedTabKey = GlobalKey();
  SpotlightController? _spotlightController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowSpotlight();
      ref
          .read(sessionControllerProvider.notifier)
          .autoConnectIfEnabled(context: context);
    });
    ref.listen<SessionState>(sessionControllerProvider, _onSessionChanged);
  }

  @override
  void dispose() {
    _spotlightController?.dispose();
    super.dispose();
  }

  Future<void> _maybeShowSpotlight() async {
    final prefs = await ref.read(prefsStoreProvider.future);
    if (prefs.getBool('tour_done')) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final l10n = context.l10n;
    final steps = _buildSpotlightSteps(l10n);
    _spotlightController = SpotlightController(
      targets: steps.map((step) => step.toTarget()).toList(),
    );
    await _spotlightController?.show(
      context: context,
      onFinish: () => _completeTour(prefs),
      onSkip: () => _completeTour(prefs),
    );
  }

  void _completeTour(PrefsStore prefs) {
    prefs.setBool('tour_done', true);
  }

  List<SpotlightStep> _buildSpotlightSteps(AppLocalizations l10n) {
    return [
      SpotlightStep(
        key: _serverCarouselKey,
        text: l10n.tutorialChooseLocation,
        align: ContentAlign.top,
      ),
      SpotlightStep(
        key: _connectKey,
        text: l10n.tutorialWatchAd,
        align: ContentAlign.bottom,
      ),
      SpotlightStep(
        key: _statusKey,
        text: l10n.tutorialSession,
        align: ContentAlign.bottom,
      ),
      SpotlightStep(
        key: _speedTabKey,
        text: l10n.tutorialSpeed,
        align: ContentAlign.top,
      ),
    ];
  }

  void _onSessionChanged(SessionState? previous, SessionState next) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (next.status == SessionStatus.error && next.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(next.errorMessage!)),
      );
    }
    if (next.extendRequested && !(previous?.extendRequested ?? false)) {
      unawaited(
        ref.read(sessionControllerProvider.notifier).extendSession(context),
      );
    }
    if (previous?.status == SessionStatus.connected &&
        next.status == SessionStatus.disconnected) {
      if (next.expired) {
        _showSessionExpiredDialog();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(context.l10n.disconnectedWatchAd),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _buildHomeTab(context, l10n),
                  const SpeedTestScreen(),
                  const HistoryScreen(),
                  const SettingsScreen(),
                ],
              ),
            ),
            _buildNavigationBar(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, AppLocalizations l10n) {
    final session = ref.watch(sessionControllerProvider);
    final countdown = ref.watch(sessionCountdownProvider).maybeWhen(
          data: formatCountdown,
          orElse: () => session.meta != null
              ? formatCountdown(session.meta!.duration)
              : '60:00',
        );
    final catalog = ref.watch(serverCatalogProvider);
    final selectedServer = ref.watch(selectedServerProvider);
    final serversAsyncValue = ref.watch(serversAsync);
    final speedState = ref.watch(speedTestControllerProvider);
    final usageState = ref.watch(dataUsageControllerProvider);
    final theme = Theme.of(context);
    final servers = catalog.sortedServers;

    final statusLabel = _statusLabel(session.status, countdown, l10n);
    final statusColor = _statusColor(session.status);

    final isBusy = session.status == SessionStatus.preparing ||
        session.status == SessionStatus.connecting;
    final isConnected = session.status == SessionStatus.connected;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: HomeStatusWidget()),
              IconButton(
                onPressed: () => _openSettings(context),
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.settingsTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ConnectionQualityIndicator(),
          const SizedBox(height: 16),
          _buildUsageSummary(context, usageState),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: KeyedSubtree(
              key: _statusKey,
              child: StatusPill(
                label: statusLabel,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            selectedServer?.name ?? l10n.selectServerToBegin,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            selectedServer != null
                ? '${_flagEmoji(selectedServer.countryCode)}  ${selectedServer.countryCode.toUpperCase()}'
                : l10n.noServerSelected,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isConnected ? l10n.sessionRemaining : l10n.unlockSecureAccess,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          const SessionCountdown(),
          const SizedBox(height: 24),
          KeyedSubtree(
            key: _connectKey,
            child: ConnectControl(
              enabled: !isBusy,
              isActive: isConnected,
              isLoading: isBusy,
              label: isConnected ? l10n.disconnect : l10n.connect,
              statusText: isConnected ? countdown : l10n.watchAdToStart,
              onTap: () async {
                await ref.read(hapticsServiceProvider).impact();
                if (isConnected) {
                  await ref.read(sessionControllerProvider.notifier).disconnect();
                } else {
                  final server = selectedServer;
                  if (server == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseSelectServer)),
                    );
                    return;
                  }
                  await ref
                      .read(sessionControllerProvider.notifier)
                      .connect(context: context, server: server);
                }
              },
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.locations,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    unawaited(_showServerPicker(context));
                  },
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          KeyedSubtree(
            key: _serverCarouselKey,
            child: serversAsyncValue.when(
              data: (servers) => SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: servers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final server = servers[index];
                    final selected = selectedServer?.id == server.id;
                    final latency = catalog.latencyMs[server.id];
                    return _ServerCard(
                      server: server,
                      selected: selected,
                      connected: isConnected && selected,
                      onTap: isConnected
                          ? null
                          : () {
                              unawaited(
                                  ref.read(hapticsServiceProvider).selection());
                              ref
                                  .read(selectedServerProvider.notifier)
                                  .select(server);
                            },
                      latency: latency,
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, __) => Text('${l10n.failedToLoadServers}: $error'),
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoFooter(
            context,
            l10n: l10n,
            ip: speedState.ip ?? '--',
            remaining: countdown,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              unawaited(ref.read(hapticsServiceProvider).selection());
              _showLegalDialog(context);
            },
            child: Text(l10n.termsPrivacy),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFooter(BuildContext context,
      {required AppLocalizations l10n,
      required String ip,
      required String remaining}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.elevatedSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.currentIp, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(ip, style: theme.textTheme.titleMedium),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.sessionLabel, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(remaining, style: theme.textTheme.titleMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              unawaited(ref.read(hapticsServiceProvider).selection());
              setState(() => _tabIndex = 1);
            },
            child: Row(
              children: [
                Icon(Icons.speed, color: theme.colorScheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.runSpeedTest,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.elevatedSurface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: _NavigationItem(
                icon: Icons.shield_moon_outlined,
                label: l10n.navHome,
                selected: _tabIndex == 0,
                onTap: () {
                  unawaited(ref.read(hapticsServiceProvider).selection());
                  setState(() => _tabIndex = 0);
                },
              ),
            ),
            Expanded(
              child: KeyedSubtree(
                key: _speedTabKey,
                child: _NavigationItem(
                  icon: Icons.speed,
                  label: l10n.navSpeedTest,
                  selected: _tabIndex == 1,
                  onTap: () {
                    unawaited(ref.read(hapticsServiceProvider).selection());
                    setState(() => _tabIndex = 1);
                  },
                ),
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.history,
                label: 'History',
                selected: _tabIndex == 2,
                onTap: () => setState(() => _tabIndex = 2),
              ),
            ),
            Expanded(
              child: _NavigationItem(
                icon: Icons.tune,
                label: 'Settings',
                selected: _tabIndex == 3,
                onTap: () => setState(() => _tabIndex = 3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.connected:
        return HiVpnColors.success;
      case SessionStatus.connecting:
      case SessionStatus.preparing:
        return HiVpnColors.info;
      case SessionStatus.error:
        return HiVpnColors.error;
      case SessionStatus.disconnected:
      default:
        return Colors.white54;
    }
  }

  String _statusLabel(SessionStatus status, String countdown, AppLocalizations l10n) {
    switch (status) {
      case SessionStatus.connected:
        return l10n.connectedCountdownLabel(countdown);
      case SessionStatus.connecting:
        return l10n.statusConnecting;
      case SessionStatus.preparing:
        return l10n.statusPreparing;
      case SessionStatus.error:
        return l10n.statusError;
      case SessionStatus.disconnected:
      default:
        return l10n.statusDisconnected;
    }
  }

  Future<void> _showServerPicker(BuildContext context) async {
    await ref.read(hapticsServiceProvider).selection();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SizedBox(
        height: 440,
        child: ServerPickerSheet(),
      ),
    );
  }

  void _showLegalDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.legalTitle),
        content: Text(context.l10n.legalBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  void _showSessionExpiredDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.sessionExpiredTitle),
        content: Text(context.l10n.sessionExpiredBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    await ref.read(hapticsServiceProvider).selection();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Widget _buildUsageSummary(BuildContext context, DataUsageState usage) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final usedGb = usage.usedBytes / (1024 * 1024 * 1024);
    final limitGb = usage.monthlyLimitBytes != null
        ? usage.monthlyLimitBytes! / (1024 * 1024 * 1024)
        : null;
    final progress = usage.hasLimit ? usage.utilization.clamp(0, 1).toDouble() : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.elevatedSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsUsage,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.usageSummaryText(usedGb, limitGb),
            style: theme.textTheme.bodyMedium,
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
          ],
        ],
      ),
    );
  }

  String _flagEmoji(String countryCode) {
    final base = 0x1F1E6;
    return countryCode.toUpperCase().characters.map((char) {
      final codeUnit = char.codeUnitAt(0) - 0x41 + base;
      return String.fromCharCode(codeUnit);
    }).join();
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  const _ServerCard({
    required this.server,
    required this.selected,
    required this.connected,
    this.onTap,
    this.latency,
  });

  final Server server;
  final bool selected;
  final bool connected;
  final VoidCallback? onTap;
  final int? latency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cardColor = theme.pastelCard(
      selected ? theme.colorScheme.secondary : theme.colorScheme.primaryContainer,
      opacity: selected ? 0.22 : 0.12,
    );
    final statusLabel = connected
        ? l10n.badgeConnected
        : selected
            ? l10n.badgeSelected
            : l10n.badgeConnect;
    final statusColor = connected
        ? HiVpnColors.success
        : theme.colorScheme.onSurface.withOpacity(0.85);
    final latencyText = latency != null ? '${latency!} ms' : '--';

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurface.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _flagEmoji(server.countryCode),
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              server.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.latencyLabel}: $latencyText',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _flagEmoji(String countryCode) {
    final base = 0x1F1E6;
    return countryCode.toUpperCase().characters.map((char) {
      final codeUnit = char.codeUnitAt(0) - 0x41 + base;
      return String.fromCharCode(codeUnit);
    }).join();
  }
}
