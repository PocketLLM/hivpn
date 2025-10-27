import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/server.dart';
import 'vpngate_api.dart';
import '../../../services/storage/prefs.dart';

class ServerRepositoryException implements Exception {
  ServerRepositoryException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer('ServerRepositoryException: $message');
    if (cause != null) {
      buffer.write(' (cause: $cause)');
    }
    return buffer.toString();
  }
}

class ServerRepository {
  ServerRepository({required VpnGateApi vpnGateApi, PrefsStore? prefs})
      : _vpnGateApi = vpnGateApi,
        _prefs = prefs;

  final VpnGateApi _vpnGateApi;
  final PrefsStore? _prefs;

  static const _cacheKey = 'servers_v2';

  Future<List<Server>> loadServers() async {
    developer.log('🔵 ServerRepository.loadServers() called', name: 'ServerRepository');

    final cached = await _loadCachedServers();
    developer.log('🔵 Loaded ${cached.length} cached servers', name: 'ServerRepository');

    try {
      developer.log('🔵 Fetching from VPN Gate API...', name: 'ServerRepository');
      final remoteServers = await _vpnGateApi.fetchServers();
      developer.log('✅ Received ${remoteServers.length} VPN entries from API',
          name: 'ServerRepository');

      if (remoteServers.isEmpty) {
        developer.log('⚠️ Remote catalogue returned zero entries',
            name: 'ServerRepository');
        if (cached.isNotEmpty) {
          developer.log('ℹ️ Falling back to ${cached.length} cached servers',
              name: 'ServerRepository');
          return cached;
        }
        throw ServerRepositoryException(
          message: 'VPN Gate returned zero servers',
        );
      }

      // Convert VPN Gate records directly to Server objects
      final servers = _convertVpnGateRecords(remoteServers);
      developer.log('✅ Converted to ${servers.length} Server objects',
          name: 'ServerRepository');

      await _saveCache(servers);
      return servers;
    } on VpnGateCatalogueException catch (error, stackTrace) {
      developer.log('❌ VPN Gate catalogue error: $error',
          name: 'ServerRepository', error: error, stackTrace: stackTrace);
      if (cached.isNotEmpty) {
        developer.log('ℹ️ Falling back to ${cached.length} cached servers',
            name: 'ServerRepository');
        return cached;
      }
      throw ServerRepositoryException(
        message: error.message,
        cause: error.cause,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      developer.log('❌ Failed to fetch from API: $error',
          name: 'ServerRepository', error: error, stackTrace: stackTrace);
      print('❌ ServerRepository Error: $error');
      print('❌ StackTrace: $stackTrace');
      if (cached.isNotEmpty) {
        developer.log('ℹ️ Falling back to ${cached.length} cached servers',
            name: 'ServerRepository');
        return cached;
      }
      throw ServerRepositoryException(
        message: 'Failed to load VPN servers',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Convert VPN Gate records to Server objects
  List<Server> _convertVpnGateRecords(List<VpnGateRecord> records) {
    final servers = <Server>[];
    var skippedInvalidConfigs = 0;

    for (final record in records) {
      final rawConfig = record.openVpnConfig.trim();
      if (rawConfig.isEmpty) {
        skippedInvalidConfigs++;
        developer.log(
          '⏭️ Skipping ${record.hostName}/${record.ip}: empty OpenVPN config',
          name: 'ServerRepository',
        );
        continue;
      }

      final normalizedConfig = base64.normalize(rawConfig);
      try {
        final decoded = base64.decode(normalizedConfig);
        if (decoded.isEmpty) {
          skippedInvalidConfigs++;
          developer.log(
            '⏭️ Skipping ${record.hostName}/${record.ip}: decoded config was empty',
            name: 'ServerRepository',
          );
          continue;
        }
      } catch (error, stackTrace) {
        skippedInvalidConfigs++;
        developer.log(
          '⏭️ Skipping ${record.hostName}/${record.ip}: invalid OpenVPN config',
          name: 'ServerRepository',
          error: error,
          stackTrace: stackTrace,
        );
        continue;
      }

      final rawSlug = record.hostName.isNotEmpty
          ? record.hostName.replaceAll('.', '-')
          : record.ip.replaceAll(RegExp(r'[.:]'), '-');
      final hostSlug = rawSlug.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '-');
      final displayName = record.hostName.isNotEmpty
          ? '${record.countryLong} • ${record.hostName}'
          : '${record.countryLong} • ${record.ip}';

      servers.add(
        Server(
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
          openVpnConfigDataBase64: normalizedConfig,
          regionName: record.regionName,
          cityName: record.city,
          score: record.score,
        ),
      );
    }

    if (skippedInvalidConfigs > 0) {
      developer.log(
        '⚠️ Skipped $skippedInvalidConfigs VPN Gate records due to invalid configs',
        name: 'ServerRepository',
      );
    }

    return servers;
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

