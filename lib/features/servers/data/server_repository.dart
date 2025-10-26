import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/server.dart';
import 'vpngate_api.dart';

class ServerRepository {
  ServerRepository({required VpnGateApi vpnGateApi}) : _vpnGateApi = vpnGateApi;

  final VpnGateApi _vpnGateApi;

  Future<List<Server>> loadServers() async {
    final bundledServers = await _loadBundledServers();

    try {
      final remoteRecords = await _vpnGateApi.fetchServers();
      final remoteServers = _buildServersFromRemote(remoteRecords);
      if (remoteServers.isNotEmpty) {
        if (bundledServers.isEmpty) {
          return remoteServers;
        }
        final merged = [...remoteServers];
        final remoteIds = remoteServers.map((server) => server.id).toSet();
        for (final server in bundledServers) {
          if (!remoteIds.contains(server.id)) {
            merged.add(server);
          }
        }
        return merged;
      }
    } catch (_) {
      // Silently ignore remote errors and return the bundled server list.
    }

    return bundledServers;
  }

  Future<List<Server>> _loadBundledServers() async {
    final jsonString = await rootBundle.loadString('assets/servers.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return (data['servers'] as List<dynamic>)
        .map((e) => Server.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  List<Server> _buildServersFromRemote(List<VpnGateRecord> records) {
    if (records.isEmpty) {
      return const [];
    }
    final deduped = <String, VpnGateRecord>{};
    for (final record in records) {
      if (record.openVpnConfig.isEmpty ||
          record.countryShort.isEmpty ||
          (record.hostName.isEmpty && record.ip.isEmpty)) {
        continue;
      }
      final keySeed = record.hostName.isNotEmpty ? record.hostName : record.ip;
      final key = keySeed.toLowerCase();
      final existing = deduped[key];
      if (existing == null) {
        deduped[key] = record;
        continue;
      }
      final existingPing = existing.pingMs ?? 9999;
      final currentPing = record.pingMs ?? 9999;
      if (currentPing < existingPing) {
        deduped[key] = record;
      }
    }

    final prioritized = deduped.values.toList()
      ..sort((a, b) {
        final pingA = a.pingMs ?? 9999;
        final pingB = b.pingMs ?? 9999;
        if (pingA != pingB) {
          return pingA.compareTo(pingB);
        }
        final scoreA = a.score ?? 0;
        final scoreB = b.score ?? 0;
        return scoreB.compareTo(scoreA);
      });

    final limited = prioritized.take(60).toList();
    final servers = <Server>[];
    for (final record in limited) {
      final server = _mapRecordToServer(record);
      if (server != null) {
        servers.add(server);
      }
    }
    return servers;
  }

  Server? _mapRecordToServer(VpnGateRecord record) {
    final decodedConfig = _decodeConfig(record.openVpnConfig);
    if (decodedConfig == null) {
      return null;
    }
    final endpoint = _extractEndpoint(decodedConfig);
    if (endpoint == null) {
      return null;
    }
    final country = record.countryShort.isNotEmpty ? record.countryShort : 'US';
    final host = record.hostName.isNotEmpty ? record.hostName : null;
    final ip = record.ip.isNotEmpty ? record.ip : null;
    final idSeed = host ?? ip ?? '${record.countryShort}_${record.score ?? ''}';
    final id = 'vpngate-${idSeed.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-')}'.toLowerCase();
    final placeholderKey = _derivePlaceholderKey(idSeed);

    return Server(
      id: id,
      name: host ?? (record.countryLong.isNotEmpty ? record.countryLong : 'VPN Gate'),
      countryCode: country,
      publicKey: placeholderKey,
      endpoint: endpoint,
      allowedIps: '0.0.0.0/0, ::/0',
      hostName: host,
      ip: ip,
      pingMs: record.pingMs,
      bandwidth: record.speed,
      sessions: record.sessions,
      openVpnConfigDataBase64: record.openVpnConfig,
      regionName: record.regionName,
      cityName: record.city,
      score: record.score,
    );
  }

  String? _decodeConfig(String base64Config) {
    if (base64Config.isEmpty) {
      return null;
    }
    try {
      final bytes = base64.decode(base64Config);
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  String? _extractEndpoint(String config) {
    final lines = config.split(RegExp(r'\r?\n'));
    String? host;
    String? port;
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }
      if (line.startsWith('remote ')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          host = parts[1];
          if (parts.length >= 3) {
            port = parts[2];
          }
          break;
        }
      }
    }
    if (host == null || host.isEmpty) {
      return null;
    }
    final resolvedPort = int.tryParse(port ?? '') ?? 1194;
    return '$host:$resolvedPort';
  }

  String _derivePlaceholderKey(String seed) {
    final normalized = seed.isNotEmpty ? seed : 'hivpn-placeholder';
    final bytes = utf8.encode(normalized);
    final buffer = List<int>.filled(32, 0);
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] = bytes[i % bytes.length];
    }
    return base64.encode(buffer);
  }
}

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final api = ref.watch(vpnGateApiProvider);
  return ServerRepository(vpnGateApi: api);
});

