import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/analytics/analytics_service.dart';
import '../../servers/domain/server.dart';
import '../../servers/domain/server_catalog_controller.dart';
import '../../servers/domain/server_providers.dart';
import '../presentation/onboarding_speedtest_controller.dart';

enum OnboardingServerMode { auto, manual, imported }

class ImportedOvpnConfig {
  const ImportedOvpnConfig({
    required this.name,
    required this.remote,
    required this.rawConfig,
    this.cipher,
  });

  final String name;
  final String remote;
  final String rawConfig;
  final String? cipher;

  String get base64Config => base64.encode(utf8.encode(rawConfig));

  Server toServer() {
    final id = 'imported-${DateTime.now().millisecondsSinceEpoch}';
    return Server(
      id: id,
      name: name,
      countryCode: 'ZZ',
      publicKey: '',
      endpoint: remote,
      allowedIps: '0.0.0.0/0',
      openVpnConfigDataBase64: base64Config,
    );
  }
}

class OnboardingState {
  const OnboardingState({
    this.serverMode = OnboardingServerMode.auto,
    this.selectedServer,
    this.importedConfig,
    this.notificationsGranted = false,
    this.notificationsPrompted = false,
    this.connecting = false,
    this.connectionError,
    this.showNotificationDenied = false,
    this.speedTestSummary,
  });

  final OnboardingServerMode serverMode;
  final Server? selectedServer;
  final ImportedOvpnConfig? importedConfig;
  final bool notificationsGranted;
  final bool notificationsPrompted;
  final bool connecting;
  final String? connectionError;
  final bool showNotificationDenied;
  final SpeedTestSummary? speedTestSummary;

  OnboardingState copyWith({
    OnboardingServerMode? serverMode,
    Server? selectedServer,
    ImportedOvpnConfig? importedConfig,
    bool? notificationsGranted,
    bool? notificationsPrompted,
    bool? connecting,
    Object? connectionError = _sentinel,
    bool? showNotificationDenied,
    SpeedTestSummary? speedTestSummary,
  }) {
    return OnboardingState(
      serverMode: serverMode ?? this.serverMode,
      selectedServer: selectedServer ?? this.selectedServer,
      importedConfig: importedConfig ?? this.importedConfig,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      notificationsPrompted: notificationsPrompted ?? this.notificationsPrompted,
      connecting: connecting ?? this.connecting,
      connectionError: identical(connectionError, _sentinel)
          ? this.connectionError
          : connectionError as String?,
      showNotificationDenied: showNotificationDenied ?? this.showNotificationDenied,
      speedTestSummary: speedTestSummary ?? this.speedTestSummary,
    );
  }

  static const Object _sentinel = Object();
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._ref) : super(const OnboardingState());

  final Ref _ref;

  Future<void> setServerMode(OnboardingServerMode mode,
      {bool userInitiated = true}) async {
    if (state.serverMode == mode) {
      return;
    }
    if (userInitiated) {
      await _logServerSelection(mode);
    }
    state = state.copyWith(serverMode: mode);
    if (mode == OnboardingServerMode.auto) {
      final catalog = _ref.read(serverCatalogProvider);
      maybeAssignAuto(catalog);
    }
  }

  Future<void> _logServerSelection(OnboardingServerMode mode) {
    final analytics = _ref.read(analyticsServiceProvider);
    switch (mode) {
      case OnboardingServerMode.auto:
        return analytics.logEvent('server_select_auto');
      case OnboardingServerMode.manual:
        return analytics.logEvent('server_select_browse');
      case OnboardingServerMode.imported:
        return analytics.logEvent('server_select_import');
    }
  }

  void maybeAssignAuto(ServerCatalogState catalog) {
    if (state.serverMode != OnboardingServerMode.auto) {
      return;
    }
    final best = _pickBestServer(catalog);
    if (best == null) {
      return;
    }
    if (state.selectedServer?.id == best.id) {
      return;
    }
    state = state.copyWith(selectedServer: best);
  }

  Server? _pickBestServer(ServerCatalogState catalog) {
    final candidates = catalog.servers
        .where((server) => (server.openVpnConfigDataBase64?.isNotEmpty ?? false))
        .toList();
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((a, b) {
      final latencyMap = catalog.latencyMs;
      final latencyA = latencyMap[a.id] ?? 9999;
      final latencyB = latencyMap[b.id] ?? 9999;
      if (latencyA != latencyB) {
        return latencyA.compareTo(latencyB);
      }
      final scoreA = a.score ?? 0;
      final scoreB = b.score ?? 0;
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      final throughputA = a.downloadSpeed ?? a.bandwidth ?? 0;
      final throughputB = b.downloadSpeed ?? b.bandwidth ?? 0;
      if (throughputA != throughputB) {
        return throughputB.compareTo(throughputA);
      }
      return a.name.compareTo(b.name);
    });
    return candidates.first;
  }

  Future<void> selectManualServer(Server server) async {
    await setServerMode(OnboardingServerMode.manual);
    state = state.copyWith(selectedServer: server, importedConfig: null);
  }

  Future<void> useAutoServer() async {
    await setServerMode(OnboardingServerMode.auto);
    state = state.copyWith(importedConfig: null);
  }

  Future<void> setImportedConfig(ImportedOvpnConfig config) async {
    await setServerMode(OnboardingServerMode.imported);
    state = state.copyWith(importedConfig: config, selectedServer: null);
  }

  void clearImportedConfig() {
    if (state.importedConfig == null) {
      return;
    }
    state = state.copyWith(importedConfig: null);
  }

  void setNotificationsGranted(bool granted) {
    state = state.copyWith(notificationsGranted: granted);
  }

  void setNotificationsPrompted(bool prompted) {
    state = state.copyWith(notificationsPrompted: prompted);
  }

  void setConnecting(bool connecting) {
    state = state.copyWith(connecting: connecting, connectionError: null);
  }

  void setConnectionError(String? error) {
    state = state.copyWith(connectionError: error);
  }

  void setShowNotificationDenied(bool visible) {
    state = state.copyWith(showNotificationDenied: visible);
  }

  void setSpeedTestSummary(SpeedTestSummary? summary) {
    state = state.copyWith(speedTestSummary: summary);
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(ref);
});
