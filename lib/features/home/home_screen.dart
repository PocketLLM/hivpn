import 'dart:async';
import 'dart:ui';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/utils/time.dart';
import '../../features/connection/domain/connection_quality_controller.dart';
import '../../services/storage/prefs.dart';
import '../../services/haptics/haptics_service.dart';
import '../../theme/colors.dart';
import '../../widgets/connect_control.dart';
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

    final qualityLabel = l10n.connectionQualityLabel(qualityState.quality);

    final usedGb = usageState.usedBytes / (1024 * 1024 * 1024);
    final limitGb = usageState.monthlyLimitBytes != null
        ? usageState.monthlyLimitBytes! / (1024 * 1024 * 1024)
        : null;
    final usageText = l10n.usageSummaryText(usedGb, limitGb);
    final ip = speedState.ip ?? '--';
    final downloadText = speedState.downloadMbps > 0
        ? '${speedState.downloadMbps.toStringAsFixed(1)} Mbps'
        : '--';
    final uploadText = speedState.uploadMbps > 0
        ? '${speedState.uploadMbps.toStringAsFixed(1)} Mbps'
        : '--';
    final pingText = speedState.ping != null ? '${speedState.ping!.inMilliseconds} ms' : '--';
    final statusBadgeLabel = _statusBadgeLabel(session.status, l10n);
    final statusBadgeColor = _statusDotColor(session.status);
    final titleBaseStyle = theme.textTheme.headlineSmall ?? const TextStyle(fontSize: 24);
    final titleStyle = GoogleFonts.poppins(
      textStyle: titleBaseStyle.copyWith(fontWeight: FontWeight.w700),
    );

    final isBusy = session.status == SessionStatus.preparing ||
        session.status == SessionStatus.connecting;
    final isConnected = session.status == SessionStatus.connected;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'hi',
                            style: titleStyle.copyWith(color: theme.colorScheme.onSurface),
                          ),
                          TextSpan(
                            text: 'VPN',
                            style: titleStyle.copyWith(color: HiVpnColors.accent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    KeyedSubtree(
                      key: _statusKey,
                      child: _ConnectionStatusBadge(
                        label: statusBadgeLabel,
                        color: statusBadgeColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: l10n.settingsTitle,
                    ),
                  ],
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
          const SizedBox(height: 28),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
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
                  padding: EdgeInsets.zero,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeWidgetTitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _InfoRow(label: l10n.connectionQualityTitle, value: qualityLabel),
                const SizedBox(height: 12),
                _InfoRow(label: l10n.settingsUsage, value: usageText),
                const SizedBox(height: 12),
                _InfoRow(label: l10n.currentIp, value: ip),
                const SizedBox(height: 12),
                _InfoRow(label: l10n.sessionRemaining, value: countdown),
                const SizedBox(height: 12),
                _InfoRow(label: 'Download', value: downloadText),
                const SizedBox(height: 12),
                _InfoRow(label: 'Upload', value: uploadText),
                const SizedBox(height: 12),
                _InfoRow(label: 'Ping', value: pingText),
              ],
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _buildNavigationBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surface.withOpacity(0.45);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            color: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavigationItem(
                  icon: Icons.shield_outlined,
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
                    selected: _tabIndex == 1,
                    onTap: () {
                      unawaited(ref.read(hapticsServiceProvider).selection());
                      setState(() => _tabIndex = 1);
                    },
                  ),
                ),
                _NavigationItem(
                  icon: Icons.history,
                  selected: _tabIndex == 2,
                  onTap: () {
                    setState(() => _tabIndex = 2);
                  },
                ),
                _NavigationItem(
                  icon: Icons.tune,
                  selected: _tabIndex == 3,
                  onTap: () {
                    setState(() => _tabIndex = 3);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusBadgeLabel(SessionStatus status, AppLocalizations l10n) {
    switch (status) {
      case SessionStatus.connected:
        return l10n.statusConnected;
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

  Color _statusDotColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.connected:
        return HiVpnColors.success;
      case SessionStatus.connecting:
      case SessionStatus.preparing:
        return HiVpnColors.warning;
      case SessionStatus.error:
        return HiVpnColors.error;
      case SessionStatus.disconnected:
      default:
        return HiVpnColors.error;
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
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.6);
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 26),
      splashRadius: 22,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
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

class _ConnectionStatusBadge extends StatelessWidget {
  const _ConnectionStatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
