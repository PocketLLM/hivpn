// MANUAL JSON SERIALIZATION
// ignore_for_file: type=lint

part of 'session_state.dart';

SessionState _$SessionStateFromJson(Map<String, dynamic> json) =>
    _$_SessionState.fromJson(json);

Map<String, dynamic> _$SessionStateToJson(SessionState instance) =>
    instance.toJson();

_$_SessionState _$$_SessionStateFromJson(Map<String, dynamic> json) =>
  _$_SessionState(
      status: $enumDecode(_$SessionStatusEnumMap, json['status']),
      start:
          json['start'] == null ? null : DateTime.parse(json['start'] as String),
      duration: _durationFromJson(json['duration'] as int?),
      startElapsedMs: (json['startElapsedMs'] as num?)?.toInt(),
      serverId: json['serverId'] as String?,
      serverName: json['serverName'] as String?,
      countryCode: json['countryCode'] as String?,
      publicIp: json['publicIp'] as String?,
      errorMessage: json['errorMessage'] as String?,
      expired: json['expired'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
    );

Map<String, dynamic> _$$_SessionStateToJson(_$_SessionState instance) =>
    <String, dynamic>{
      'status': _$SessionStatusEnumMap[instance.status]!,
      'start': instance.start?.toIso8601String(),
      'duration': _durationToJson(instance.duration),
      'startElapsedMs': instance.startElapsedMs,
      'serverId': instance.serverId,
      'serverName': instance.serverName,
      'countryCode': instance.countryCode,
      'publicIp': instance.publicIp,
      'errorMessage': instance.errorMessage,
      'expired': instance.expired,
      'locked': instance.locked,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.disconnected: 'disconnected',
  SessionStatus.preparing: 'preparing',
  SessionStatus.connecting: 'connecting',
  SessionStatus.connected: 'connected',
  SessionStatus.error: 'error',
};

T $enumDecode<T>(Map<T, dynamic> enumValues, Object? source,
    {T? unknownValue}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final entry = enumValues.entries.singleWhere(
    (element) => element.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError('`$source` is not one of the supported values: '
            '${enumValues.values.join(', ')}');
      }
      return MapEntry<T, dynamic>(unknownValue, enumValues.values.first);
    },
  );

  return entry.key;
}

T? $enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source,
    {T? unknownValue}) {
  if (source == null) {
    return null;
  }
  return $enumDecode(enumValues, source, unknownValue: unknownValue);
}
