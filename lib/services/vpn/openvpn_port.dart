import 'dart:async';
import 'dart:io';

import 'package:openvpn_flutter/openvpn_flutter.dart';

import 'models/vpn.dart';
import 'models/vpn_config.dart';
import 'models/vpn_status.dart' as model;
import 'vpn_port.dart';

/// OpenVPN port implementation using openvpn_flutter package
class OpenVpnPort implements VpnPort {
  OpenVpnPort();

  OpenVPN? _engine;
  final StreamController<String> _intentActionsController =
      StreamController<String>.broadcast();
  final StreamController<VPNStage> _stageController =
      StreamController<VPNStage>.broadcast();
  final StreamController<model.VpnStatus> _statusController =
      StreamController<model.VpnStatus>.broadcast();

  bool _isConnected = false;
  bool _isInitialized = false;
  Vpn? _currentServer;

  @override
  bool get isSupported => true;

  @override
  Stream<String> get intentActions => _intentActionsController.stream;

  @override
  Future<bool> isConnected() async => _isConnected;

  @override
  Stream<VPNStage> get stageStream => _stageController.stream;

  @override
  Stream<model.VpnStatus> get statusStream => _statusController.stream;

  @override
  Future<bool> prepare() async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_engine == null) {
      return false;
    }
    if (Platform.isAndroid) {
      final granted = await _engine!.requestPermissionAndroid();
      return granted;
    }
    return true;
  }

  /// Initialize the OpenVPN engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _engine = OpenVPN(
        onVpnStatusChanged: (data) {
          if (data == null) {
            return;
          }
          final converted = _convertStatus(data);
          _lastStatus = converted;
          _statusController.add(converted);
        },
        onVpnStageChanged: (stage, rawStage) {
          _isConnected = stage == VPNStage.connected;
          _stageController.add(stage);
        },
      );

      await _engine!.initialize(
        groupIdentifier:
            Platform.isIOS ? 'group.com.example.hivpn' : null,
        providerBundleIdentifier:
            Platform.isIOS ? 'com.example.hivpn.VPNExtension' : null,
        localizedDescription: 'HiVPN',
      );

      _isInitialized = true;
    } catch (e) {
      print('Error initializing OpenVPN: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  Future<bool> connect(Vpn server) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (_isConnected) {
        await disconnect();
        await Future.delayed(const Duration(seconds: 1));
      }

      _currentServer = server;

      final configText = server.openVpnConfig.trim();
      if (configText.isEmpty) {
        print('Error: Empty OpenVPN config for ${server.countryLong}');
        return false;
      }

      final sanitizedConfig = _ensureTrailingNewline(configText);

      final config = VpnConfig(
        config: sanitizedConfig,
        country: server.countryLong,
        username: 'vpn',
        password: 'vpn',
      );

      await _engine!.connect(
        config.config,
        server.countryLong,
        username: config.username,
        password: config.password,
        certIsRequired: false,
      );

      return true;
    } catch (e) {
      print('Error connecting to VPN: $e');
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      if (_engine != null) {
        _engine!.disconnect();
      }
      _isConnected = false;
      _currentServer = null;
      _stageController.add(VPNStage.disconnected);
    } catch (e) {
      print('Error disconnecting from VPN: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTunnelStats() async {
    return _lastStatus?.toJson() ?? <String, dynamic>{};
  }

  @override
  Future<void> extendSession(Duration duration, {String? publicIp}) async {
    // Session extension is handled at the app level, not VPN level
    // This is a no-op for OpenVPN
  }

  /// Dispose resources
  void dispose() {
    _intentActionsController.close();
    _stageController.close();
    _statusController.close();
  }

  model.VpnStatus _convertStatus(VpnStatus status) {
    return model.VpnStatus(
      duration: status.duration ?? '00:00:00',
      connectedOn: status.connectedOn,
      byteIn: status.byteIn ?? '0',
      byteOut: status.byteOut ?? '0',
      packetsIn: status.packetsIn ?? '0',
      packetsOut: status.packetsOut ?? '0',
    );
  }

  String _ensureTrailingNewline(String config) {
    if (config.endsWith('\n')) {
      return config;
    }
    return '$config\n';
  }

  model.VpnStatus? _lastStatus;
}

