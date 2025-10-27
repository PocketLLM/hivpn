import 'dart:async';
import 'package:openvpn_flutter/openvpn_flutter.dart';

import 'models/vpn.dart';
import 'models/vpn_status.dart';

/// Abstract VPN port interface
/// Now supports OpenVPN instead of WireGuard
abstract class VpnPort {
  bool get isSupported;
  Stream<String> get intentActions;
  Stream<VPNStage> get stageStream;
  Stream<VpnStatus> get statusStream;
  Future<bool> prepare();
  Future<bool> connect(Vpn server);
  Future<void> disconnect();
  Future<bool> isConnected();
  Future<Map<String, dynamic>> getTunnelStats();
  Future<void> extendSession(Duration duration, {String? publicIp});
}
