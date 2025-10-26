import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/server.dart';
import 'vpngate_api.dart';
import '../../../services/storage/prefs.dart';

class ServerRepository {
  ServerRepository({required VpnGateApi vpnGateApi, PrefsStore? prefs})
      : _vpnGateApi = vpnGateApi,
        _prefs = prefs;

  final VpnGateApi _vpnGateApi;
  final PrefsStore? _prefs;

  static const _cacheKey = 'servers_v1';

  Future<List<Server>> loadServers() async {
    developer.log('🔵 ServerRepository.loadServers() called', name: 'ServerRepository');

    final cached = await _loadCachedServers();
    developer.log('🔵 Loaded ${cached.length} cached servers', name: 'ServerRepository');

    try {
      developer.log('🔵 Fetching from VPN Gate API...', name: 'ServerRepository');
      final remoteServers = await _vpnGateApi.fetchServers();
      developer.log('✅ Received ${remoteServers.length} VPN entries from API', name: 'ServerRepository');

      if (remoteServers.isEmpty) {
        developer.log('⚠️ Remote catalogue empty, using cached servers', name: 'ServerRepository');
        return cached;
      }

      // Convert VPN Gate records directly to Server objects
      final servers = _convertVpnGateRecords(remoteServers);
      developer.log('✅ Converted to ${servers.length} Server objects', name: 'ServerRepository');

      await _saveCache(servers);
      return servers;
    } catch (error, stackTrace) {
      developer.log('❌ Failed to fetch from API: $error',
          name: 'ServerRepository', error: error, stackTrace: stackTrace);
      print('❌ ServerRepository Error: $error');
      print('❌ StackTrace: $stackTrace');
      return cached;
    }
  }

  /// Convert VPN Gate records to Server objects
  List<Server> _convertVpnGateRecords(List<VpnGateRecord> records) {
    return records.map((record) {
      final rawSlug = record.hostName.isNotEmpty
          ? record.hostName.replaceAll('.', '-')
          : record.ip.replaceAll(RegExp(r'[.:]'), '-');
      final hostSlug = rawSlug.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '-');
      final displayName = record.hostName.isNotEmpty
          ? '${record.countryLong} • ${record.hostName}'
          : '${record.countryLong} • ${record.ip}';
      return Server(
        id: 'vpngate-${record.countryShort.toLowerCase()}-$hostSlug',
        name: displayName,
        countryCode: record.countryShort,
        countryName: record.countryLong,
        publicKey: 'openvpn',
        endpoint: '${record.ip}:1194',
        allowedIps: '0.0.0.0/0, ::/0',
        hostName: record.hostName,
        ip: record.ip,
        pingMs: record.pingMs,
        bandwidth: record.speed,
        downloadSpeed: record.speed,
        uploadSpeed: record.speed,
        sessions: record.sessions,
        openVpnConfigDataBase64: record.openVpnConfig,
        regionName: record.regionName,
        cityName: record.city,
        score: record.score,
      );
    }).toList();
  }

  Future<List<Server>> _loadCachedServers() async {
    final prefs = _prefs;
    if (prefs == null) {
      return const <Server>[];
    }
    try {
      final raw = prefs.getString(_cacheKey);
      if (raw == null) {
        return const <Server>[];
      }
      final decoded = json.decode(raw);
      if (decoded is! List) {
        return const <Server>[];
      }
      return decoded
          .map((item) {
            if (item is Map) {
              return Server.fromJson(
                  Map<String, dynamic>.from(item as Map<dynamic, dynamic>));
            }
            return null;
          })
          .whereType<Server>()
          .toList(growable: false);
    } catch (_) {
      return const <Server>[];
    }
  }

  Future<void> _saveCache(List<Server> servers) async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }
    try {
      final encoded = json.encode(
        servers.map((server) => server.toJson()).toList(growable: false),
      );
      await prefs.setString(_cacheKey, encoded);
      developer.log('Cached ${servers.length} VPN entries',
          name: 'ServerRepository');
    } catch (_) {
      // Ignore cache write errors.
    }
  }


}

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final api = ref.watch(vpnGateApiProvider);
  final prefs = ref.watch(prefsStoreProvider).maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
  return ServerRepository(vpnGateApi: api, prefs: prefs);
});

