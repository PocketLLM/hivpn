import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/utils/time.dart';
import '../../services/storage/prefs.dart';
import '../../theme/colors.dart';
import '../../theme/theme.dart';
import '../../widgets/connect_control.dart';
import '../../widgets/status_pill.dart';
import '../onboarding/presentation/spotlight_controller.dart';
import '../onboarding/presentation/spotlight_tour.dart';
import '../servers/data/server_repository.dart';
import '../servers/domain/server.dart';
import '../servers/domain/server_selection.dart';
import '../servers/presentation/server_picker_sheet.dart';
import '../session/domain/session_controller.dart';
import '../session/domain/session_state.dart';
import '../session/domain/session_status.dart';
import '../session/presentation/countdown.dart';
import '../speedtest/domain/speedtest_controller.dart';
import '../speedtest/presentation/speedtest_screen.dart';

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
    final steps = _buildSpotlightSteps();
    _spotlightController = SpotlightController(
      targets: steps.map((step) => step.toTarget()).toList(),
    );
    await _spotlightController?.show(
      context,
      onFinish: () => _completeTour(prefs),
      onSkip: () => _completeTour(prefs),
    );
  }

  void _completeTour(PrefsStore prefs) {
    prefs.setBool('tour_done', true);
  }

  List<SpotlightStep> _buildSpotlightSteps() {
    return [
      SpotlightStep(
        key: _serverCarouselKey,
        text: 'Choose a location to route your traffic.',
        align: ContentAlign.top,
      ),
      SpotlightStep(
        key: _connectKey,
        text: 'Watch a short ad to unlock 60 minutes.',
        align: ContentAlign.bottom,
      ),
      SpotlightStep(
        key: _statusKey,
        text: 'Your session time shows here.',
        align: ContentAlign.bottom,
      ),
      SpotlightStep(
        key: _speedTabKey,
        text: 'Measure speed, ping, and IP.',
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
    if (previous?.status == SessionStatus.connected &&
        next.status == SessionStatus.disconnected) {
      if (next.expired) {
        _showSessionExpiredDialog();
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Disconnected. Watch another ad to reconnect.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _buildHomeTab(context),
                  const SpeedTestScreen(),
                ],
              ),
            ),
            _buildNavigationBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final countdown = ref.watch(sessionCountdownProvider).maybeWhen(
          data: formatCountdown,
          orElse: () => session.duration != null
              ? formatCountdown(session.duration!)
              : '60:00',
        );
    final serversAsync = ref.watch(serversProvider);
    final selectedServer = ref.watch(selectedServerProvider);
    final speedState = ref.watch(speedTestControllerProvider);
    final theme = Theme.of(context);

    final statusLabel = _statusLabel(session.status, countdown);
    final statusColor = _statusColor(session.status);

    final isBusy = session.status == SessionStatus.preparing ||
        session.status == SessionStatus.connecting;
    final isConnected = session.status == SessionStatus.connected;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
            selectedServer?.name ?? 'Select a server to begin',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            selectedServer != null
                ? '${_flagEmoji(selectedServer.countryCode)}  ${selectedServer.countryCode.toUpperCase()}'
                : 'No server selected',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isConnected ? 'Session remaining' : 'Unlock secure access',
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
              label: isConnected ? 'Disconnect' : 'Connect',
              statusText: isConnected ? countdown : 'Watch ad to start',
              onTap: () async {
                if (isConnected) {
                  await ref.read(sessionControllerProvider.notifier).disconnect();
                } else {
                  final server = selectedServer;
                  if (server == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a server first.')),
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
                  'Locations',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _showServerPicker(context),
                  child: const Text('View all'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          KeyedSubtree(
            key: _serverCarouselKey,
            child: serversAsync.when(
              data: (servers) => SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: servers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final server = servers[index];
                    final selected = selectedServer?.id == server.id;
                    return _ServerCard(
                      server: server,
                      selected: selected,
                      connected: isConnected && selected,
                      onTap: isConnected
                          ? null
                          : () => ref
                              .read(selectedServerProvider.notifier)
                              .select(server),
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Text('Failed to load servers'),
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoFooter(
            context,
            ip: speedState.ip ?? '--',
            remaining: countdown,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _showLegalDialog(context),
            child: const Text('Terms & Privacy'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFooter(BuildContext context, {required String ip, required String remaining}) {
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
                  Text('Current IP', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(ip, style: theme.textTheme.titleMedium),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Session', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(remaining, style: theme.textTheme.titleMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _tabIndex = 1),
            child: Row(
              children: [
                Icon(Icons.speed, color: theme.colorScheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Run Speed Test to benchmark your tunnel latency.',
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

  Widget _buildNavigationBar(BuildContext context) {
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
                label: 'Home',
                selected: _tabIndex == 0,
                onTap: () => setState(() => _tabIndex = 0),
              ),
            ),
            Expanded(
              child: KeyedSubtree(
                key: _speedTabKey,
                child: _NavigationItem(
                  icon: Icons.speed,
                  label: 'Speed Test',
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
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

  String _statusLabel(SessionStatus status, String countdown) {
    switch (status) {
      case SessionStatus.connected:
        return 'Connected: $countdown';
      case SessionStatus.connecting:
        return 'Connecting…';
      case SessionStatus.preparing:
        return 'Preparing…';
      case SessionStatus.error:
        return 'Error';
      case SessionStatus.disconnected:
      default:
        return 'Disconnected';
    }
  }

  void _showServerPicker(BuildContext context) {
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
        title: const Text('Legal'),
        content: const Text(
            'VPN usage may be regulated in your country. Ensure you understand local laws before connecting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSessionExpiredDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Session expired'),
        content: const Text('Your 60 minute session is over. Watch another ad to reconnect.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
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
    required this.onTap,
  });

  final Server server;
  final bool selected;
  final bool connected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.pastelCard(
      selected ? theme.colorScheme.secondary : theme.colorScheme.primaryContainer,
      opacity: selected ? 0.22 : 0.12,
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? theme.colorScheme.secondary : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _flagEmoji(server.countryCode),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              server.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Latency -- ms',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: connected
                      ? HiVpnColors.success.withOpacity(0.2)
                      : theme.colorScheme.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  connected
                      ? 'Connected'
                      : selected
                          ? 'Selected'
                          : 'Connect',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: connected
                        ? HiVpnColors.success
                        : theme.colorScheme.onSurface.withOpacity(0.8),
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
