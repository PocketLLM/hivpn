import 'dart:async';

import 'wg_config.dart';

abstract class VpnPort {
  Stream<String> get intentActions;
  Future<bool> prepare();
  Future<bool> connect(WgConfig config);
  Future<void> disconnect();
  Future<bool> isConnected();
  Future<Map<String, dynamic>> getTunnelStats();
  Future<void> extendSession(Duration duration, {String? publicIp});
}
