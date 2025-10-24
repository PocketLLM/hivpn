// coverage:ignore-file
// MANUAL FREEZED OUTPUT
// ignore_for_file: type=lint

part of 'session_meta.dart';

mixin _$SessionMeta {
  String get serverId => throw UnimplementedError();
  String get serverName => throw UnimplementedError();
  String get countryCode => throw UnimplementedError();
  int get startElapsedMs => throw UnimplementedError();
  int get durationMs => throw UnimplementedError();
  String? get publicIp => throw UnimplementedError();
  Map<String, dynamic> toJson() => throw UnimplementedError();
  @JsonKey(ignore: true)
  $SessionMetaCopyWith<SessionMeta> get copyWith => throw UnimplementedError();
}

abstract class $SessionMetaCopyWith<$Res> {
  factory $SessionMetaCopyWith(SessionMeta value, $Res Function(SessionMeta) then) =
      _$SessionMetaCopyWithImpl<$Res>;
  $Res call({
    String serverId,
    String serverName,
    String countryCode,
    int startElapsedMs,
    int durationMs,
    String? publicIp,
  });
}

class _$SessionMetaCopyWithImpl<$Res> implements $SessionMetaCopyWith<$Res> {
  _$SessionMetaCopyWithImpl(this._value, this._then);

  final SessionMeta _value;
  final $Res Function(SessionMeta) _then;

  @override
  $Res call({
    Object? serverId = freezed,
    Object? serverName = freezed,
    Object? countryCode = freezed,
    Object? startElapsedMs = freezed,
    Object? durationMs = freezed,
    Object? publicIp = freezed,
  }) {
    return _then(_value.copyWith(
      serverId: serverId == freezed ? _value.serverId : serverId as String,
      serverName: serverName == freezed ? _value.serverName : serverName as String,
      countryCode: countryCode == freezed ? _value.countryCode : countryCode as String,
      startElapsedMs: startElapsedMs == freezed
          ? _value.startElapsedMs
          : startElapsedMs as int,
      durationMs:
          durationMs == freezed ? _value.durationMs : durationMs as int,
      publicIp: publicIp == freezed ? _value.publicIp : publicIp as String?,
    ));
  }
}

abstract class _$$_SessionMetaCopyWith<$Res> implements $SessionMetaCopyWith<$Res> {
  factory _$$_SessionMetaCopyWith(_$_SessionMeta value, $Res Function(_$_SessionMeta) then) =
      __$$_SessionMetaCopyWithImpl<$Res>;
  @override
  $Res call({
    String serverId,
    String serverName,
    String countryCode,
    int startElapsedMs,
    int durationMs,
    String? publicIp,
  });
}

class __$$_SessionMetaCopyWithImpl<$Res>
    extends _$SessionMetaCopyWithImpl<$Res>
    implements _$$_SessionMetaCopyWith<$Res> {
  __$$_SessionMetaCopyWithImpl(_$_SessionMeta _value, $Res Function(_$_SessionMeta) _then)
      : super(_value, (v) => _then(v as _$_SessionMeta));

  @override
  _$_SessionMeta get _value => super._value as _$_SessionMeta;

  @override
  $Res call({
    Object? serverId = freezed,
    Object? serverName = freezed,
    Object? countryCode = freezed,
    Object? startElapsedMs = freezed,
    Object? durationMs = freezed,
    Object? publicIp = freezed,
  }) {
    return _then(_$_SessionMeta(
      serverId: serverId == freezed ? _value.serverId : serverId as String,
      serverName: serverName == freezed ? _value.serverName : serverName as String,
      countryCode: countryCode == freezed ? _value.countryCode : countryCode as String,
      startElapsedMs: startElapsedMs == freezed
          ? _value.startElapsedMs
          : startElapsedMs as int,
      durationMs:
          durationMs == freezed ? _value.durationMs : durationMs as int,
      publicIp: publicIp == freezed ? _value.publicIp : publicIp as String?,
    ));
  }
}

@JsonSerializable()
class _$_SessionMeta extends _SessionMeta {
  const _$_SessionMeta({
    required this.serverId,
    required this.serverName,
    required this.countryCode,
    required this.startElapsedMs,
    required this.durationMs,
    this.publicIp,
  }) : super._();

  factory _$_SessionMeta.fromJson(Map<String, dynamic> json) =>
      _$$_SessionMetaFromJson(json);

  @override
  final String serverId;
  @override
  final String serverName;
  @override
  final String countryCode;
  @override
  final int startElapsedMs;
  @override
  final int durationMs;
  @override
  final String? publicIp;

  @override
  Map<String, dynamic> toJson() {
    return _$$_SessionMetaToJson(this);
  }

  @override
  _$$_SessionMetaCopyWith<_$_SessionMeta> get copyWith =>
      __$$_SessionMetaCopyWithImpl<_$_SessionMeta>(this, _$identity);

  @override
  String toString() {
    return 'SessionMeta(serverId: $serverId, serverName: $serverName, countryCode: $countryCode, startElapsedMs: $startElapsedMs, durationMs: $durationMs, publicIp: $publicIp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _$_SessionMeta &&
            serverId == other.serverId &&
            serverName == other.serverName &&
            countryCode == other.countryCode &&
            startElapsedMs == other.startElapsedMs &&
            durationMs == other.durationMs &&
            publicIp == other.publicIp);
  }

  @override
  int get hashCode => Object.hash(
        serverId,
        serverName,
        countryCode,
        startElapsedMs,
        durationMs,
        publicIp,
      );
}

abstract class _SessionMeta extends SessionMeta {
  const factory _SessionMeta({
    required final String serverId,
    required final String serverName,
    required final String countryCode,
    required final int startElapsedMs,
    required final int durationMs,
    final String? publicIp,
  }) = _$_SessionMeta;
  const _SessionMeta._() : super._();

  factory _SessionMeta.fromJson(Map<String, dynamic> json) =
      _$_SessionMeta.fromJson;
}

T _$identity<T>(T value) => value;
