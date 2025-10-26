import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart' show rootBundle;
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
    final bundled = await _loadBundledServers();
    final cached = await _loadCachedServers();

    try {
      developer.log('Fetching VPNGate catalogue', name: 'ServerRepository');
      final remoteServers = await _vpnGateApi.fetchServers();
      developer.log('Received ${remoteServers.length} VPN entries',
          name: 'ServerRepository');

      if (remoteServers.isEmpty) {
        developer.log('Remote catalogue empty, falling back to cache/bundle',
            name: 'ServerRepository');
        return cached.isNotEmpty ? cached : bundled;
      }

      final enriched = _mergeRecords(bundled, remoteServers);
      await _saveCache(enriched);
      return enriched;
    } catch (error, stackTrace) {
      developer.log('Failed to refresh catalogue, falling back to cached copy',
          name: 'ServerRepository', error: error, stackTrace: stackTrace);
      if (cached.isNotEmpty) {
        return cached;
      }
      return bundled;
    }
  }

  Future<List<Server>> _loadBundledServers() async {
    final jsonString = await rootBundle.loadString('assets/servers.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final rawList = data['servers'] as List<dynamic>?;
    if (rawList == null) {
      return const <Server>[];
    }
    return rawList
        .map((item) => Server.fromJson(
            Map<String, dynamic>.from(item as Map<dynamic, dynamic>)))
        .toList(growable: false);
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

  List<Server> _mergeRecords(
      List<Server> base, List<VpnGateRecord> remoteRecords) {
    final bestByCountry = <String, VpnGateRecord>{};

    for (final record in remoteRecords) {
      final key = record.countryShort.toLowerCase();
      final existing = bestByCountry[key];
      if (existing == null) {
        bestByCountry[key] = record;
        continue;
      }
      final existingPing = existing.pingMs ?? 9999;
      final currentPing = record.pingMs ?? 9999;
      if (currentPing < existingPing) {
        bestByCountry[key] = record;
      }
    }

    return base
        .map((server) {
          final record = bestByCountry[server.countryCode.toLowerCase()];
          if (record == null) {
            return server;
          }
          return server.copyWith(
            name: record.countryLong.isNotEmpty ? record.countryLong : server.name,
            hostName: record.hostName.isNotEmpty ? record.hostName : server.hostName,
            ip: record.ip.isNotEmpty ? record.ip : server.ip,
            pingMs: record.pingMs ?? server.pingMs,
            bandwidth: record.speed ?? server.bandwidth,
            sessions: record.sessions ?? server.sessions,
            openVpnConfigDataBase64: record.openVpnConfig,
            regionName: record.regionName ?? server.regionName,
            cityName: record.city ?? server.cityName,
            score: record.score ?? server.score,
          );
        })
        .toList(growable: false);
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

