// MANUAL JSON SUPPORT - GENERATED STYLE
// ignore_for_file: type=lint

part of 'server.dart';

Server _$ServerFromJson(Map<String, dynamic> json) => _$_Server.fromJson(json);

Map<String, dynamic> _$ServerToJson(Server instance) => instance.toJson();

_$_Server _$$_ServerFromJson(Map<String, dynamic> json) => _$_Server(
      id: json['id'] as String,
      name: json['name'] as String,
      countryCode: json['countryCode'] as String,
      publicKey: json['publicKey'] as String,
      endpoint: json['endpoint'] as String,
      allowedIps: json['allowedIps'] as String,
      mtu: json['mtu'] as int?,
      keepaliveSeconds: json['keepaliveSeconds'] as int?,
    );

Map<String, dynamic> _$$_ServerToJson(_$_Server instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'countryCode': instance.countryCode,
      'publicKey': instance.publicKey,
      'endpoint': instance.endpoint,
      'allowedIps': instance.allowedIps,
      'mtu': instance.mtu,
      'keepaliveSeconds': instance.keepaliveSeconds,
    };
