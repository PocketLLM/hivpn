import 'dart:async';

import 'package:flutter/services.dart';

import '../../services/vpn/vpn_port.dart';
import '../../services/vpn/wg_config.dart';

class AndroidVpnChannel implements VpnPort {
  factory AndroidVpnChannel({MethodChannel? channel}) {
    _instance ??= AndroidVpnChannel._(
      channel ?? const MethodChannel('com.example.vpn/VpnChannel'),
    );
    return _instance!;
  }

  AndroidVpnChannel._(MethodChannel channel) : _channel = channel {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static AndroidVpnChannel? _instance;

  MethodChannel _channel;
  final StreamController<String> _intentActionsController =
      StreamController<String>.broadcast();

  @override
  bool get isSupported => true;

  @override
  Stream<String> get intentActions => _intentActionsController.stream;

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'notifyIntentAction':
        final action = call.arguments as String?;
        if (action != null && action.isNotEmpty) {
          _intentActionsController.add(action);
        }
        return;
      default:
        return;
    }
  }

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

  @override
  Future<void> extendSession(Duration duration, {String? publicIp}) async {
    await _channel.invokeMethod<void>('extendSession', {
      'durationMs': duration.inMilliseconds,
      if (publicIp != null) 'publicIp': publicIp,
    });
  }
}
