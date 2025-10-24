import 'package:freezed_annotation/freezed_annotation.dart';

part 'wg_config.freezed.dart';
part 'wg_config.g.dart';

@freezed
class WgConfig with _$WgConfig {
  const WgConfig._();
  const factory WgConfig({
    required String interfacePrivateKey,
    String? interfaceAddress,
    String? interfaceDns,
    required String peerPublicKey,
    required String peerAllowedIps,
    required String peerEndpoint,
    int? peerPersistentKeepalive,
    int? mtu,
  }) = _WgConfig;

  factory WgConfig.fromJson(Map<String, dynamic> json) =>
      _$WgConfigFromJson(json);
}
