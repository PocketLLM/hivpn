// GENERATED CODE - MANUALLY CREATED
// ignore_for_file: type=lint

part of 'wg_config.dart';

WgConfig _$WgConfigFromJson(Map<String, dynamic> json) =>
    _$_WgConfig.fromJson(json);

Map<String, dynamic> _$WgConfigToJson(WgConfig instance) => instance.toJson();

_$_WgConfig _$$_WgConfigFromJson(Map<String, dynamic> json) => _$_WgConfig(
      interfacePrivateKey: json['interfacePrivateKey'] as String,
      interfaceAddress: json['interfaceAddress'] as String?,
      interfaceDns: json['interfaceDns'] as String?,
      peerPublicKey: json['peerPublicKey'] as String,
      peerAllowedIps: json['peerAllowedIps'] as String,
      peerEndpoint: json['peerEndpoint'] as String,
      peerPersistentKeepalive: json['peerPersistentKeepalive'] as int?,
      mtu: json['mtu'] as int?,
    );

Map<String, dynamic> _$$_WgConfigToJson(_$_WgConfig instance) =>
    <String, dynamic>{
      'interfacePrivateKey': instance.interfacePrivateKey,
      'interfaceAddress': instance.interfaceAddress,
      'interfaceDns': instance.interfaceDns,
      'peerPublicKey': instance.peerPublicKey,
      'peerAllowedIps': instance.peerAllowedIps,
      'peerEndpoint': instance.peerEndpoint,
      'peerPersistentKeepalive': instance.peerPersistentKeepalive,
      'mtu': instance.mtu,
    };
