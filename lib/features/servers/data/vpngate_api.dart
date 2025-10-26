import 'dart:convert';

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
        'HiVPN/1.0'
  };

  final http.Client _client;

  Future<List<VpnGateRecord>> fetchServers() async {
    print('🎬 VpnGateApi.fetchServers() called');
    try {
      final body = await _downloadCatalogue();
      print('📥 Downloaded catalogue: ${body.length} bytes');

      if (body.isEmpty) {
        print('❌ Catalogue is empty');
        return const [];
      }

      final segments = body.split('#');
      print('📊 Split into ${segments.length} segments');

      if (segments.length < 2) {
        print('❌ Not enough segments (need at least 2)');
        return const [];
      }

      final csvString = segments[1].replaceAll('*', '');
      print('📄 CSV string length: ${csvString.length}');

      final rows = const CsvToListConverter(eol: '\n').convert(csvString);
      print('📋 Parsed ${rows.length} rows from CSV');

      if (rows.length <= 1) {
        print('❌ Not enough rows (need more than 1)');
        return const [];
      }

      final header = rows.first.map((value) => value.toString()).toList();
      print('🔑 Header: $header');

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
          continue;
        }
        records.add(VpnGateRecord.fromMap(map));
      }
      print('✅ VPNGate catalogue parsed: ${records.length} records');
      return records;
    } catch (e, st) {
      print('❌ fetchServers() failed: $e');
      print('❌ Stack trace: $st');
      return const [];
    }
  }

  Future<String> _downloadCatalogue() async {
    print('🌐 _downloadCatalogue() started');

    Future<http.Response> performGet(Uri uri) {
      print('📤 Sending GET request to: $uri');
      return _client.get(uri, headers: _defaultHeaders).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ GET request timed out after 30 seconds');
          throw http.ClientException('Request timeout', uri);
        },
      );
    }

    Future<String> tryFetch(Uri uri) async {
      try {
        print('🔄 Attempting fetch from: $uri');
        final response = await performGet(uri);
        print('📥 VPNGate response: status=${response.statusCode} length=${response.contentLength ?? response.bodyBytes.length}');
        if (response.statusCode != 200) {
          throw http.ClientException(
            'Unexpected status code: ${response.statusCode}',
            uri,
          );
        }
        final decoded = const Utf8Decoder().convert(response.bodyBytes);
        print('✅ Successfully decoded response: ${decoded.length} chars');
        return decoded;
      } catch (e, st) {
        print('❌ tryFetch failed: $e');
        print('❌ Stack: $st');
        rethrow;
      }
    }

    try {
      print('🔗 Trying HTTP endpoint: $_endpoint');
      return await tryFetch(Uri.parse(_endpoint));
    } on http.ClientException catch (error, stackTrace) {
      print('⚠️ HTTP fetch failed, retrying with HTTPS: $error');
      print('🔗 Trying HTTPS endpoint: $_fallbackEndpoint');
      return tryFetch(Uri.parse(_fallbackEndpoint));
    } catch (error, stackTrace) {
      print('❌ _downloadCatalogue failed completely: $error');
      print('❌ Stack: $stackTrace');
      rethrow;
    }
  }
}

final vpnGateApiProvider = Provider<VpnGateApi>((ref) {
  return VpnGateApi();
});
