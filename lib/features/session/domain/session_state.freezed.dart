// coverage:ignore-file
// MANUAL FREEZED OUTPUT
// ignore_for_file: type=lint

part of 'session_state.dart';

mixin _$SessionState {
  SessionStatus get status => throw UnimplementedError();
  DateTime? get start => throw UnimplementedError();
  Duration? get duration => throw UnimplementedError();
  int? get startElapsedMs => throw UnimplementedError();
  String? get serverId => throw UnimplementedError();
  String? get serverName => throw UnimplementedError();
  String? get countryCode => throw UnimplementedError();
  String? get publicIp => throw UnimplementedError();
  String? get errorMessage => throw UnimplementedError();
  @JsonKey(ignore: true)
  WgConfig? get config => throw UnimplementedError();
  bool get expired => throw UnimplementedError();
  SessionMeta? get meta => throw UnimplementedError();
  bool get sessionLocked => throw UnimplementedError();
  String? get queuedServerId => throw UnimplementedError();
  bool get extendRequested => throw UnimplementedError();
  String? get publicIp => throw UnimplementedError();
  Map<String, dynamic> toJson() => throw UnimplementedError();
  @JsonKey(ignore: true)
  $SessionStateCopyWith<SessionState> get copyWith =>
      throw UnimplementedError();
}

abstract class $SessionStateCopyWith<$Res> {
  factory $SessionStateCopyWith(
          SessionState value, $Res Function(SessionState) then) =
      _$SessionStateCopyWithImpl<$Res>;
  $Res call({
    SessionStatus status,
    DateTime? start,
    Duration? duration,
    int? startElapsedMs,
    String? serverId,
    String? serverName,
    String? countryCode,
    String? publicIp,
    String? errorMessage,
    WgConfig? config,
    bool expired,
    bool locked,
  });
}

class _$SessionStateCopyWithImpl<$Res> implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._value, this._then);

  final SessionState _value;
  final $Res Function(SessionState) _then;

  @override
  $Res call({
    Object? status = freezed,
    Object? start = freezed,
    Object? duration = freezed,
    Object? startElapsedMs = freezed,
    Object? serverId = freezed,
    Object? serverName = freezed,
    Object? countryCode = freezed,
    Object? publicIp = freezed,
    Object? errorMessage = freezed,
    Object? config = freezed,
    Object? expired = freezed,
    Object? locked = freezed,
  }) {
    return _then(_value.copyWith(
      status: status == freezed ? _value.status : status as SessionStatus,
      start: start == freezed ? _value.start : start as DateTime?,
      duration: duration == freezed ? _value.duration : duration as Duration?,
      startElapsedMs: startElapsedMs == freezed
          ? _value.startElapsedMs
          : startElapsedMs as int?,
      serverId: serverId == freezed ? _value.serverId : serverId as String?,
      serverName:
          serverName == freezed ? _value.serverName : serverName as String?,
      countryCode: countryCode == freezed
          ? _value.countryCode
          : countryCode as String?,
      publicIp:
          publicIp == freezed ? _value.publicIp : publicIp as String?,
      errorMessage: errorMessage == freezed
          ? _value.errorMessage
          : errorMessage as String?,
      config: config == freezed ? _value.config : config as WgConfig?,
      expired: expired == freezed ? _value.expired : expired as bool,
      locked: locked == freezed ? _value.locked : locked as bool,
    ));
  }
}

abstract class _$$_SessionStateCopyWith<$Res>
    implements $SessionStateCopyWith<$Res> {
  factory _$$_SessionStateCopyWith(
          _$_SessionState value, $Res Function(_$_SessionState) then) =
      __$$_SessionStateCopyWithImpl<$Res>;
  @override
  $Res call({
    SessionStatus status,
    DateTime? start,
    Duration? duration,
    int? startElapsedMs,
    String? serverId,
    String? serverName,
    String? countryCode,
    String? publicIp,
    String? errorMessage,
    WgConfig? config,
    bool expired,
    bool locked,
  });
}

class __$$_SessionStateCopyWithImpl<$Res>
    extends _$SessionStateCopyWithImpl<$Res>
    implements _$$_SessionStateCopyWith<$Res> {
  __$$_SessionStateCopyWithImpl(
      _$_SessionState _value, $Res Function(_$_SessionState) _then)
      : super(_value, (v) => _then(v as _$_SessionState));

  @override
  _$_SessionState get _value => super._value as _$_SessionState;

  @override
  $Res call({
    Object? status = freezed,
    Object? start = freezed,
    Object? duration = freezed,
    Object? startElapsedMs = freezed,
    Object? serverId = freezed,
    Object? serverName = freezed,
    Object? countryCode = freezed,
    Object? publicIp = freezed,
    Object? errorMessage = freezed,
    Object? config = freezed,
    Object? expired = freezed,
    Object? locked = freezed,
  }) {
    return _then(_$_SessionState(
      status: status == freezed ? _value.status : status as SessionStatus,
      start: start == freezed ? _value.start : start as DateTime?,
      duration: duration == freezed ? _value.duration : duration as Duration?,
      startElapsedMs: startElapsedMs == freezed
          ? _value.startElapsedMs
          : startElapsedMs as int?,
      serverId: serverId == freezed ? _value.serverId : serverId as String?,
      serverName:
          serverName == freezed ? _value.serverName : serverName as String?,
      countryCode: countryCode == freezed
          ? _value.countryCode
          : countryCode as String?,
      publicIp:
          publicIp == freezed ? _value.publicIp : publicIp as String?,
      errorMessage: errorMessage == freezed
          ? _value.errorMessage
          : errorMessage as String?,
      config: config == freezed ? _value.config : config as WgConfig?,
      expired: expired == freezed ? _value.expired : expired as bool,
      locked: locked == freezed ? _value.locked : locked as bool,
    ));
  }
}

@JsonSerializable()
class _$_SessionState extends _SessionState {
  const _$_SessionState({
    required this.status,
    this.start,
    this.duration,
    this.startElapsedMs,
    this.serverId,
    this.serverName,
    this.countryCode,
    this.publicIp,
    this.errorMessage,
    @JsonKey(ignore: true) this.config,
    this.expired = false,
    this.locked = false,
  }) : super._();

  factory _$_SessionState.fromJson(Map<String, dynamic> json) =>
      _$$_SessionStateFromJson(json);

  @override
  final SessionStatus status;
  @override
  final DateTime? start;
  @override
  final Duration? duration;
  @override
  final int? startElapsedMs;
  @override
  final String? serverId;
  @override
  final String? serverName;
  @override
  final String? countryCode;
  @override
  final String? publicIp;
  @override
  final String? errorMessage;
  @override
  @JsonKey(ignore: true)
  final WgConfig? config;
  @override
  @JsonKey()
  final bool expired;
  @override
  @JsonKey()
  final bool locked;

  @override
  Map<String, dynamic> toJson() {
    return _$$_SessionStateToJson(this);
  }

  @override
  _$$_SessionStateCopyWith<_$_SessionState> get copyWith =>
      __$$_SessionStateCopyWithImpl<_$_SessionState>(this, _$identity);

  @override
  String toString() {
    return 'SessionState(status: $status, start: $start, duration: $duration, startElapsedMs: $startElapsedMs, serverId: $serverId, serverName: $serverName, countryCode: $countryCode, publicIp: $publicIp, errorMessage: $errorMessage, expired: $expired, locked: $locked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _$_SessionState &&
            status == other.status &&
            start == other.start &&
            duration == other.duration &&
            startElapsedMs == other.startElapsedMs &&
            serverId == other.serverId &&
            serverName == other.serverName &&
            countryCode == other.countryCode &&
            publicIp == other.publicIp &&
            errorMessage == other.errorMessage &&
            expired == other.expired &&
            locked == other.locked);
  }

  @override
  int get hashCode => Object.hash(
        status,
        start,
        duration,
        startElapsedMs,
        serverId,
        serverName,
        countryCode,
        publicIp,
        errorMessage,
        expired,
        locked,
      );
}

abstract class _SessionState extends SessionState {
  const factory _SessionState({
    required final SessionStatus status,
    final DateTime? start,
    final Duration? duration,
    final int? startElapsedMs,
    final String? serverId,
    final String? serverName,
    final String? countryCode,
    final String? publicIp,
    final String? errorMessage,
    @JsonKey(ignore: true) final WgConfig? config,
    final bool expired,
    final bool locked,
  }) = _$_SessionState;
  const _SessionState._() : super._();

  factory _SessionState.fromJson(Map<String, dynamic> json) =
      _$_SessionState.fromJson;
}

T _$identity<T>(T value) => value;
