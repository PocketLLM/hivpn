import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../services/vpn/wg_config.dart';
import 'session_status.dart';

part 'session_state.freezed.dart';
part 'session_state.g.dart';

@freezed
class SessionState with _$SessionState {
  const SessionState._();
  const factory SessionState({
    required SessionStatus status,
    DateTime? start,
    @JsonKey(
      fromJson: _durationFromJson,
      toJson: _durationToJson,
    )
    Duration? duration,
    int? startElapsedMs,
    String? serverId,
    String? serverName,
    String? countryCode,
    String? publicIp,
    String? errorMessage,
    @JsonKey(ignore: true) WgConfig? config,
    @Default(false) bool expired,
    @Default(false) bool locked,
  }) = _SessionState;

  factory SessionState.initial() =>
      const SessionState(status: SessionStatus.disconnected);

  factory SessionState.fromJson(Map<String, dynamic> json) =>
      _$SessionStateFromJson(json);
}

Duration? _durationFromJson(int? seconds) {
  if (seconds == null) return null;
  return Duration(seconds: seconds);
}

int? _durationToJson(Duration? duration) {
  return duration?.inSeconds;
}
