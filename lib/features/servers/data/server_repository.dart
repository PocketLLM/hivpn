import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage/prefs.dart';
import '../domain/server.dart';
import 'vpngate_api.dart';

class ServerRepository {
  ServerRepository({
    required VpnGateApi vpnGateApi,
    ServerCacheStore? cacheStore,
  })  : _vpnGateApi = vpnGateApi,
        _cacheStore = cacheStore;

  final VpnGateApi _vpnGateApi;
  final ServerCacheStore? _cacheStore;

  Future<ServerLoadResult> loadServers() async {
    Object? remoteError;

    try {
      final remoteRecords = await _vpnGateApi.fetchServers();
      final remoteServers = _buildServersFromRemote(remoteRecords);
      if (remoteServers.isNotEmpty) {
        final savedAt = await _cacheStore?.save(remoteServers);
        return ServerLoadResult(
          servers: remoteServers,
          source: ServerLoadSource.remote,
          lastUpdated: savedAt ?? DateTime.now().toUtc(),
        );
      }
    } catch (error) {
      remoteError = error;
    }

    final cacheSnapshot = _cacheStore?.load();
    final cachedServers = cacheSnapshot?.servers ?? const <Server>[];
    if (cachedServers.isNotEmpty) {
      return ServerLoadResult(
        servers: cachedServers,
        source: ServerLoadSource.cache,
        lastUpdated: cacheSnapshot?.timestamp,
        error: remoteError,
      );
    }

    if (remoteError != null) {
      throw ServerLoadException(remoteError);
    }

    throw const ServerLoadException('No VPN servers available.');
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

class ServerLoadResult {
  const ServerLoadResult({
    required this.servers,
    required this.source,
    this.lastUpdated,
    this.error,
  });

  final List<Server> servers;
  final ServerLoadSource source;
  final DateTime? lastUpdated;
  final Object? error;
}

enum ServerLoadSource { remote, cache }

class ServerLoadException implements Exception {
  const ServerLoadException(this.error);

  final Object error;

  @override
  String toString() => error.toString();
}

class ServerCacheSnapshot {
  const ServerCacheSnapshot({
    required this.servers,
    this.timestamp,
  });

  final List<Server> servers;
  final DateTime? timestamp;
}

class ServerCacheStore {
  ServerCacheStore(this._prefs);

  final PrefsStore _prefs;

  static const _cacheKey = 'server_cache_v1';
  static const _timestampKey = 'server_cache_v1_ts';

  Future<DateTime> save(List<Server> servers) async {
    final now = DateTime.now().toUtc();
    final payload = json.encode(
      servers.map((server) => server.toJson()).toList(growable: false),
    );
    await _prefs.setString(_cacheKey, payload);
    await _prefs.setString(_timestampKey, now.toIso8601String());
    return now;
  }

  ServerCacheSnapshot? load() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      final servers = <Server>[];
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          servers.add(Server.fromJson(entry));
        } else if (entry is Map) {
          final map = Map<String, dynamic>.from(
            entry as Map<dynamic, dynamic>,
          );
          servers.add(Server.fromJson(map));
        }
      }
      if (servers.isEmpty) {
        return null;
      }
      final timestampRaw = _prefs.getString(_timestampKey);
      final timestamp =
          timestampRaw != null ? DateTime.tryParse(timestampRaw)?.toUtc() : null;
      return ServerCacheSnapshot(servers: servers, timestamp: timestamp);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_timestampKey);
  }
}

final serverCacheStoreProvider = Provider<ServerCacheStore?>((ref) {
  final prefs = ref.watch(prefsStoreProvider);
  return prefs.maybeWhen(
    data: (store) => ServerCacheStore(store),
    orElse: () => null,
  );
});

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final api = ref.watch(vpnGateApiProvider);
  final cache = ref.watch(serverCacheStoreProvider);
  return ServerRepository(
    vpnGateApi: api,
    cacheStore: cache,
  );
});

