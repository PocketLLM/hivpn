import 'dart:async';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/utils/time.dart';
import '../../features/connection/domain/connection_quality_controller.dart';
import '../../services/storage/prefs.dart';
import '../../services/haptics/haptics_service.dart';
import '../../theme/colors.dart';
import '../../widgets/connect_control.dart';
import '../../widgets/status_pill.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/presentation/spotlight_controller.dart';
import '../onboarding/presentation/spotlight_tour.dart';
import '../history/presentation/history_screen.dart';
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
  bool _didSchedulePostFrameCallback = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSchedulePostFrameCallback) {
      return;
    }
    _didSchedulePostFrameCallback = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeShowSpotlight();
      ref
          .read(sessionControllerProvider.notifier)
          .autoConnectIfEnabled(context: context);
    });
  }

  @override
  void dispose() {
    _spotlightController?.dispose();
    super.dispose();
  }

  Future<void> _maybeShowSpotlight() async {
    if (!mounted) return;
    final prefs = await ref.read(prefsStoreProvider.future);
    if (prefs.getBool('tour_done')) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final l10n = context.l10n;
    final steps = _buildSpotlightSteps(l10n);
    _spotlightController = SpotlightController(
      targets: steps.map((step) => step.toTarget()).toList(),
    );
    _spotlightController?.show(
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
    ref.listen<SessionState>(sessionControllerProvider, _onSessionChanged);
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
                  HistoryScreen(),
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
    final qualityState = ref.watch(connectionQualityControllerProvider);
    final theme = Theme.of(context);
    final servers = catalog.sortedServers;

    final statusLabel = _statusLabel(session.status, countdown, l10n);
    final statusColor = _statusColor(session.status);
    final qualityLabel = l10n.connectionQualityLabel(qualityState.quality);

    final usedGb = usageState.usedBytes / (1024 * 1024 * 1024);
    final limitGb = usageState.monthlyLimitBytes != null
        ? usageState.monthlyLimitBytes! / (1024 * 1024 * 1024)
        : null;
    final usageText = l10n.usageSummaryText(usedGb, limitGb);
    final ip = speedState.ip ?? '--';
    final downloadValue = speedState.downloadMbps > 0 ? speedState.downloadMbps : null;
    final uploadValue = speedState.uploadMbps > 0 ? speedState.uploadMbps : null;

    final isBusy = session.status == SessionStatus.preparing ||
        session.status == SessionStatus.connecting;
    final isConnected = session.status == SessionStatus.connected;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.unlockSecureAccess,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: _openSettings,
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.settingsTitle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildOverviewCard(
            context,
            l10n: l10n,
            statusLabel: statusLabel,
            statusColor: statusColor,
            qualityLabel: qualityLabel,
            usageText: usageText,
            ip: ip,
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text(
                  selectedServer?.name ?? l10n.selectServerToBegin,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  selectedServer != null
                      ? '${_flagEmoji(selectedServer.countryCode)}  ${selectedServer.countryCode.toUpperCase()}'
                      : l10n.noServerSelected,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
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
                const SizedBox(height: 20),
                Text(
                  isConnected ? l10n.sessionRemaining : l10n.unlockSecureAccess,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                const SessionCountdown(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
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
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(l10n.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _serverCarouselKey,
            child: serversAsyncValue.when(
              data: (servers) => SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: servers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
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
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, __) => Text('${l10n.failedToLoadServers}: $error'),
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoFooter(
            context,
            l10n: l10n,
            ip: ip,
            remaining: countdown,
            download: downloadValue,
            upload: uploadValue,
            ping: speedState.ping,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                unawaited(ref.read(hapticsServiceProvider).selection());
                _showLegalDialog(context);
              },
              child: Text(l10n.termsPrivacy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context,
      {required AppLocalizations l10n,
      required String statusLabel,
      required Color statusColor,
      required String qualityLabel,
      required String usageText,
      required String ip}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.18),
            theme.colorScheme.secondary.withOpacity(0.12),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.14),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              KeyedSubtree(
                key: _statusKey,
                child: StatusPill(
                  label: statusLabel,
                  color: statusColor,
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.65),
                foregroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.shield_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            statusLabel,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeWidgetQualitySummary(qualityLabel),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _InfoBadge(
                icon: Icons.signal_cellular_alt,
                label: l10n.connectionQualityTitle,
                value: qualityLabel,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.22),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              _InfoBadge(
                icon: Icons.storage_rounded,
                label: l10n.settingsUsage,
                value: usageText,
              ),
              _InfoBadge(
                icon: Icons.language,
                label: l10n.currentIp,
                value: ip,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFooter(BuildContext context,
      {required AppLocalizations l10n,
      required String ip,
      required String remaining,
      required double? download,
      required double? upload,
      required Duration? ping}) {
    final theme = Theme.of(context);
    final downloadText = download != null ? '${download.toStringAsFixed(1)} Mbps' : '--';
    final uploadText = upload != null ? '${upload.toStringAsFixed(1)} Mbps' : '--';
    final pingText = ping != null ? '${ping.inMilliseconds} ms' : '--';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.06),
            blurRadius: 34,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _InfoBadge(
                icon: Icons.language,
                label: l10n.currentIp,
                value: ip,
              ),
              _InfoBadge(
                icon: Icons.timer_outlined,
                label: l10n.sessionLabel,
                value: remaining,
              ),
              _InfoBadge(
                icon: Icons.download_rounded,
                label: 'Download',
                value: downloadText,
              ),
              _InfoBadge(
                icon: Icons.upload_rounded,
                label: 'Upload',
                value: uploadText,
              ),
              _InfoBadge(
                icon: Icons.podcasts,
                label: 'Ping',
                value: pingText,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              unawaited(ref.read(hapticsServiceProvider).selection());
              setState(() => _tabIndex = 1);
            },
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              foregroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.speed),
            ),
            title: Text(
              l10n.navSpeedTest,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              l10n.runSpeedTest,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            _NavigationItem(
              icon: Icons.shield_outlined,
              label: l10n.navHome,
              selected: _tabIndex == 0,
              onTap: () {
                unawaited(ref.read(hapticsServiceProvider).selection());
                setState(() => _tabIndex = 0);
              },
            ),
            KeyedSubtree(
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
            _NavigationItem(
              icon: Icons.history,
              label: 'History',
              selected: _tabIndex == 2,
              onTap: () {
                setState(() => _tabIndex = 2);
              },
            ),
            _NavigationItem(
              icon: Icons.tune,
              label: 'Settings',
              selected: _tabIndex == 3,
              onTap: () {
                setState(() => _tabIndex = 3);
              },
            ),
          ].map((item) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: item))).toList(),
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

  Future<void> _openSettings() async {
    await ref.read(hapticsServiceProvider).selection();
    if (!mounted) return;
    setState(() => _tabIndex = 3);
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
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.28),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.25)
                    : theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
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
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: selected
          ? [
              theme.colorScheme.primary.withOpacity(0.22),
              theme.colorScheme.secondary.withOpacity(0.16),
              Colors.white,
            ]
          : [
              theme.colorScheme.primary.withOpacity(0.08),
              Colors.white,
            ],
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.45)
                : theme.colorScheme.outline.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? theme.colorScheme.primary.withOpacity(0.22)
                  : theme.colorScheme.primary.withOpacity(0.08),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _flagEmoji(server.countryCode),
                  style: const TextStyle(fontSize: 30),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    latencyText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
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

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
    this.gradient,
  });

  final IconData icon;
  final String label;
  final String value;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? theme.colorScheme.surface : null,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.05),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
