import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/server.dart';
import 'vpngate_api.dart';

class ServerRepository {
  ServerRepository({required VpnGateApi vpnGateApi}) : _vpnGateApi = vpnGateApi;

  final VpnGateApi _vpnGateApi;

  Future<List<Server>> loadServers() async {
    final jsonString = await rootBundle.loadString('assets/servers.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final servers = (data['servers'] as List<dynamic>)
        .map((e) => Server.fromJson(e as Map<String, dynamic>))
        .toList();

    try {
      final remoteServers = await _vpnGateApi.fetchServers();
      if (remoteServers.isNotEmpty) {
        final bestByCountry = <String, VpnGateRecord>{};
        for (final record in remoteServers) {
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

        return servers
            .map((server) {
              final record = bestByCountry[server.countryCode.toLowerCase()];
              if (record == null) {
                return server;
              }
              return server.copyWith(
                name: record.countryLong.isNotEmpty
                    ? record.countryLong
                    : server.name,
                hostName: record.hostName,
                ip: record.ip,
                pingMs: record.pingMs,
                bandwidth: record.speed,
                sessions: record.sessions,
                openVpnConfigDataBase64: record.openVpnConfig,
                regionName: record.regionName ?? server.regionName,
                cityName: record.city ?? server.cityName,
                score: record.score,
              );
            })
            .toList(growable: false);
      }
    } catch (_) {
      // Silently ignore remote errors and return the bundled server list.
    }

    return servers;
  }
}

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final api = ref.watch(vpnGateApiProvider);
  return ServerRepository(vpnGateApi: api);
});

