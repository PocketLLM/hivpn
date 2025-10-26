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
      hostName: json['hostName'] as String?,
      ip: json['ip'] as String?,
      pingMs: json['pingMs'] as int?,
      bandwidth: json['bandwidth'] as int?,
      sessions: json['sessions'] as int?,
      openVpnConfigDataBase64: json['openVpnConfigDataBase64'] as String?,
      regionName: json['regionName'] as String?,
      cityName: json['cityName'] as String?,
      score: (json['score'] as num?)?.toDouble(),
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
      'hostName': instance.hostName,
      'ip': instance.ip,
      'pingMs': instance.pingMs,
      'bandwidth': instance.bandwidth,
      'sessions': instance.sessions,
      'openVpnConfigDataBase64': instance.openVpnConfigDataBase64,
      'regionName': instance.regionName,
      'cityName': instance.cityName,
      'score': instance.score,
    };
