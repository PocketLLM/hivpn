import 'dart:convert';
import 'dart:developer' as developer;

import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class VpnGateRecord {
  const VpnGateRecord({
    required this.hostName,
    required this.ip,
    required this.countryShort,
    required this.countryLong,
    required this.pingMs,
    required this.speed,
    required this.sessions,
    required this.openVpnConfig,
    this.score,
    this.regionName,
    this.city,
  });

  final String hostName;
  final String ip;
  final String countryShort;
  final String countryLong;
  final int? pingMs;
  final int? speed;
  final int? sessions;
  final double? score;
  final String openVpnConfig;
  final String? regionName;
  final String? city;

  factory VpnGateRecord.fromMap(Map<String, dynamic> map) {
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      return parsed;
    }

    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    String _readString(String key) {
      final value = map[key];
      if (value == null) return '';
      return value.toString();
    }

    return VpnGateRecord(
      hostName: _readString('HostName'),
      ip: _readString('IP'),
      countryShort: _readString('CountryShort'),
      countryLong: _readString('CountryLong'),
      pingMs: _parseInt(map['Ping']),
      speed: _parseInt(map['Speed']),
      sessions: _parseInt(map['NumVpnSessions']),
      openVpnConfig: _readString('OpenVPN_ConfigData_Base64'),
      score: _parseDouble(map['Score']),
      regionName: _readString('RegionName').isEmpty ? null : _readString('RegionName'),
      city: _readString('CityName').isEmpty ? null : _readString('CityName'),
    );
  }
}

class VpnGateApi {
  VpnGateApi({http.Client? client}) : _client = client ?? http.Client();

  static const _endpoint = 'http://www.vpngate.net/api/iphone/';
  static const _fallbackEndpoint = 'https://www.vpngate.net/api/iphone/';
  static const _defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    'Accept': 'text/plain,application/json;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Connection': 'keep-alive',
    'Referer': 'http://www.vpngate.net/',
  };

  final http.Client _client;

  Future<List<VpnGateRecord>> fetchServers() async {
    try {
      developer.log('🎬 fetchServers() started', name: 'VpnGateApi');
      final body = await _downloadCatalogue();
      developer.log('📥 Downloaded catalogue: ${body.length} bytes', name: 'VpnGateApi');

      if (body.isEmpty) {
        developer.log('❌ Catalogue is empty', name: 'VpnGateApi');
        return const [];
      }

      final segments = body.split('#');
      developer.log('📊 Split into ${segments.length} segments', name: 'VpnGateApi');

      if (segments.length < 2) {
        developer.log('❌ Not enough segments (need at least 2)', name: 'VpnGateApi');
        return const [];
      }

      final csvString = segments[1].replaceAll('*', '');
      developer.log('📄 CSV string length: ${csvString.length}', name: 'VpnGateApi');

      if (csvString.contains('Domain forbidden')) {
        developer.log('⛔️ Catalogue response indicates domain forbidden',
            name: 'VpnGateApi');
        return const [];
      }

      final cleanedCsv = csvString.trim();
      final rows = const CsvToListConverter(eol: '\n').convert(cleanedCsv);
      developer.log('📋 Parsed ${rows.length} rows from CSV', name: 'VpnGateApi');

      if (rows.length <= 1) {
        developer.log('❌ Not enough rows (need more than 1)', name: 'VpnGateApi');
        return const [];
      }

      final header = rows.first.map((value) => value.toString()).toList();
      developer.log('🔑 Header: $header', name: 'VpnGateApi');

      final records = <VpnGateRecord>[];
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row.length != header.length) {
          continue;
        }
        final map = <String, dynamic>{};
        for (var j = 0; j < header.length; j++) {
          map[header[j]] = row[j];
        }
        final host = map['HostName']?.toString() ?? '';
        final ip = map['IP']?.toString() ?? '';
        final config = map['OpenVPN_ConfigData_Base64']?.toString() ?? '';
        if ((host.isEmpty && ip.isEmpty) || config.isEmpty) {
          developer.log('⏭️ Skipping row $i: host=$host, ip=$ip, config_len=${config.length}', name: 'VpnGateApi');
          continue;
        }
        records.add(VpnGateRecord.fromMap(map));
      }
      developer.log('✅ VPNGate catalogue parsed: ${records.length} records',
          name: 'VpnGateApi');
      return records;
    } catch (e, st) {
      developer.log('❌ fetchServers() failed: $e', name: 'VpnGateApi', error: e, stackTrace: st);
      return const [];
    }
  }

  Future<String> _downloadCatalogue() async {
    developer.log('🌐 Starting _downloadCatalogue()', name: 'VpnGateApi');

    Future<http.Response> performGet(Uri uri) {
      developer.log('📤 Sending GET request to: $uri', name: 'VpnGateApi');
      return _client.get(uri, headers: _defaultHeaders);
    }

    Future<String> tryFetch(Uri uri) async {
      try {
        developer.log('🔄 Attempting fetch from: $uri', name: 'VpnGateApi');
        final response = await performGet(uri);
        developer.log(
          '📥 VPNGate response: status=${response.statusCode} length=${response.contentLength ?? response.bodyBytes.length} uri=$uri',
          name: 'VpnGateApi',
        );
        if (response.statusCode != 200) {
          throw http.ClientException(
            'Unexpected status code: ${response.statusCode}',
            uri,
          );
        }
        final decoded = const Utf8Decoder().convert(response.bodyBytes);
        if (decoded.contains('Domain forbidden')) {
          developer.log('⛔️ Response body reports domain forbidden',
              name: 'VpnGateApi');
        }
        developer.log('✅ Successfully decoded response: ${decoded.length} chars', name: 'VpnGateApi');
        return decoded;
      } catch (e, st) {
        developer.log('❌ tryFetch failed: $e', name: 'VpnGateApi', error: e, stackTrace: st);
        rethrow;
      }
    }

    try {
      developer.log('🔗 Trying HTTP endpoint: $_endpoint', name: 'VpnGateApi');
      final primary = await tryFetch(Uri.parse(_endpoint));
      if (primary.contains('Domain forbidden')) {
        developer.log('⚠️ HTTP endpoint blocked, retrying with HTTPS',
            name: 'VpnGateApi');
        final fallback = await tryFetch(Uri.parse(_fallbackEndpoint));
        return fallback;
      }
      return primary;
    } on http.ClientException catch (error, stackTrace) {
      developer.log('⚠️ HTTP fetch failed, retrying with HTTPS: $error',
          name: 'VpnGateApi', error: error, stackTrace: stackTrace);
      developer.log('🔗 Trying HTTPS endpoint: $_fallbackEndpoint', name: 'VpnGateApi');
      return tryFetch(Uri.parse(_fallbackEndpoint));
    } catch (error, stackTrace) {
      developer.log('❌ _downloadCatalogue failed completely: $error',
          name: 'VpnGateApi', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}

final vpnGateApiProvider = Provider<VpnGateApi>((ref) {
  return VpnGateApi();
});
