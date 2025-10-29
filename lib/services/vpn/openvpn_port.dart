import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

import '../../core/errors/app_error.dart';
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
          debugPrint('[OpenVpnPort] Stage changed: $stage (raw: $rawStage)');
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
      debugPrint('[OpenVpnPort] connect() invoked for ${server.countryLong}');
      if (!_isInitialized) {
        await initialize();
      }

      if (_isConnected) {
        await disconnect();
        await Future.delayed(const Duration(seconds: 1));
      }

      _currentServer = server;

      late final String configText;
      try {
        configText = server.openVpnConfig;
        debugPrint('[OpenVpnPort] Successfully decoded OpenVPN config, length: ${configText.length}');
      } on AppError catch (error) {
        debugPrint('[OpenVpnPort] Invalid OpenVPN config: $error');
        _stageController.add(VPNStage.error);
        return false;
      }

      if (configText.isEmpty) {
        debugPrint(
            '[OpenVpnPort] Error: Empty OpenVPN config for ${server.countryLong}');
        _stageController.add(VPNStage.error);
        return false;
      }

      final sanitizedConfig = _sanitizeOpenVpnConfig(configText);
      final username = sanitizedConfig.username ?? 'vpn';
      final password = sanitizedConfig.password ?? 'vpn';

      debugPrint('[OpenVpnPort] Using username: $username, password: ${password.isNotEmpty ? "****" : "(empty)"}');
      debugPrint('[OpenVpnPort] Sanitized config length: ${sanitizedConfig.config.length}');

      // For VPN Gate servers, we typically use 'vpn' as both username and password
      final vpnUsername = username.isNotEmpty ? username : 'vpn';
      final vpnPassword = password.isNotEmpty ? password : 'vpn';
      
      debugPrint('[OpenVpnPort] Attempting connection with username: $vpnUsername');
      debugPrint('[OpenVpnPort] Server country: ${server.countryLong}');
      debugPrint('[OpenVpnPort] Config preview (first 500 chars): ${sanitizedConfig.config.substring(0, sanitizedConfig.config.length > 500 ? 500 : sanitizedConfig.config.length)}');
      
      await _engine!.connect(
        sanitizedConfig.config,
        server.countryLong,
        username: vpnUsername,
        password: vpnPassword,
        certIsRequired: false,
      );

      debugPrint('[OpenVpnPort] OpenVPN connect command dispatched');
      return true;
    } catch (e, stackTrace) {
      debugPrint('[OpenVpnPort] Error connecting to VPN: $e');
      debugPrint('[OpenVpnPort] Stack trace: $stackTrace');
      _isConnected = false;
      _stageController.add(VPNStage.error);
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      debugPrint('[OpenVpnPort] disconnect() requested');
      if (_engine != null) {
        _engine!.disconnect();
      }
      _isConnected = false;
      _currentServer = null;
      _stageController.add(VPNStage.disconnected);
    } catch (e) {
      debugPrint('[OpenVpnPort] Error disconnecting from VPN: $e');
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

  SanitizedOpenVpnConfig _sanitizeOpenVpnConfig(String config) {
    debugPrint('[OpenVpnPort] Sanitizing OpenVPN config, original length: ${config.length}');
    var working = config.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    String? username;
    String? password;

    final authBlockPattern = RegExp(
      r'<auth-user-pass>(.*?)</auth-user-pass>',
      dotAll: true,
      caseSensitive: false,
    );

    final match = authBlockPattern.firstMatch(working);
    if (match != null) {
      debugPrint('[OpenVpnPort] Found auth-user-pass block in config');
      final blockContent = match.group(1) ?? '';
      final credentials = blockContent
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (credentials.isNotEmpty) {
        username = credentials[0];
        debugPrint('[OpenVpnPort] Extracted username from auth block: $username');
      }
      if (credentials.length > 1) {
        password = credentials[1];
        debugPrint('[OpenVpnPort] Extracted password from auth block: ****');
      }

      working = working.replaceRange(match.start, match.end, '');
    }

    working = working.replaceAll(authBlockPattern, '');

    final authLinePattern = RegExp(
      r'^\s*auth-user-pass(?:[ \t]+[^\r\n]+)?\s*$',
      multiLine: true,
    );

    var foundDirective = false;
    working = working.replaceAllMapped(authLinePattern, (match) {
      if (foundDirective) {
        return '';
      }
      foundDirective = true;
      debugPrint('[OpenVpnPort] Found auth-user-pass directive in config');
      return 'auth-user-pass';
    });

    if (!foundDirective) {
      debugPrint('[OpenVpnPort] No auth-user-pass directive found, adding one');
      working = working.trimRight();
      if (working.isNotEmpty && !working.endsWith('\n')) {
        working += '\n';
      }
      working += 'auth-user-pass\n';
    }

    final normalized = _ensureTrailingNewline(working.trimRight());
    debugPrint('[OpenVpnPort] Sanitized config length: ${normalized.length}');

    return SanitizedOpenVpnConfig(
      config: normalized,
      username: username,
      password: password,
    );
  }

  @visibleForTesting
  SanitizedOpenVpnConfig debugSanitizeOpenVpnConfig(String config) {
    return _sanitizeOpenVpnConfig(config);
  }

  model.VpnStatus? _lastStatus;
}

class SanitizedOpenVpnConfig {
  const SanitizedOpenVpnConfig({
    required this.config,
    this.username,
    this.password,
  });

  final String config;
  final String? username;
  final String? password;
}
