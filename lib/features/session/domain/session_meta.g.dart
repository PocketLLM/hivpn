// MANUAL JSON SERIALIZATION
// ignore_for_file: type=lint

part of 'session_meta.dart';

SessionMeta _$SessionMetaFromJson(Map<String, dynamic> json) =>
    _$_SessionMeta.fromJson(json);

Map<String, dynamic> _$SessionMetaToJson(SessionMeta instance) =>
    instance.toJson();

_$_SessionMeta _$$_SessionMetaFromJson(Map<String, dynamic> json) =>
    _$_SessionMeta(
      serverId: json['serverId'] as String,
      serverName: json['serverName'] as String,
      countryCode: json['countryCode'] as String,
      startElapsedMs: (json['startElapsedMs'] as num).toInt(),
      durationMs: (json['durationMs'] as num).toInt(),
      publicIp: json['publicIp'] as String?,
    );

Map<String, dynamic> _$$_SessionMetaToJson(_$_SessionMeta instance) =>
    <String, dynamic>{
      'serverId': instance.serverId,
      'serverName': instance.serverName,
      'countryCode': instance.countryCode,
      'startElapsedMs': instance.startElapsedMs,
      'durationMs': instance.durationMs,
      'publicIp': instance.publicIp,
    };
