import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/server.dart';
import 'vpngate_api.dart';

class ServerRepository {
  ServerRepository({required VpnGateApi vpnGateApi}) : _vpnGateApi = vpnGateApi;

  final VpnGateApi _vpnGateApi;

  static const _cacheBoxName = 'server_cache_box';
  static const _cacheKey = 'servers_v1';

  Future<Box<dynamic>> _openCacheBox() async {
    if (Hive.isBoxOpen(_cacheBoxName)) {
      return Hive.box<dynamic>(_cacheBoxName);
    }
    return Hive.openBox<dynamic>(_cacheBoxName);
  }

  Future<List<Server>> loadServers() async {
    List<Server> cached = const [];
    try {
      final box = await _openCacheBox();
      final raw = box.get(_cacheKey);
      if (raw is List) {
        cached = raw
            .map((item) {
              if (item is Map) {
                return Server.fromJson(
                    Map<String, dynamic>.from(item as Map<dynamic, dynamic>));
              }
              return null;
            })
            .whereType<Server>()
            .toList(growable: false);
      }
    } catch (_) {
      cached = const [];
    }

    try {
      final remoteServers = await _vpnGateApi.fetchServers();
      if (remoteServers.isEmpty) {
        return cached;
      }

      remoteServers.sort((a, b) {
        final pingA = a.pingMs ?? 9999;
        final pingB = b.pingMs ?? 9999;
        return pingA.compareTo(pingB);
      });

      final mapped = <Server>[];
      final seenIds = <String>{};

      for (var i = 0; i < remoteServers.length; i++) {
        final record = remoteServers[i];
        final server = _mapRecord(record, i);
        if (seenIds.add(server.id)) {
          mapped.add(server);
        }
      }

      try {
        final box = await _openCacheBox();
        await box.put(
          _cacheKey,
          mapped.map((server) => server.toJson()).toList(growable: false),
        );
      } catch (_) {
        // Ignore cache write errors.
      }

      return mapped;
    } catch (_) {
      return cached;
    }
  }

  Server _mapRecord(VpnGateRecord record, int index) {
    String _ensureId() {
      final base = record.hostName.isNotEmpty ? record.hostName : record.ip;
      final sanitized = base.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-');
      if (sanitized.isEmpty) {
        return 'ovpn-$index';
      }
      return 'ovpn-${sanitized.toLowerCase()}-$index';
    }

    final endpointHost = record.ip.isNotEmpty ? record.ip : record.hostName;
    final endpoint = endpointHost.isNotEmpty ? '$endpointHost:443' : '';
    final baseName = record.countryLong.isNotEmpty
        ? '${record.countryLong} • ${record.hostName.isNotEmpty ? record.hostName : endpointHost}'
        : (record.hostName.isNotEmpty ? record.hostName : endpointHost);
    final name = baseName.trim().isNotEmpty ? baseName.trim() : 'VPN ${index + 1}';

    String countryCode = record.countryShort.trim();
    if (countryCode.isEmpty) {
      final lettersOnly = record.countryLong.replaceAll(RegExp(r'[^A-Za-z]'), '');
      if (lettersOnly.length >= 2) {
        countryCode = lettersOnly.substring(0, 2).toUpperCase();
      } else {
        countryCode = 'UN';
      }
    } else {
      countryCode = countryCode.toUpperCase();
    }

    return Server(
      id: _ensureId(),
      name: name,
      countryCode: countryCode,
      publicKey: 'OPENVPN_PLACEHOLDER',
      endpoint: endpoint,
      allowedIps: '0.0.0.0/0, ::/0',
      mtu: null,
      keepaliveSeconds: 25,
      hostName: record.hostName.isNotEmpty ? record.hostName : null,
      ip: record.ip.isNotEmpty ? record.ip : null,
      pingMs: record.pingMs,
      bandwidth: record.speed,
      sessions: record.sessions,
      openVpnConfigDataBase64: record.openVpnConfig,
      regionName:
          (record.regionName != null && record.regionName!.isNotEmpty) ? record.regionName : null,
      cityName: (record.city != null && record.city!.isNotEmpty) ? record.city : null,
      score: record.score,
    );
  }
}

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final api = ref.watch(vpnGateApiProvider);
  return ServerRepository(vpnGateApi: api);
});

