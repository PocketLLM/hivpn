import 'dart:async';
import 'models/vpn.dart';

/// Abstract VPN port interface
/// Now supports OpenVPN instead of WireGuard
abstract class VpnPort {
  bool get isSupported;
  Stream<String> get intentActions;
  Future<bool> prepare();
  Future<bool> connect(Vpn server);
  Future<void> disconnect();
  Future<bool> isConnected();
  Future<Map<String, dynamic>> getTunnelStats();
  Future<void> extendSession(Duration duration, {String? publicIp});
}
