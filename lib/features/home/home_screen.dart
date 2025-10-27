import 'dart:async';
import 'package:characters/characters.dart';
import 'dart:ui';

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
import '../settings/domain/preferences_controller.dart';
import '../settings/presentation/privacy_policy_consent_page.dart';
import '../settings/presentation/settings_screen.dart';
import '../network/data/ip_info_repository.dart';

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
      unawaited(_handleAppLaunchFlow());
    });
  }

  @override
  void dispose() {
    _spotlightController?.dispose();
    super.dispose();
  }

  Future<void> _handleAppLaunchFlow() async {
    final accepted = await _ensurePrivacyPolicyAccepted();
    if (!mounted || !accepted) {
      return;
    }
    await _maybeShowSpotlight();
    if (!mounted) {
      return;
    }
    unawaited(
      ref.read(sessionControllerProvider.notifier).autoConnectIfEnabled(
            context: context,
          ),
    );
  }

  Future<bool> _ensurePrivacyPolicyAccepted() async {
    final notifier = ref.read(preferencesControllerProvider.notifier);
    await notifier.ready;
    final preferences = ref.read(preferencesControllerProvider);
    if (preferences.privacyPolicyAccepted) {
      return true;
    }
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyConsentPage(),
        fullscreenDialog: true,
      ),
    );
    if (accepted == true) {
      await notifier.setPrivacyPolicyAccepted(true);
      return true;
    }
    return false;
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

  double _serverCardWidth(double maxWidth) {
    final proposed = maxWidth * 0.68;
    if (proposed < 220) {
      return 220;
    }
    if (proposed > 320) {
      return 320;
    }
    return proposed;
  }

  double _estimateServerCardHeight(
    BoxConstraints constraints,
    List<Server> servers,
  ) {
    var height = 260.0;
    if (servers.any(_serverHasDistinctIpLine)) {
      height += 18;
    }
    if (servers.any((server) => server.sessions != null)) {
      height += 24;
    }
    if (constraints.maxWidth < 380) {
      height += 24;
    }
    if (height < 260) {
      height = 260;
    }
    if (height > 340) {
      height = 340;
    }
    return height;
  }

  bool _serverHasDistinctIpLine(Server server) {
    final host = server.hostName?.trim();
    final ip = (server.ip ?? server.endpoint.split(':').first).trim();
    if (host == null || host.isEmpty) {
      return false;
    }
    if (ip.isEmpty) {
      return false;
    }
    return host != ip;
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
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.7),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: NavigationBar(
                height: 70,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                selectedIndex: _tabIndex,
                onDestinationSelected: (index) {
                  if (index == _tabIndex) {
                    return;
                  }
                  unawaited(ref.read(hapticsServiceProvider).selection());
                  setState(() => _tabIndex = index);
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.shield_outlined),
                    selectedIcon: const Icon(Icons.shield),
                    label: l10n.navHome,
                  ),
                  NavigationDestination(
                    key: _speedTabKey,
                    icon: const Icon(Icons.speed_outlined),
                    selectedIcon: const Icon(Icons.speed),
                    label: l10n.navSpeedTest,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.history_outlined),
                    selectedIcon: const Icon(Icons.history),
                    label: l10n.navHistory,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: l10n.navSettings,
                  ),
                ],
              ),
            ),
          ),
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
    final ipInfoAsync = ref.watch(ipInfoProvider);
    final ipInfo = ipInfoAsync.asData?.value;
    final ipLoading = ipInfoAsync.isLoading;
    final currentIp = ipLoading
        ? '...'
        : (ipInfo != null && ipInfo.ip.isNotEmpty
            ? ipInfo.ip
            : (speedState.ip?.isNotEmpty ?? false ? speedState.ip! : '--'));
    final locationText = ipLoading
        ? '...'
        : (ipInfo != null && ipInfo.formattedLocation.isNotEmpty
            ? ipInfo.formattedLocation
            : '--');
    final ispText = ipLoading
        ? '...'
        : (ipInfo != null && ipInfo.isp.isNotEmpty ? ipInfo.isp : '--');
    final timezoneText = ipLoading
        ? '...'
        : (ipInfo != null && ipInfo.timezone.isNotEmpty ? ipInfo.timezone : '--');
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return serversAsyncValue.when(
                  data: (servers) {
                    final cardWidth = _serverCardWidth(constraints.maxWidth);
                    final minHeight =
                        _estimateServerCardHeight(constraints, servers);
                    final carouselHeight = minHeight + 24;
                    return SizedBox(
                      height: carouselHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              constraints.maxWidth * 0.04, // 4% of screen width
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: servers.length,
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.02,
                          ),
                          physics: const BouncingScrollPhysics(),
                          clipBehavior: Clip.none,
                          separatorBuilder: (_, __) => SizedBox(
                            width: constraints.maxWidth * 0.04,
                          ),
                          itemBuilder: (context, index) {
                            final server = servers[index];
                            final selected = selectedServer?.id == server.id;
                            final latency = catalog.latencyMs[server.id];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: _ServerCard(
                                server: server,
                                selected: selected,
                                connected: isConnected && selected,
                                onTap: isConnected
                                    ? null
                                    : () {
                                        unawaited(
                                          ref
                                              .read(hapticsServiceProvider)
                                              .selection(),
                                        );
                                        ref
                                            .read(selectedServerProvider.notifier)
                                            .select(server);
                                      },
                                latency: latency,
                                width: cardWidth,
                                minHeight: minHeight,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, __) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.04,
                      vertical: 16,
                    ),
                    child: Text('${l10n.failedToLoadServers}: $error'),
                  ),
                );
              },
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
                _InfoRow(label: l10n.currentIp, value: currentIp),
                const SizedBox(height: 12),
                _InfoRow(label: l10n.networkLocation, value: locationText),
                const SizedBox(height: 12),
                _InfoRow(label: l10n.networkIsp, value: ispText),
                const SizedBox(height: 12),
                _InfoRow(label: l10n.networkTimezone, value: timezoneText),
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
        height: 520,
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


class _ServerCard extends StatelessWidget {
  const _ServerCard({
    required this.server,
    required this.selected,
    required this.connected,
    this.onTap,
    this.latency,
    required this.width,
    required this.minHeight,
  });

  final Server server;
  final bool selected;
  final bool connected;
  final VoidCallback? onTap;
  final int? latency;
  final double width;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final statusLabel = connected
        ? l10n.badgeConnected
        : selected
            ? l10n.badgeSelected
            : l10n.badgeConnect;
    final statusColor = connected
        ? HiVpnColors.success
        : theme.colorScheme.onSurface.withOpacity(0.85);
    final pingValue = server.pingMs ?? latency;
    final latencyText = pingValue != null ? '$pingValue ms' : '--';
    final downloadText =
        _formatBandwidth(server.downloadSpeed ?? server.bandwidth);
    final uploadText = _formatBandwidth(server.uploadSpeed);
    final sessionsValue = server.sessions;
    final hostLabel = (server.hostName?.isNotEmpty ?? false)
        ? server.hostName!
        : server.endpoint;
    final ipLabel = (server.ip?.isNotEmpty ?? false)
        ? server.ip!
        : server.endpoint.split(':').first;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _flagEmoji(server.countryCode),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          latencyText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hostLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (ipLabel != hostLabel) ...[
                    const SizedBox(height: 4),
                    Text(
                      ipLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: l10n.serverDownloadLabel,
                          value: downloadText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          label: l10n.serverUploadLabel,
                          value: uploadText,
                        ),
                      ),
                    ],
                  ),
                  if (sessionsValue != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.serverSessionsLabel(sessionsValue),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  String _formatBandwidth(int? bytesPerSecond) {
    final value = bytesPerSecond ?? 0;
    if (value <= 0) {
      return '--';
    }
    const units = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    var display = value.toDouble();
    var unitIndex = 0;
    while (display >= 1024 && unitIndex < units.length - 1) {
      display /= 1024;
      unitIndex++;
    }
    return '${display.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
