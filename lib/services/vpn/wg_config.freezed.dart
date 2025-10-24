// coverage:ignore-file
// GENERATED CODE - MANUALLY CREATED FOR BUILDLESS ENVIRONMENT.
// ignore_for_file: type=lint

part of 'wg_config.dart';

mixin _$WgConfig {
  String get interfacePrivateKey => throw UnimplementedError();
  String? get interfaceAddress => throw UnimplementedError();
  String? get interfaceDns => throw UnimplementedError();
  String get peerPublicKey => throw UnimplementedError();
  String get peerAllowedIps => throw UnimplementedError();
  String get peerEndpoint => throw UnimplementedError();
  int? get peerPersistentKeepalive => throw UnimplementedError();
  int? get mtu => throw UnimplementedError();
  Map<String, dynamic> toJson() => throw UnimplementedError();
  @JsonKey(ignore: true)
  $WgConfigCopyWith<WgConfig> get copyWith => throw UnimplementedError();
}

abstract class $WgConfigCopyWith<$Res> {
  factory $WgConfigCopyWith(WgConfig value, $Res Function(WgConfig) then) =
      _$WgConfigCopyWithImpl<$Res>;
  $Res call({
    String interfacePrivateKey,
    String? interfaceAddress,
    String? interfaceDns,
    String peerPublicKey,
    String peerAllowedIps,
    String peerEndpoint,
    int? peerPersistentKeepalive,
    int? mtu,
  });
}

class _$WgConfigCopyWithImpl<$Res> implements $WgConfigCopyWith<$Res> {
  _$WgConfigCopyWithImpl(this._value, this._then);

  final WgConfig _value;
  final $Res Function(WgConfig) _then;

  @override
  $Res call({
    Object? interfacePrivateKey = freezed,
    Object? interfaceAddress = freezed,
    Object? interfaceDns = freezed,
    Object? peerPublicKey = freezed,
    Object? peerAllowedIps = freezed,
    Object? peerEndpoint = freezed,
    Object? peerPersistentKeepalive = freezed,
    Object? mtu = freezed,
  }) {
    return _then(_value.copyWith(
      interfacePrivateKey: interfacePrivateKey == freezed
          ? _value.interfacePrivateKey
          : interfacePrivateKey as String,
      interfaceAddress: interfaceAddress == freezed
          ? _value.interfaceAddress
          : interfaceAddress as String?,
      interfaceDns: interfaceDns == freezed
          ? _value.interfaceDns
          : interfaceDns as String?,
      peerPublicKey: peerPublicKey == freezed
          ? _value.peerPublicKey
          : peerPublicKey as String,
      peerAllowedIps: peerAllowedIps == freezed
          ? _value.peerAllowedIps
          : peerAllowedIps as String,
      peerEndpoint: peerEndpoint == freezed
          ? _value.peerEndpoint
          : peerEndpoint as String,
      peerPersistentKeepalive: peerPersistentKeepalive == freezed
          ? _value.peerPersistentKeepalive
          : peerPersistentKeepalive as int?,
      mtu: mtu == freezed ? _value.mtu : mtu as int?,
    ));
  }
}

abstract class _$$_WgConfigCopyWith<$Res> implements $WgConfigCopyWith<$Res> {
  factory _$$_WgConfigCopyWith(
          _$_WgConfig value, $Res Function(_$_WgConfig) then) =
      __$$_WgConfigCopyWithImpl<$Res>;
  @override
  $Res call({
    String interfacePrivateKey,
    String? interfaceAddress,
    String? interfaceDns,
    String peerPublicKey,
    String peerAllowedIps,
    String peerEndpoint,
    int? peerPersistentKeepalive,
    int? mtu,
  });
}

class __$$_WgConfigCopyWithImpl<$Res>
    extends _$WgConfigCopyWithImpl<$Res>
    implements _$$_WgConfigCopyWith<$Res> {
  __$$_WgConfigCopyWithImpl(
      _$_WgConfig _value, $Res Function(_$_WgConfig) _then)
      : super(_value, (v) => _then(v as _$_WgConfig));

  @override
  _$_WgConfig get _value => super._value as _$_WgConfig;

  @override
  $Res call({
    Object? interfacePrivateKey = freezed,
    Object? interfaceAddress = freezed,
    Object? interfaceDns = freezed,
    Object? peerPublicKey = freezed,
    Object? peerAllowedIps = freezed,
    Object? peerEndpoint = freezed,
    Object? peerPersistentKeepalive = freezed,
    Object? mtu = freezed,
  }) {
    return _then(_$_WgConfig(
      interfacePrivateKey: interfacePrivateKey == freezed
          ? _value.interfacePrivateKey
          : interfacePrivateKey as String,
      interfaceAddress: interfaceAddress == freezed
          ? _value.interfaceAddress
          : interfaceAddress as String?,
      interfaceDns: interfaceDns == freezed
          ? _value.interfaceDns
          : interfaceDns as String?,
      peerPublicKey: peerPublicKey == freezed
          ? _value.peerPublicKey
          : peerPublicKey as String,
      peerAllowedIps: peerAllowedIps == freezed
          ? _value.peerAllowedIps
          : peerAllowedIps as String,
      peerEndpoint: peerEndpoint == freezed
          ? _value.peerEndpoint
          : peerEndpoint as String,
      peerPersistentKeepalive: peerPersistentKeepalive == freezed
          ? _value.peerPersistentKeepalive
          : peerPersistentKeepalive as int?,
      mtu: mtu == freezed ? _value.mtu : mtu as int?,
    ));
  }
}

@JsonSerializable()
class _$_WgConfig extends _WgConfig {
  const _$_WgConfig({
    required this.interfacePrivateKey,
    this.interfaceAddress,
    this.interfaceDns,
    required this.peerPublicKey,
    required this.peerAllowedIps,
    required this.peerEndpoint,
    this.peerPersistentKeepalive,
    this.mtu,
  }) : super._();

  factory _$_WgConfig.fromJson(Map<String, dynamic> json) =>
      _$$_WgConfigFromJson(json);

  @override
  final String interfacePrivateKey;
  @override
  final String? interfaceAddress;
  @override
  final String? interfaceDns;
  @override
  final String peerPublicKey;
  @override
  final String peerAllowedIps;
  @override
  final String peerEndpoint;
  @override
  final int? peerPersistentKeepalive;
  @override
  final int? mtu;

  @override
  Map<String, dynamic> toJson() {
    return _$$_WgConfigToJson(this);
  }

  @override
  _$$_WgConfigCopyWith<_$_WgConfig> get copyWith =>
      __$$_WgConfigCopyWithImpl<_$_WgConfig>(this, _$identity);

  @override
  String toString() {
    return 'WgConfig(interfacePrivateKey: $interfacePrivateKey, interfaceAddress: $interfaceAddress, interfaceDns: $interfaceDns, peerPublicKey: $peerPublicKey, peerAllowedIps: $peerAllowedIps, peerEndpoint: $peerEndpoint, peerPersistentKeepalive: $peerPersistentKeepalive, mtu: $mtu)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _$_WgConfig &&
            interfacePrivateKey == other.interfacePrivateKey &&
            interfaceAddress == other.interfaceAddress &&
            interfaceDns == other.interfaceDns &&
            peerPublicKey == other.peerPublicKey &&
            peerAllowedIps == other.peerAllowedIps &&
            peerEndpoint == other.peerEndpoint &&
            peerPersistentKeepalive == other.peerPersistentKeepalive &&
            mtu == other.mtu);
  }

  @override
  int get hashCode => Object.hash(
        interfacePrivateKey,
        interfaceAddress,
        interfaceDns,
        peerPublicKey,
        peerAllowedIps,
        peerEndpoint,
        peerPersistentKeepalive,
        mtu,
      );
}

abstract class _WgConfig extends WgConfig {
  const factory _WgConfig({
    required final String interfacePrivateKey,
    final String? interfaceAddress,
    final String? interfaceDns,
    required final String peerPublicKey,
    required final String peerAllowedIps,
    required final String peerEndpoint,
    final int? peerPersistentKeepalive,
    final int? mtu,
  }) = _$_WgConfig;
  const _WgConfig._() : super._();

  factory _WgConfig.fromJson(Map<String, dynamic> json) = _$_WgConfig.fromJson;
}

T _$identity<T>(T value) => value;
