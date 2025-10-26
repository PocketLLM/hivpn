import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/vpn_config.dart';
import 'models/vpn_status.dart';

/// OpenVPN Engine for managing VPN connections
/// Communicates with native Android OpenVPN implementation via method channels
class OpenVpnEngine {
  // Channel names for native communication
  static const String _eventChannelVpnStage = "vpnStage";
  static const String _eventChannelVpnStatus = "vpnStatus";
  static const String _methodChannelVpnControl = "vpnControl";

  // VPN connection states
  static const String vpnConnected = "connected";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNoConnection = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPrepare = "prepare";
  static const String vpnDenied = "denied";

  /// Stream of VPN connection stage changes
  static Stream<String> vpnStageSnapshot() {
    try {
      return const EventChannel(_eventChannelVpnStage)
          .receiveBroadcastStream()
          .map((event) => event?.toString() ?? vpnDisconnected)
          .handleError((error) {
        print('VPN Stage Stream Error: $error');
        return vpnDisconnected;
      });
    } catch (e) {
      print('Error creating VPN stage stream: $e');
      return Stream.value(vpnDisconnected);
    }
  }

  /// Stream of VPN connection status (traffic stats)
  static Stream<VpnStatus?> vpnStatusSnapshot() {
    try {
      return const EventChannel(_eventChannelVpnStatus)
          .receiveBroadcastStream()
          .map((event) {
        try {
          if (event == null) return VpnStatus();
          if (event is String) {
            return VpnStatus.fromJson(jsonDecode(event));
          }
          if (event is Map) {
            return VpnStatus.fromJson(Map<String, dynamic>.from(event));
          }
          return VpnStatus();
        } catch (e) {
          print('Error parsing VPN status: $e');
          return VpnStatus();
        }
      }).handleError((error) {
        print('VPN Status Stream Error: $error');
        return VpnStatus();
      });
    } catch (e) {
      print('Error creating VPN status stream: $e');
      return Stream.value(VpnStatus());
    }
  }

  /// Start VPN connection with the given configuration
  static Future<void> startVpn(VpnConfig vpnConfig) async {
    try {
      await const MethodChannel(_methodChannelVpnControl).invokeMethod(
        "start",
        {
          "config": vpnConfig.config,
          "country": vpnConfig.country,
          "username": vpnConfig.username,
          "password": vpnConfig.password,
        },
      );
    } catch (e) {
      print('Error starting VPN: $e');
      rethrow;
    }
  }

  /// Stop VPN connection
  static Future<void> stopVpn() async {
    try {
      await const MethodChannel(_methodChannelVpnControl).invokeMethod("stop");
    } catch (e) {
      print('Error stopping VPN: $e');
      rethrow;
    }
  }

  /// Refresh VPN connection stage
  static Future<void> refreshStage() async {
    try {
      await const MethodChannel(_methodChannelVpnControl)
          .invokeMethod("refresh");
    } catch (e) {
      print('Error refreshing VPN stage: $e');
    }
  }

  /// Get current VPN stage
  static Future<String?> stage() async {
    try {
      return await const MethodChannel(_methodChannelVpnControl)
          .invokeMethod<String>("stage");
    } catch (e) {
      print('Error getting VPN stage: $e');
      return null;
    }
  }

  /// Check if VPN is connected
  static Future<bool> isConnected() async {
    try {
      final currentStage = await stage();
      return currentStage?.toLowerCase() == vpnConnected;
    } catch (e) {
      print('Error checking VPN connection: $e');
      return false;
    }
  }

  /// Open VPN kill switch settings (if supported)
  static Future<void> openKillSwitch() async {
    try {
      await const MethodChannel(_methodChannelVpnControl)
          .invokeMethod("kill_switch");
    } catch (e) {
      print('Error opening kill switch: $e');
    }
  }
}

