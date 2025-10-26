import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'openvpn_port.dart';
import 'models/vpn.dart';

/// Provider for OpenVPN port
final openVpnPortProvider = Provider<OpenVpnPort>((ref) {
  final port = OpenVpnPort();
  // Initialize on first access
  port.initialize().catchError((error) {
    debugPrint('Failed to initialize OpenVPN: $error');
  });
  return port;
});

/// Legacy VPN port provider for backward compatibility
/// Now returns OpenVPN port instead of WireGuard
final vpnPortProvider = Provider<OpenVpnPort>((ref) {
  return ref.watch(openVpnPortProvider);
});
