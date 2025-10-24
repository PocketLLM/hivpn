import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_meta.freezed.dart';
part 'session_meta.g.dart';

@freezed
class SessionMeta with _$SessionMeta {
  const SessionMeta._();

  const factory SessionMeta({
    required String serverId,
    required String serverName,
    required String countryCode,
    required int startElapsedMs,
    required int durationMs,
    String? publicIp,
  }) = _SessionMeta;

  Duration get duration => Duration(milliseconds: durationMs);

  factory SessionMeta.fromJson(Map<String, dynamic> json) =>
      _$SessionMetaFromJson(json);

  SessionMeta extend(Duration extra) {
    return copyWith(durationMs: durationMs + extra.inMilliseconds);
  }
}
