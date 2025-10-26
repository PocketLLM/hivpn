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
        'HiVPN/1.0 (Flutter); (+https://github.com/HarshAndroid/FreeVPN-App-Flutter)'
  };

  final http.Client _client;

  Future<List<VpnGateRecord>> fetchServers() async {
    final body = await _downloadCatalogue();
    if (body.isEmpty) {
      return const [];
    }

    final segments = body.split('#');
    if (segments.length < 2) {
      return const [];
    }

    final csvString = segments[1].replaceAll('*', '');
    final rows = const CsvToListConverter(eol: '\n').convert(csvString);
    if (rows.length <= 1) {
      return const [];
    }

    final header = rows.first.map((value) => value.toString()).toList();
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
    developer.log('VPNGate catalogue parsed: ${records.length} records',
        name: 'VpnGateApi');
    return records;
  }

  Future<String> _downloadCatalogue() async {
    Future<http.Response> _performGet(Uri uri) {
      return _client.get(uri, headers: _defaultHeaders);
    }

    Future<String> _tryFetch(Uri uri) async {
      final response = await _performGet(uri);
      developer.log(
        'VPNGate response: status=${response.statusCode} length=${response.contentLength ?? response.bodyBytes.length} uri=$uri',
        name: 'VpnGateApi',
      );
      if (response.statusCode != 200) {
        throw http.ClientException(
          'Unexpected status code: ${response.statusCode}',
          uri,
        );
      }
      return const Utf8Decoder().convert(response.bodyBytes);
    }

    try {
      return await _tryFetch(Uri.parse(_endpoint));
    } on http.ClientException catch (error, stackTrace) {
      developer.log('VPNGate fetch failed, retrying with HTTPS',
          name: 'VpnGateApi', error: error, stackTrace: stackTrace);
      return _tryFetch(Uri.parse(_fallbackEndpoint));
    }
  }
}

final vpnGateApiProvider = Provider<VpnGateApi>((ref) {
  return VpnGateApi();
});
