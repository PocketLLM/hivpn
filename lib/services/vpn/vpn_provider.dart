import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/android/vpn_channel.dart';
import 'vpn_port.dart';
import 'wg_config.dart';

final vpnPortProvider = Provider<VpnPort>((ref) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidVpnChannel();
  }
  return _UnsupportedVpnPort();
});

class _UnsupportedVpnPort implements VpnPort {
  @override
  bool get isSupported => false;

  @override
  Stream<String> get intentActions => const Stream<String>.empty();

  @override
  Future<bool> connect(WgConfig config) async => false;

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> extendSession(Duration duration, {String? publicIp}) async {}

  @override
  Future<Map<String, dynamic>> getTunnelStats() async => <String, dynamic>{};

  @override
  Future<bool> isConnected() async => false;

  @override
  Future<bool> prepare() async => false;
}
