import 'dart:async';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36';

  final http.Client _client;

  Future<List<VpnGateRecord>> fetchServers() async {
    final uri = Uri.parse(_endpoint);
    final response = await _client
        .get(
          uri,
          headers: {
            'User-Agent': _userAgent,
            'Accept': 'text/plain, */*',
            'Connection': 'close',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Unexpected status code: ${response.statusCode}',
        uri,
      );
    }

    final body = response.body;
    if (body.isEmpty) {
      return const [];
    }

    if (body.toLowerCase().contains('domain forbidden')) {
      throw http.ClientException('Domain forbidden', uri);
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
      if (host.isEmpty || ip.isEmpty || config.isEmpty) {
        continue;
      }
      records.add(VpnGateRecord.fromMap(map));
    }
    return records;
  }
}

final vpnGateApiProvider = Provider<VpnGateApi>((ref) {
  return VpnGateApi();
});
