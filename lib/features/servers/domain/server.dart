import 'package:freezed_annotation/freezed_annotation.dart';

part 'server.freezed.dart';
part 'server.g.dart';

@freezed
class Server with _$Server {
  const Server._();
  const factory Server({
    required String id,
    required String name,
    required String countryCode,
    required String publicKey,
    required String endpoint,
    required String allowedIps,
    int? mtu,
    int? keepaliveSeconds,
  }) = _Server;

  factory Server.fromJson(Map<String, dynamic> json) =>
      _$ServerFromJson(json);
}
