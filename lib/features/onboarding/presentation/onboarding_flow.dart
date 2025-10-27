import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/analytics/analytics_service.dart';
import '../../../services/notifications/session_notification_service.dart';
import '../../../services/vpn/vpn_provider.dart';
import '../../home/home_screen.dart';
import '../../servers/domain/server.dart';
import '../../servers/domain/server_catalog_controller.dart';
import '../../servers/domain/server_providers.dart';
import '../../session/domain/session_controller.dart';
import '../../session/domain/session_state.dart';
import '../../session/domain/session_status.dart';
import '../../settings/domain/preferences_controller.dart';
import '../../settings/domain/preferences_state.dart';
import '../../settings/presentation/privacy_policy_consent_page.dart';
import 'onboarding_controller.dart';
import 'onboarding_speedtest_controller.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _pendingConnect = false;
  bool _loggedStep3 = false;
  late final ProviderSubscription<ServerCatalogState> _serverCatalogSubscription;
  late final ProviderSubscription<SessionState> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(analyticsServiceProvider).logEvent('onboarding_viewed_step_1'));
    });
    _serverCatalogSubscription = ref.listenManual<ServerCatalogState>(
      serverCatalogProvider,
      (previous, next) {
        ref.read(onboardingControllerProvider.notifier).maybeAssignAuto(next);
      },
    );
    _sessionSubscription = ref.listenManual<SessionState>(
      sessionControllerProvider,
      (previous, next) {
        _handleSessionState(previous, next);
      },
    );
  }

  @override
  void dispose() {
    _serverCatalogSubscription.close();
    _sessionSubscription.close();
    _pageController.dispose();
    super.dispose();
  }

  void _handleSessionState(SessionState? previous, SessionState next) {
    if (!_pendingConnect) {
      return;
    }
    if (previous?.status != SessionStatus.connected && next.status == SessionStatus.connected) {
      _pendingConnect = false;
      ref.read(onboardingControllerProvider.notifier).setConnecting(false);
      unawaited(ref.read(analyticsServiceProvider).logEvent('connect_success'));
      unawaited(
        ref.read(preferencesControllerProvider.notifier).setOnboardingCompleted(true),
      );
      unawaited(_navigateToHome());
    } else if (previous?.status != SessionStatus.error && next.status == SessionStatus.error) {
      _pendingConnect = false;
      ref.read(onboardingControllerProvider.notifier).setConnecting(false);
      final message = next.errorMessage ?? 'Unable to establish VPN connection.';
      ref.read(onboardingControllerProvider.notifier).setConnectionError(message);
      unawaited(ref.read(analyticsServiceProvider).logEvent(
        'connect_failure',
        {'message': message},
      ));
      unawaited(_showConnectionErrorSheet(message));
    }
  }

  Future<void> _goToPage(int index) async {
    setState(() {
      _currentPage = index;
    });
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    if (index == 2 && !_loggedStep3) {
      _loggedStep3 = true;
      unawaited(ref.read(analyticsServiceProvider).logEvent('onboarding_step_3_viewed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);
    final speedTestState = ref.watch(onboardingSpeedTestControllerProvider);
    final preferences = ref.watch(preferencesControllerProvider);
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  if (index == 2 && !_loggedStep3) {
                    _loggedStep3 = true;
                    unawaited(ref
                        .read(analyticsServiceProvider)
                        .logEvent('onboarding_step_3_viewed'));
                  }
                },
                children: [
                  _WelcomePage(
                    onGetStarted: () {
                      unawaited(
                        ref.read(analyticsServiceProvider).logEvent('onboarding_cta_step_1'),
                      );
                      _goToPage(1);
                    },
                    onLearnMore: _showHowItWorksSheet,
                    onPrivacyPolicy: _showPrivacyPolicy,
                    onViewSource: () => _openLink(Uri.parse('https://github.com/hivpn/hivpn')),
                  ),
                  _SpeedTestPage(
                    state: speedTestState,
                    onToggleOptIn: (value) {
                      ref
                          .read(onboardingSpeedTestControllerProvider.notifier)
                          .toggleOptIn(value);
                    },
                    onRunTest: () {
                      ref.read(onboardingSpeedTestControllerProvider.notifier).startTest();
                    },
                    onCancelTest: () {
                      ref.read(onboardingSpeedTestControllerProvider.notifier).cancelTest();
                    },
                    onContinue: () async {
                      if (!speedTestState.optIn) {
                        await ref
                            .read(analyticsServiceProvider)
                            .logEvent('speedtest_skipped', {'method': 'toggle_off_continue'});
                      }
                      _goToPage(2);
                    },
                    onSkip: () async {
                      await ref
                          .read(analyticsServiceProvider)
                          .logEvent('speedtest_skipped', {'method': 'skip_button'});
                      _goToPage(2);
                    },
                    onLearnMore: _showSpeedTestLearnMoreSheet,
                    onDismissBanner: () {
                      ref
                          .read(onboardingSpeedTestControllerProvider.notifier)
                          .markBannerDismissed();
                    },
                  ),
                  _ConnectPage(
                    state: onboardingState,
                    preferences: preferences,
                    onSelectAuto: () async {
                      await ref.read(onboardingControllerProvider.notifier).useAutoServer();
                    },
                    onSelectManual: () async {
                      final server = await _showServerPicker(context);
                      if (server != null) {
                        await ref
                            .read(onboardingControllerProvider.notifier)
                            .selectManualServer(server);
                      }
                    },
                    onImport: () async {
                      final config = await _pickOvpnConfig();
                      if (config != null) {
                        await ref
                            .read(onboardingControllerProvider.notifier)
                            .setImportedConfig(config);
                      }
                    },
                    onClearImport: () {
                      ref.read(onboardingControllerProvider.notifier).clearImportedConfig();
                    },
                    onToggleAutoReconnect: (value) {
                      unawaited(ref
                          .read(preferencesControllerProvider.notifier)
                          .setAutoReconnect(value));
                    },
                    onOpenAlwaysOnSettings: _openAlwaysOnSettings,
                    onEnableNotifications: () => _requestNotifications(),
                    onAllowConnect: () {
                      _handleConnect(requestNotifications: true);
                    },
                    onConnectWithoutNotifications: () {
                      _handleConnect(requestNotifications: false);
                    },
                    onSkipSetup: () async {
                      await ref
                          .read(preferencesControllerProvider.notifier)
                          .setOnboardingCompleted(true);
                      await _navigateToHome();
                    },
                    onShowRisks: _showRisksSheet,
                  ),
                ],
              ),
              if (_currentPage < 2)
                Positioned(
                  top: 0,
                  right: size.width > 400 ? 16 : 8,
                  child: TextButton(
                    onPressed: () {
                      _goToPage(2);
                    },
                    child: const Text('Skip'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToHome() async {
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _handleConnect({required bool requestNotifications}) async {
    final onboardingNotifier = ref.read(onboardingControllerProvider.notifier);
    final onboardingState = ref.read(onboardingControllerProvider);
    final analytics = ref.read(analyticsServiceProvider);

    final server = onboardingState.serverMode == OnboardingServerMode.imported
        ? onboardingState.importedConfig?.toServer()
        : onboardingState.selectedServer;

    if (server == null) {
      _showSnackBar('Choose a server before connecting.');
      return;
    }

    unawaited(analytics.logEvent('connect_tapped', {
      'notifications': requestNotifications,
      'selection': onboardingState.serverMode.name,
    }));

    onboardingNotifier.setConnecting(true);
    setState(() {
      _pendingConnect = true;
    });

    if (requestNotifications) {
      await _requestNotifications();
    }

    final vpnPort = ref.read(openVpnPortProvider);
    final granted = await vpnPort.prepare();
    unawaited(analytics.logEvent('vpn_permission_result', {'granted': granted}));
    if (!granted) {
      onboardingNotifier.setConnecting(false);
      setState(() {
        _pendingConnect = false;
      });
      _showSnackBar('VPN permission is required to continue.');
      return;
    }

    try {
      await ref.read(sessionControllerProvider.notifier).connect(
            context: context,
            server: server,
          );
    } catch (error) {
      onboardingNotifier.setConnecting(false);
      setState(() {
        _pendingConnect = false;
      });
      final message = error.toString();
      onboardingNotifier.setConnectionError(message);
      await analytics.logEvent('connect_failure', {'message': message});
      unawaited(_showConnectionErrorSheet(message));
    }
  }

  Future<bool> _requestNotifications() async {
    final notificationService = ref.read(sessionNotificationServiceProvider);
    try {
      final granted = await notificationService.requestPermission();
      final controller = ref.read(onboardingControllerProvider.notifier);
      controller.setNotificationsPrompted(true);
      controller.setNotificationsGranted(granted);
      controller.setShowNotificationDenied(!granted);
      if (!granted) {
        _showSnackBar('Notifications are optional, but recommended for status updates.');
      }
      return granted;
    } on PlatformException catch (error) {
      final controller = ref.read(onboardingControllerProvider.notifier);
      controller.setNotificationsPrompted(true);
      controller.setNotificationsGranted(false);
      controller.setShowNotificationDenied(true);
      _showSnackBar('Unable to request notifications: ${error.message}');
      return false;
    }
  }

  Future<void> _showHowItWorksSheet() {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How HiVPN works',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _DiagramStep(
                icon: Icons.public,
                title: 'Community servers',
                description:
                    'HiVPN connects to public VPNGate relays so you can reach open servers worldwide.',
              ),
              _DiagramStep(
                icon: Icons.vpn_lock,
                title: 'Encrypted tunnel',
                description:
                    'Your traffic flows through an encrypted OpenVPN tunnel before heading to the internet.',
              ),
              _DiagramStep(
                icon: Icons.lock_open,
                title: 'No account needed',
                description:
                    'Launch, pick a server, and connect. No sign-up or email required to get going.',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSpeedTestLearnMoreSheet() {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About the quick speed test',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const _BulletLine('Measures download, upload, and latency using our test endpoints.'),
              const _BulletLine('Endpoints are currently hosted in multiple regions for baseline checks.'),
              const _BulletLine('You can opt out anytime; skipping has no impact on VPN usage.'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRisksSheet() {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Know the risks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _BulletLine('VPNGate relays are run by volunteers and may keep logs.'),
              _BulletLine('Throughput and uptime can fluctuate; switch if a server feels slow.'),
              _BulletLine('Understand your local laws when using VPNs to bypass censorship.'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showConnectionErrorSheet(String message) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connection failed',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Try again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        unawaited(
                          _openLink(Uri.parse('https://www.vpngate.net/en/about_overview.aspx')),
                        );
                      },
                      child: const Text('Help'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPrivacyPolicy() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyConsentPage(),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openAlwaysOnSettings() async {
    if (!Platform.isAndroid) {
      _showSnackBar('Always-on VPN settings are only available on Android devices.');
      return;
    }
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.vpn);
    } catch (error) {
      _showSnackBar('Unable to open VPN settings: $error');
    }
  }

  Future<Server?> _showServerPicker(BuildContext context) async {
    return showModalBottomSheet<Server>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        final catalog = ref.watch(serverCatalogProvider);
        final servers = catalog.sortedServers;
        if (catalog.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (servers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No community servers are available right now. Pull to refresh later.'),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Browse community list',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  final server = servers[index];
                  final latency = catalog.latencyMs[server.id];
                  return ListTile(
                    title: Text(server.name),
                    subtitle: Text(_formatServerSubtitle(server, latency)),
                    onTap: () {
                      Navigator.of(context).pop(server);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<ImportedOvpnConfig?> _pickOvpnConfig() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['ovpn'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }
      final file = result.files.first;
      var data = file.bytes;
      if (data == null) {
        final path = file.path;
        if (path == null) {
          _showSnackBar('Unable to read the selected file.');
          return null;
        }
        data = await File(path).readAsBytes();
      }
      final bytes = data;
      final content = utf8.decode(bytes);
      return _parseOvpn(content, file.name);
    } catch (error) {
      _showSnackBar('Unable to import configuration: $error');
      return null;
    }
  }

  ImportedOvpnConfig? _parseOvpn(String content, String filename) {
    final lines = LineSplitter.split(content).map((line) => line.trim()).toList();
    final remoteLine = lines.firstWhere(
      (line) => line.startsWith('remote '),
      orElse: () => '',
    );
    if (remoteLine.isEmpty) {
      _showSnackBar('The selected .ovpn file is missing a remote directive.');
      return null;
    }
    final parts = remoteLine.split(RegExp(r'\s+'));
    if (parts.length < 3) {
      _showSnackBar('The remote directive must include host and port.');
      return null;
    }
    final host = parts[1];
    final port = parts[2];
    final cipherLine = lines.firstWhere(
      (line) => line.startsWith('cipher '),
      orElse: () => '',
    );
    final cipher = cipherLine.isNotEmpty ? cipherLine.split(RegExp(r'\s+')).skip(1).join(' ') : null;
    final name = filename.replaceAll('.ovpn', '').trim().isEmpty
        ? 'Imported server'
        : filename.replaceAll('.ovpn', '').trim();
    return ImportedOvpnConfig(
      name: name,
      remote: '$host:$port',
      rawConfig: content,
      cipher: cipher,
    );
  }

  Future<void> _openLink(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Unable to open ${uri.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatServerSubtitle(Server server, int? latency) {
    final metrics = <String>[];
    if (server.countryName?.isNotEmpty == true) {
      metrics.add(server.countryName!);
    }
    if (latency != null && latency < 9999) {
      metrics.add('${latency} ms');
    }
    if (server.downloadSpeed != null && server.downloadSpeed! > 0) {
      metrics.add('${(server.downloadSpeed! / 1000).toStringAsFixed(1)} Mbps');
    }
    if (server.sessions != null && server.sessions! > 0) {
      metrics.add('${server.sessions} sessions');
    }
    return metrics.isEmpty ? 'No extra details available' : metrics.join(' • ');
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.onGetStarted,
    required this.onLearnMore,
    required this.onPrivacyPolicy,
    required this.onViewSource,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLearnMore;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onViewSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/s1.svg',
                  height: constraints.maxHeight > 600 ? 240 : 200,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Free VPN with community servers',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const _BulletLine('OpenVPN tunnel for reliable connectivity'),
              const _BulletLine('Connect to public servers from VPNGate'),
              const _BulletLine('No account. Import your own .ovpn if you like.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onGetStarted,
                child: const Text('Get started'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onLearnMore,
                child: const Text('Learn how it works'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(onPressed: onPrivacyPolicy, child: const Text('Privacy Policy')),
                  const SizedBox(width: 8),
                  TextButton(onPressed: onViewSource, child: const Text('View Source')),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _launchAttribution(),
                child: const Text('Online illustrations by Storyset'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _launchAttribution() async {
    final uri = Uri.parse('https://storyset.com/online');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SpeedTestPage extends StatelessWidget {
  const _SpeedTestPage({
    required this.state,
    required this.onToggleOptIn,
    required this.onRunTest,
    required this.onCancelTest,
    required this.onContinue,
    required this.onSkip,
    required this.onLearnMore,
    required this.onDismissBanner,
  });

  final OnboardingSpeedTestState state;
  final ValueChanged<bool> onToggleOptIn;
  final VoidCallback onRunTest;
  final VoidCallback onCancelTest;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onLearnMore;
  final VoidCallback onDismissBanner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/s2.svg',
              height: 220,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Check your connection speed',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We use a Flutter library to measure download and upload so you know what to expect before connecting.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Running a test sends traffic to test endpoints. Your IP is visible to them.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: onLearnMore,
                    child: const Text('Learn more'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: state.optIn,
            onChanged: onToggleOptIn,
            title: const Text('I want to run a quick speed test now'),
          ),
          if (state.showUnavailableBanner)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: MaterialBanner(
                content: const Text('Speed test unavailable right now. You can continue.'),
                actions: [
                  TextButton(onPressed: onDismissBanner, child: const Text('Dismiss')),
                ],
              ),
            ),
          if (state.optIn) ...[
            const SizedBox(height: 16),
            _SpeedProgress(state: state),
          ],
          const SizedBox(height: 24),
          if (state.optIn && state.status == OnboardingSpeedTestStatus.running)
            FilledButton(
              onPressed: onCancelTest,
              child: const Text('Cancel test'),
            )
          else
            FilledButton(
              onPressed: state.optIn
                  ? (state.status == OnboardingSpeedTestStatus.completed ? onContinue : onRunTest)
                  : onContinue,
              child: Text(state.optIn
                  ? (state.status == OnboardingSpeedTestStatus.completed ? 'Continue' : 'Run quick test')
                  : 'Continue'),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}

class _ConnectPage extends StatelessWidget {
  const _ConnectPage({
    required this.state,
    required this.preferences,
    required this.onSelectAuto,
    required this.onSelectManual,
    required this.onImport,
    required this.onClearImport,
    required this.onToggleAutoReconnect,
    required this.onOpenAlwaysOnSettings,
    required this.onEnableNotifications,
    required this.onAllowConnect,
    required this.onConnectWithoutNotifications,
    required this.onSkipSetup,
    required this.onShowRisks,
  });

  final OnboardingState state;
  final PreferencesState preferences;
  final Future<void> Function() onSelectAuto;
  final Future<void> Function() onSelectManual;
  final Future<void> Function() onImport;
  final VoidCallback onClearImport;
  final ValueChanged<bool> onToggleAutoReconnect;
  final Future<void> Function() onOpenAlwaysOnSettings;
  final Future<bool> Function() onEnableNotifications;
  final VoidCallback onAllowConnect;
  final VoidCallback onConnectWithoutNotifications;
  final Future<void> Function() onSkipSetup;
  final Future<void> Function() onShowRisks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseline = state.speedTestSummary;
    final isConnecting = state.connecting;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/s3.svg',
              height: 220,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pick a server and connect',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (baseline != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.speed, size: 18),
                label: Text(
                  'Baseline: ${baseline.downloadMbps.toStringAsFixed(0)}↓ / ${baseline.uploadMbps.toStringAsFixed(0)}↑',
                ),
              ),
            ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Server'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Best server (Auto)'),
                selected: state.serverMode == OnboardingServerMode.auto,
                onSelected: (_) => unawaited(onSelectAuto()),
              ),
              ChoiceChip(
                label: const Text('Browse community list'),
                selected: state.serverMode == OnboardingServerMode.manual,
                onSelected: (_) => unawaited(onSelectManual()),
              ),
              ChoiceChip(
                label: const Text('Import .ovpn'),
                selected: state.serverMode == OnboardingServerMode.imported,
                onSelected: (_) => unawaited(onImport()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.serverMode != OnboardingServerMode.imported && state.selectedServer != null)
            _ServerSummaryCard(server: state.selectedServer!),
          if (state.serverMode == OnboardingServerMode.imported && state.importedConfig != null)
            _ImportedConfigCard(config: state.importedConfig!, onClear: onClearImport),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Options'),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            value: preferences.autoReconnect,
            onChanged: onToggleAutoReconnect,
            title: const Text('Auto reconnect in background'),
          ),
          ListTile(
            title: const Text('Always-on VPN'),
            subtitle: const Text('Open system settings to enable Android’s kill-switch.'),
            onTap: () {
              unawaited(onOpenAlwaysOnSettings());
            },
            trailing: const Icon(Icons.open_in_new),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Permissions'),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.vpn_lock),
            title: const Text('VPN permission'),
            subtitle: const Text('Requested when you connect for the first time.'),
          ),
          ListTile(
            leading: Icon(
              state.notificationsGranted ? Icons.notifications_active : Icons.notifications_none,
            ),
            title: const Text('Notifications for status and controls'),
            subtitle: Text(state.notificationsPrompted
                ? (state.notificationsGranted
                    ? 'Enabled for session updates.'
                    : 'Permission denied. You can try again later.')
                : 'Recommended on Android 13+ to show tunnel status.'),
            trailing: TextButton(
              onPressed: () {
                unawaited(onEnableNotifications());
              },
              child: const Text('Enable'),
            ),
          ),
          if (state.showNotificationDenied)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Notifications will be disabled for now.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isConnecting ? null : onAllowConnect,
            child: isConnecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Allow & Connect'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: isConnecting ? null : onConnectWithoutNotifications,
            child: const Text('Connect without notifications'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isConnecting ? null : () => unawaited(onSkipSetup()),
            child: const Text('Set this up later'),
          ),
          const SizedBox(height: 24),
          Text(
            'VPNGate servers are run by volunteers. Availability and speed vary. Some operators may keep logs. Use at your own discretion.',
            style: theme.textTheme.bodySmall,
          ),
          TextButton(
            onPressed: () {
              unawaited(onShowRisks());
            },
            child: const Text('Know the risks'),
          ),
        ],
      ),
    );
  }
}

class _SpeedProgress extends StatelessWidget {
  const _SpeedProgress({required this.state});

  final OnboardingSpeedTestState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: state.isRunning ? state.progress : (state.summary != null ? 1 : 0)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Download',
                    value: state.downloadMbps > 0
                        ? '${state.downloadMbps.toStringAsFixed(1)} Mbps'
                        : state.isRunning
                            ? 'Measuring…'
                            : '--',
                    icon: Icons.download,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Upload',
                    value: state.uploadMbps > 0
                        ? '${state.uploadMbps.toStringAsFixed(1)} Mbps'
                        : state.isRunning
                            ? 'Pending…'
                            : '--',
                    icon: Icons.upload,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricTile(
              label: 'Latency',
              value: state.latency != null
                  ? '${state.latency!.inMilliseconds} ms'
                  : state.isRunning
                      ? 'Checking…'
                      : '--',
              icon: Icons.podcasts,
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
              Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ServerSummaryCard extends StatelessWidget {
  const _ServerSummaryCard({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(server.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (server.countryName != null)
              Text(server.countryName!, style: theme.textTheme.bodySmall),
            if (server.downloadSpeed != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Recent throughput: ${(server.downloadSpeed! / 1000).toStringAsFixed(1)} Mbps'),
              ),
            if (server.sessions != null)
              Text('Active sessions: ${server.sessions}'),
          ],
        ),
      ),
    );
  }
}

class _ImportedConfigCard extends StatelessWidget {
  const _ImportedConfigCard({required this.config, required this.onClear});

  final ImportedOvpnConfig config;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    config.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove',
                ),
              ],
            ),
            Text('Remote: ${config.remote}'),
            if (config.cipher != null)
              Text('Cipher: ${config.cipher}'),
          ],
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramStep extends StatelessWidget {
  const _DiagramStep({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
