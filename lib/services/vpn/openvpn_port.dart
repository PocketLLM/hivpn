import 'dart:async';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'models/vpn.dart';
import 'models/vpn_config.dart';
import 'vpn_port.dart';

/// OpenVPN port implementation using openvpn_flutter package
class OpenVpnPort implements VpnPort {
  OpenVpnPort();

  OpenVPN? _engine;
  final StreamController<String> _intentActionsController =
      StreamController<String>.broadcast();

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
  Future<bool> prepare() async {
    // OpenVPN Flutter handles permissions internally
    if (!_isInitialized) {
      await initialize();
    }
    return true;
  }

  /// Initialize the OpenVPN engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _engine = OpenVPN(
        onVpnStatusChanged: (data) {
          // Handle status changes
          print('VPN Status: $data');
        },
        onVpnStageChanged: (stage, rawStage) {
          _isConnected = stage == VPNStage.connected;
          print('VPN Stage: $stage');
        },
      );

      await _engine!.initialize(
        groupIdentifier: "group.com.example.hivpn",
        providerBundleIdentifier: "com.example.hivpn.VPNExtension",
        localizedDescription: "HiVPN",
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

      final config = VpnConfig(
        config: server.openVpnConfig,
        country: server.countryLong,
        username: 'vpn',
        password: 'vpn',
      );

      if (config.config.isEmpty) {
        print('Error: Empty OpenVPN config for ${server.countryLong}');
        return false;
      }

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
    } catch (e) {
      print('Error disconnecting from VPN: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTunnelStats() async {
    // OpenVPN Flutter doesn't provide detailed stats in the same way
    // Return empty map for now
    return {};
  }

  @override
  Future<void> extendSession(Duration duration, {String? publicIp}) async {
    // Session extension is handled at the app level, not VPN level
    // This is a no-op for OpenVPN
  }

  /// Dispose resources
  void dispose() {
    _intentActionsController.close();
  }
}

