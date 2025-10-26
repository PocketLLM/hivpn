import 'session_meta.dart';
import 'session_status.dart';

const _kUnset = Object();

class SessionState {
  const SessionState({
    required this.status,
    this.start,
    this.duration,
    this.startElapsedMs,
    this.serverId,
    this.serverName,
    this.countryCode,
    this.publicIp,
    this.errorMessage,
    this.expired = false,
    this.meta,
    this.sessionLocked = false,
    this.queuedServerId,
    this.extendRequested = false,
  });

  final SessionStatus status;
  final DateTime? start;
  final Duration? duration;
  final int? startElapsedMs;
  final String? serverId;
  final String? serverName;
  final String? countryCode;
  final String? publicIp;
  final String? errorMessage;
  final bool expired;
  final SessionMeta? meta;
  final bool sessionLocked;
  final String? queuedServerId;
  final bool extendRequested;

  factory SessionState.initial() =>
      const SessionState(status: SessionStatus.disconnected);

  SessionState copyWith({
    Object? status = _kUnset,
    Object? start = _kUnset,
    Object? duration = _kUnset,
    Object? startElapsedMs = _kUnset,
    Object? serverId = _kUnset,
    Object? serverName = _kUnset,
    Object? countryCode = _kUnset,
    Object? publicIp = _kUnset,
    Object? errorMessage = _kUnset,
    Object? expired = _kUnset,
    Object? meta = _kUnset,
    Object? sessionLocked = _kUnset,
    Object? queuedServerId = _kUnset,
    Object? extendRequested = _kUnset,
  }) {
    return SessionState(
      status: status == _kUnset ? this.status : status as SessionStatus,
      start: start == _kUnset ? this.start : start as DateTime?,
      duration: duration == _kUnset ? this.duration : duration as Duration?,
      startElapsedMs: startElapsedMs == _kUnset
          ? this.startElapsedMs
          : startElapsedMs as int?,
      serverId: serverId == _kUnset ? this.serverId : serverId as String?,
      serverName:
          serverName == _kUnset ? this.serverName : serverName as String?,
      countryCode:
          countryCode == _kUnset ? this.countryCode : countryCode as String?,
      publicIp: publicIp == _kUnset ? this.publicIp : publicIp as String?,
      errorMessage: errorMessage == _kUnset
          ? this.errorMessage
          : errorMessage as String?,
      expired: expired == _kUnset ? this.expired : expired as bool,
      meta: meta == _kUnset ? this.meta : meta as SessionMeta?,
      sessionLocked: sessionLocked == _kUnset
          ? this.sessionLocked
          : sessionLocked as bool,
      queuedServerId: queuedServerId == _kUnset
          ? this.queuedServerId
          : queuedServerId as String?,
      extendRequested: extendRequested == _kUnset
          ? this.extendRequested
          : extendRequested as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'start': start?.toIso8601String(),
      'duration': _durationToJson(duration),
      'startElapsedMs': startElapsedMs,
      'serverId': serverId,
      'serverName': serverName,
      'countryCode': countryCode,
      'publicIp': publicIp,
      'errorMessage': errorMessage,
      'expired': expired,
      'meta': meta?.toJson(),
      'sessionLocked': sessionLocked,
      'queuedServerId': queuedServerId,
      'extendRequested': extendRequested,
    };
  }

  factory SessionState.fromJson(Map<String, dynamic> json) {
    return SessionState(
      status: _statusFromJson(json['status']),
      start: json['start'] != null
          ? DateTime.parse(json['start'] as String)
          : null,
      duration: _durationFromJson(json['duration'] as int?),
      startElapsedMs: (json['startElapsedMs'] as num?)?.toInt(),
      serverId: json['serverId'] as String?,
      serverName: json['serverName'] as String?,
      countryCode: json['countryCode'] as String?,
      publicIp: json['publicIp'] as String?,
      errorMessage: json['errorMessage'] as String?,
      expired: json['expired'] as bool? ?? false,
      meta: json['meta'] is Map<String, dynamic>
          ? SessionMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      sessionLocked: json['sessionLocked'] as bool? ?? false,
      queuedServerId: json['queuedServerId'] as String?,
      extendRequested: json['extendRequested'] as bool? ?? false,
    );
  }

  static SessionStatus _statusFromJson(dynamic value) {
    if (value is String) {
      return SessionStatus.values.firstWhere(
        (element) => element.name == value,
        orElse: () => SessionStatus.disconnected,
      );
    }
    if (value is int) {
      return SessionStatus.values[value];
    }
    return SessionStatus.disconnected;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionState &&
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
        meta == other.meta &&
        sessionLocked == other.sessionLocked &&
        queuedServerId == other.queuedServerId &&
        extendRequested == other.extendRequested;
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
        meta,
        sessionLocked,
        queuedServerId,
        extendRequested,
      );
}

Duration? _durationFromJson(int? seconds) {
  if (seconds == null) return null;
  return Duration(seconds: seconds);
}

int? _durationToJson(Duration? duration) {
  return duration?.inSeconds;
}
