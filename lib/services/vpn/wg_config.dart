import 'dart:convert';

class WgConfig {
  const WgConfig({
    required this.interfacePrivateKey,
    this.interfaceAddress,
    this.interfaceDns,
    required this.peerPublicKey,
    required this.peerAllowedIps,
    required this.peerEndpoint,
    this.peerPersistentKeepalive,
    this.mtu,
    this.protocol = 'wireguard',
    this.dnsServers = const <String>[],
    this.splitTunnelEnabled = false,
    this.splitTunnelPackages = const <String>[],
    this.splitTunnelMode = 'allTraffic',
    this.connectOnAppLaunch = false,
    this.connectOnBoot = false,
    this.reconnectOnNetworkChange = false,
    this.sessionServerId,
    this.sessionServerName,
    this.sessionCountryCode,
    this.sessionStartElapsedMs,
    this.sessionDurationMs,
  });

  final String interfacePrivateKey;
  final String? interfaceAddress;
  final String? interfaceDns;
  final String peerPublicKey;
  final String peerAllowedIps;
  final String peerEndpoint;
  final int? peerPersistentKeepalive;
  final int? mtu;
  final String protocol;
  final List<String> dnsServers;
  final bool splitTunnelEnabled;
  final List<String> splitTunnelPackages;
  final String splitTunnelMode;
  final bool connectOnAppLaunch;
  final bool connectOnBoot;
  final bool reconnectOnNetworkChange;
  final String? sessionServerId;
  final String? sessionServerName;
  final String? sessionCountryCode;
  final int? sessionStartElapsedMs;
  final int? sessionDurationMs;

  WgConfig copyWith({
    String? interfacePrivateKey,
    String? interfaceAddress,
    String? interfaceDns,
    String? peerPublicKey,
    String? peerAllowedIps,
    String? peerEndpoint,
    int? peerPersistentKeepalive,
    int? mtu,
    String? protocol,
    List<String>? dnsServers,
    bool? splitTunnelEnabled,
    List<String>? splitTunnelPackages,
    String? splitTunnelMode,
    bool? connectOnAppLaunch,
    bool? connectOnBoot,
    bool? reconnectOnNetworkChange,
    String? sessionServerId,
    String? sessionServerName,
    String? sessionCountryCode,
    int? sessionStartElapsedMs,
    int? sessionDurationMs,
  }) {
    return WgConfig(
      interfacePrivateKey: interfacePrivateKey ?? this.interfacePrivateKey,
      interfaceAddress: interfaceAddress ?? this.interfaceAddress,
      interfaceDns: interfaceDns ?? this.interfaceDns,
      peerPublicKey: peerPublicKey ?? this.peerPublicKey,
      peerAllowedIps: peerAllowedIps ?? this.peerAllowedIps,
      peerEndpoint: peerEndpoint ?? this.peerEndpoint,
      peerPersistentKeepalive:
          peerPersistentKeepalive ?? this.peerPersistentKeepalive,
      mtu: mtu ?? this.mtu,
      protocol: protocol ?? this.protocol,
      dnsServers: dnsServers ?? this.dnsServers,
      splitTunnelEnabled: splitTunnelEnabled ?? this.splitTunnelEnabled,
      splitTunnelPackages: splitTunnelPackages ?? this.splitTunnelPackages,
      splitTunnelMode: splitTunnelMode ?? this.splitTunnelMode,
      connectOnAppLaunch: connectOnAppLaunch ?? this.connectOnAppLaunch,
      connectOnBoot: connectOnBoot ?? this.connectOnBoot,
      reconnectOnNetworkChange:
          reconnectOnNetworkChange ?? this.reconnectOnNetworkChange,
      sessionServerId: sessionServerId ?? this.sessionServerId,
      sessionServerName: sessionServerName ?? this.sessionServerName,
      sessionCountryCode: sessionCountryCode ?? this.sessionCountryCode,
      sessionStartElapsedMs:
          sessionStartElapsedMs ?? this.sessionStartElapsedMs,
      sessionDurationMs: sessionDurationMs ?? this.sessionDurationMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interfacePrivateKey': interfacePrivateKey,
      'interfaceAddress': interfaceAddress,
      'interfaceDns': interfaceDns,
      'peerPublicKey': peerPublicKey,
      'peerAllowedIps': peerAllowedIps,
      'peerEndpoint': peerEndpoint,
      'peerPersistentKeepalive': peerPersistentKeepalive,
      'mtu': mtu,
      'protocol': protocol,
      'dnsServers': dnsServers,
      'splitTunnelEnabled': splitTunnelEnabled,
      'splitTunnelPackages': splitTunnelPackages,
      'splitTunnelMode': splitTunnelMode,
      'connectOnAppLaunch': connectOnAppLaunch,
      'connectOnBoot': connectOnBoot,
      'reconnectOnNetworkChange': reconnectOnNetworkChange,
      'sessionServerId': sessionServerId,
      'sessionServerName': sessionServerName,
      'sessionCountryCode': sessionCountryCode,
      'sessionStartElapsedMs': sessionStartElapsedMs,
      'sessionDurationMs': sessionDurationMs,
    };
  }

  factory WgConfig.fromJson(Map<String, dynamic> json) {
    final dns = (json['dnsServers'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const <String>[];
    return WgConfig(
      interfacePrivateKey: json['interfacePrivateKey'] as String,
      interfaceAddress: json['interfaceAddress'] as String?,
      interfaceDns: json['interfaceDns'] as String?,
      peerPublicKey: json['peerPublicKey'] as String,
      peerAllowedIps: json['peerAllowedIps'] as String,
      peerEndpoint: json['peerEndpoint'] as String,
      peerPersistentKeepalive: (json['peerPersistentKeepalive'] as num?)?.toInt(),
      mtu: (json['mtu'] as num?)?.toInt(),
      protocol: json['protocol'] as String? ?? 'wireguard',
      dnsServers: dns,
      splitTunnelEnabled: json['splitTunnelEnabled'] as bool? ?? false,
      splitTunnelPackages: (json['splitTunnelPackages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      splitTunnelMode: json['splitTunnelMode'] as String? ?? 'allTraffic',
      connectOnAppLaunch: json['connectOnAppLaunch'] as bool? ?? false,
      connectOnBoot: json['connectOnBoot'] as bool? ?? false,
      reconnectOnNetworkChange:
          json['reconnectOnNetworkChange'] as bool? ?? false,
      sessionServerId: json['sessionServerId'] as String?,
      sessionServerName: json['sessionServerName'] as String?,
      sessionCountryCode: json['sessionCountryCode'] as String?,
      sessionStartElapsedMs: (json['sessionStartElapsedMs'] as num?)?.toInt(),
      sessionDurationMs: (json['sessionDurationMs'] as num?)?.toInt(),
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
