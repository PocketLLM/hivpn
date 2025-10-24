// coverage:ignore-file
// MANUAL FREEZED OUTPUT
// ignore_for_file: type=lint

part of 'session_state.dart';

mixin _$SessionState {
  SessionStatus get status => throw UnimplementedError();
  DateTime? get start => throw UnimplementedError();
  Duration? get duration => throw UnimplementedError();
  String? get serverId => throw UnimplementedError();
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
    String? serverId,
    String? errorMessage,
    WgConfig? config,
    bool expired,
    SessionMeta? meta,
    bool sessionLocked,
    String? queuedServerId,
    bool extendRequested,
    String? publicIp,
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
    Object? serverId = freezed,
    Object? errorMessage = freezed,
    Object? config = freezed,
    Object? expired = freezed,
    Object? meta = freezed,
    Object? sessionLocked = freezed,
    Object? queuedServerId = freezed,
    Object? extendRequested = freezed,
    Object? publicIp = freezed,
  }) {
    return _then(_value.copyWith(
      status: status == freezed ? _value.status : status as SessionStatus,
      start: start == freezed ? _value.start : start as DateTime?,
      duration: duration == freezed ? _value.duration : duration as Duration?,
      serverId: serverId == freezed ? _value.serverId : serverId as String?,
      errorMessage: errorMessage == freezed
          ? _value.errorMessage
          : errorMessage as String?,
      config: config == freezed ? _value.config : config as WgConfig?,
      expired: expired == freezed ? _value.expired : expired as bool,
      meta: meta == freezed ? _value.meta : meta as SessionMeta?,
      sessionLocked: sessionLocked == freezed
          ? _value.sessionLocked
          : sessionLocked as bool,
      queuedServerId: queuedServerId == freezed
          ? _value.queuedServerId
          : queuedServerId as String?,
      extendRequested: extendRequested == freezed
          ? _value.extendRequested
          : extendRequested as bool,
      publicIp: publicIp == freezed ? _value.publicIp : publicIp as String?,
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
    String? serverId,
    String? errorMessage,
    WgConfig? config,
    bool expired,
    SessionMeta? meta,
    bool sessionLocked,
    String? queuedServerId,
    bool extendRequested,
    String? publicIp,
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
    Object? serverId = freezed,
    Object? errorMessage = freezed,
    Object? config = freezed,
    Object? expired = freezed,
    Object? meta = freezed,
    Object? sessionLocked = freezed,
    Object? queuedServerId = freezed,
    Object? extendRequested = freezed,
    Object? publicIp = freezed,
  }) {
    return _then(_$_SessionState(
      status: status == freezed ? _value.status : status as SessionStatus,
      start: start == freezed ? _value.start : start as DateTime?,
      duration: duration == freezed ? _value.duration : duration as Duration?,
      serverId: serverId == freezed ? _value.serverId : serverId as String?,
      errorMessage: errorMessage == freezed
          ? _value.errorMessage
          : errorMessage as String?,
      config: config == freezed ? _value.config : config as WgConfig?,
      expired: expired == freezed ? _value.expired : expired as bool,
      meta: meta == freezed ? _value.meta : meta as SessionMeta?,
      sessionLocked: sessionLocked == freezed
          ? _value.sessionLocked
          : sessionLocked as bool,
      queuedServerId: queuedServerId == freezed
          ? _value.queuedServerId
          : queuedServerId as String?,
      extendRequested: extendRequested == freezed
          ? _value.extendRequested
          : extendRequested as bool,
      publicIp: publicIp == freezed ? _value.publicIp : publicIp as String?,
    ));
  }
}

@JsonSerializable()
class _$_SessionState extends _SessionState {
  const _$_SessionState({
    required this.status,
    this.start,
    this.duration,
    this.serverId,
    this.errorMessage,
    @JsonKey(ignore: true) this.config,
    this.expired = false,
    this.meta,
    this.sessionLocked = false,
    this.queuedServerId,
    this.extendRequested = false,
    this.publicIp,
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
  final String? serverId;
  @override
  final String? errorMessage;
  @override
  @JsonKey(ignore: true)
  final WgConfig? config;
  @override
  @JsonKey()
  final bool expired;
  @override
  final SessionMeta? meta;
  @override
  @JsonKey()
  final bool sessionLocked;
  @override
  final String? queuedServerId;
  @override
  @JsonKey()
  final bool extendRequested;
  @override
  final String? publicIp;

  @override
  Map<String, dynamic> toJson() {
    return _$$_SessionStateToJson(this);
  }

  @override
  _$$_SessionStateCopyWith<_$_SessionState> get copyWith =>
      __$$_SessionStateCopyWithImpl<_$_SessionState>(this, _$identity);

  @override
  String toString() {
    return 'SessionState(status: $status, start: $start, duration: $duration, serverId: $serverId, errorMessage: $errorMessage, expired: $expired, meta: $meta, sessionLocked: $sessionLocked, queuedServerId: $queuedServerId, extendRequested: $extendRequested, publicIp: $publicIp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _$_SessionState &&
            status == other.status &&
            start == other.start &&
            duration == other.duration &&
            serverId == other.serverId &&
            errorMessage == other.errorMessage &&
            expired == other.expired &&
            meta == other.meta &&
            sessionLocked == other.sessionLocked &&
            queuedServerId == other.queuedServerId &&
            extendRequested == other.extendRequested &&
            publicIp == other.publicIp);
  }

  @override
  int get hashCode => Object.hash(
        status,
        start,
        duration,
        serverId,
        errorMessage,
        expired,
        meta,
        sessionLocked,
        queuedServerId,
        extendRequested,
        publicIp,
      );
}

abstract class _SessionState extends SessionState {
  const factory _SessionState({
    required final SessionStatus status,
    final DateTime? start,
    final Duration? duration,
    final String? serverId,
    final String? errorMessage,
    @JsonKey(ignore: true) final WgConfig? config,
    final bool expired,
    final SessionMeta? meta,
    final bool sessionLocked,
    final String? queuedServerId,
    final bool extendRequested,
    final String? publicIp,
  }) = _$_SessionState;
  const _SessionState._() : super._();

  factory _SessionState.fromJson(Map<String, dynamic> json) =
      _$_SessionState.fromJson;
}

T _$identity<T>(T value) => value;
