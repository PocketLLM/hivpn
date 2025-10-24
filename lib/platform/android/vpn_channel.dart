import 'package:flutter/services.dart';

import '../../services/vpn/vpn_port.dart';
import '../../services/vpn/wg_config.dart';

class AndroidVpnChannel implements VpnPort {
  AndroidVpnChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.example.vpn/VpnChannel');

  final MethodChannel _channel;

  @override
  Future<bool> prepare() async {
    final result = await _channel.invokeMethod<bool>('prepare');
    return result ?? false;
  }

  @override
  Future<bool> connect(WgConfig config) async {
    final result = await _channel.invokeMethod<bool>(
      'connect',
      config.toJson(),
    );
    return result ?? false;
  }

  @override
  Future<void> disconnect() async {
    await _channel.invokeMethod<void>('disconnect');
  }

  @override
  Future<bool> isConnected() async {
    final result = await _channel.invokeMethod<bool>('isConnected');
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>> getTunnelStats() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('getTunnelStats');
    return result ?? <String, dynamic>{};
  }
}
