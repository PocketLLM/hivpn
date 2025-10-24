// coverage:ignore-file
// MANUALLY AUTHORED FREEZED-LIKE OUTPUT
// ignore_for_file: type=lint

part of 'server.dart';

mixin _$Server {
  String get id => throw UnimplementedError();
  String get name => throw UnimplementedError();
  String get countryCode => throw UnimplementedError();
  String get publicKey => throw UnimplementedError();
  String get endpoint => throw UnimplementedError();
  String get allowedIps => throw UnimplementedError();
  int? get mtu => throw UnimplementedError();
  int? get keepaliveSeconds => throw UnimplementedError();
  Map<String, dynamic> toJson() => throw UnimplementedError();
  @JsonKey(ignore: true)
  $ServerCopyWith<Server> get copyWith => throw UnimplementedError();
}

abstract class $ServerCopyWith<$Res> {
  factory $ServerCopyWith(Server value, $Res Function(Server) then) =
      _$ServerCopyWithImpl<$Res>;
  $Res call({
    String id,
    String name,
    String countryCode,
    String publicKey,
    String endpoint,
    String allowedIps,
    int? mtu,
    int? keepaliveSeconds,
  });
}

class _$ServerCopyWithImpl<$Res> implements $ServerCopyWith<$Res> {
  _$ServerCopyWithImpl(this._value, this._then);

  final Server _value;
  final $Res Function(Server) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? countryCode = freezed,
    Object? publicKey = freezed,
    Object? endpoint = freezed,
    Object? allowedIps = freezed,
    Object? mtu = freezed,
    Object? keepaliveSeconds = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      name: name == freezed ? _value.name : name as String,
      countryCode: countryCode == freezed
          ? _value.countryCode
          : countryCode as String,
      publicKey:
          publicKey == freezed ? _value.publicKey : publicKey as String,
      endpoint: endpoint == freezed ? _value.endpoint : endpoint as String,
      allowedIps:
          allowedIps == freezed ? _value.allowedIps : allowedIps as String,
      mtu: mtu == freezed ? _value.mtu : mtu as int?,
      keepaliveSeconds: keepaliveSeconds == freezed
          ? _value.keepaliveSeconds
          : keepaliveSeconds as int?,
    ));
  }
}

abstract class _$$_ServerCopyWith<$Res> implements $ServerCopyWith<$Res> {
  factory _$$_ServerCopyWith(_$_Server value, $Res Function(_$_Server) then) =
      __$$_ServerCopyWithImpl<$Res>;
  @override
  $Res call({
    String id,
    String name,
    String countryCode,
    String publicKey,
    String endpoint,
    String allowedIps,
    int? mtu,
    int? keepaliveSeconds,
  });
}

class __$$_ServerCopyWithImpl<$Res>
    extends _$ServerCopyWithImpl<$Res>
    implements _$$_ServerCopyWith<$Res> {
  __$$_ServerCopyWithImpl(_$_Server _value, $Res Function(_$_Server) _then)
      : super(_value, (v) => _then(v as _$_Server));

  @override
  _$_Server get _value => super._value as _$_Server;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? countryCode = freezed,
    Object? publicKey = freezed,
    Object? endpoint = freezed,
    Object? allowedIps = freezed,
    Object? mtu = freezed,
    Object? keepaliveSeconds = freezed,
  }) {
    return _then(_$_Server(
      id: id == freezed ? _value.id : id as String,
      name: name == freezed ? _value.name : name as String,
      countryCode: countryCode == freezed
          ? _value.countryCode
          : countryCode as String,
      publicKey:
          publicKey == freezed ? _value.publicKey : publicKey as String,
      endpoint: endpoint == freezed ? _value.endpoint : endpoint as String,
      allowedIps:
          allowedIps == freezed ? _value.allowedIps : allowedIps as String,
      mtu: mtu == freezed ? _value.mtu : mtu as int?,
      keepaliveSeconds: keepaliveSeconds == freezed
          ? _value.keepaliveSeconds
          : keepaliveSeconds as int?,
    ));
  }
}

@JsonSerializable()
class _$_Server extends _Server {
  const _$_Server({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.publicKey,
    required this.endpoint,
    required this.allowedIps,
    this.mtu,
    this.keepaliveSeconds,
  }) : super._();

  factory _$_Server.fromJson(Map<String, dynamic> json) =>
      _$$_ServerFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String countryCode;
  @override
  final String publicKey;
  @override
  final String endpoint;
  @override
  final String allowedIps;
  @override
  final int? mtu;
  @override
  final int? keepaliveSeconds;

  @override
  Map<String, dynamic> toJson() {
    return _$$_ServerToJson(this);
  }

  @override
  _$$_ServerCopyWith<_$_Server> get copyWith =>
      __$$_ServerCopyWithImpl<_$_Server>(this, _$identity);

  @override
  String toString() {
    return 'Server(id: $id, name: $name, countryCode: $countryCode, publicKey: $publicKey, endpoint: $endpoint, allowedIps: $allowedIps, mtu: $mtu, keepaliveSeconds: $keepaliveSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _$_Server &&
            id == other.id &&
            name == other.name &&
            countryCode == other.countryCode &&
            publicKey == other.publicKey &&
            endpoint == other.endpoint &&
            allowedIps == other.allowedIps &&
            mtu == other.mtu &&
            keepaliveSeconds == other.keepaliveSeconds);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        countryCode,
        publicKey,
        endpoint,
        allowedIps,
        mtu,
        keepaliveSeconds,
      );
}

abstract class _Server extends Server {
  const factory _Server({
    required final String id,
    required final String name,
    required final String countryCode,
    required final String publicKey,
    required final String endpoint,
    required final String allowedIps,
    final int? mtu,
    final int? keepaliveSeconds,
  }) = _$_Server;
  const _Server._() : super._();

  factory _Server.fromJson(Map<String, dynamic> json) = _$_Server.fromJson;
}

T _$identity<T>(T value) => value;
