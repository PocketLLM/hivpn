import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/storage/prefs.dart';
import '../servers/data/server_repository.dart';
import '../servers/domain/server_selection.dart';
import '../servers/presentation/server_picker_sheet.dart';
import '../session/domain/session_controller.dart';
import '../session/domain/session_status.dart';
import '../session/domain/session_state.dart';
import '../session/presentation/countdown.dart';
import '../../theme/colors.dart';
import '../../widgets/hivpn_button.dart';
import '../../widgets/status_pill.dart';
import '../onboarding/presentation/spotlight_controller.dart';
import '../onboarding/presentation/spotlight_tour.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _serverKey = GlobalKey();
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _statusKey = GlobalKey();
  final GlobalKey _notificationKey = GlobalKey();
  SpotlightController? _spotlightController;

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
        key: _serverKey,
        text: 'Choose a location to route your traffic.',
        align: ContentAlign.bottom,
      ),
      SpotlightStep(
        key: _buttonKey,
        text: 'Watch a short ad to unlock 60 minutes.',
        align: ContentAlign.top,
      ),
      SpotlightStep(
        key: _statusKey,
        text: 'Your session time shows here.',
        align: ContentAlign.bottom,
      ),
      SpotlightStep(
        key: _notificationKey,
        text:
            'HiVPN keeps a foreground service so your connection stays stable.',
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
          const SnackBar(content: Text('Disconnected. Watch another ad to reconnect.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final selectedServer = ref.watch(selectedServerProvider);
    final theme = Theme.of(context);

    final statusLabel = _statusLabel(session.status);
    final statusColor = _statusColor(session.status);

    final isBusy = session.status == SessionStatus.preparing ||
        session.status == SessionStatus.connecting;
    final isConnected = session.status == SessionStatus.connected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HiVPN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 48),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SessionCountdown(),
                    const SizedBox(height: 16),
                    Text(
                      selectedServer?.name ?? 'Select a server',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 48),
                    KeyedSubtree(
                      key: _buttonKey,
                      child: HiVpnButton(
                        label: isConnected ? 'Disconnect' : 'Connect',
                        isLoading: isBusy,
                        onPressed: isBusy
                            ? null
                            : () async {
                                if (isConnected) {
                                  await ref
                                      .read(sessionControllerProvider.notifier)
                                      .disconnect();
                                } else {
                                  final server = selectedServer;
                                  if (server == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select a server first.'),
                                      ),
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                key: _serverKey,
                onTap: () => _showServerPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedServer?.name ?? 'Choose location',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedServer?.countryCode.toUpperCase() ?? 'Not selected',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              KeyedSubtree(
                key: _notificationKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Stay connected: HiVPN runs a foreground notification while active.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _showLegalDialog(context),
                child: const Text('Terms & Privacy'),
              ),
            ],
          ),
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

  String _statusLabel(SessionStatus status) {
    switch (status) {
      case SessionStatus.connected:
        return 'Connected';
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
        height: 400,
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
        content: const Text(
            'Your 60 minute session has ended. Watch another ad to reconnect.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final server = ref.read(selectedServerProvider);
              if (server != null) {
                ref
                    .read(sessionControllerProvider.notifier)
                    .connect(context: context, server: server);
              }
            },
            child: const Text('Watch ad'),
          ),
        ],
      ),
    );
  }
}
