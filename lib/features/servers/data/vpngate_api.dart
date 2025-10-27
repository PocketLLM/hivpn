import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class VpnGateCatalogueException implements Exception {
  const VpnGateCatalogueException(this.message, {this.uri, this.cause});

  final String message;
  final Uri? uri;
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('VpnGateCatalogueException: $message');
    if (uri != null) {
      buffer.write(' (uri: $uri)');
    }
    if (cause != null) {
      buffer.write(' cause=$cause');
    }
    return buffer.toString();
  }
}

class VpnGateDomainForbiddenException extends VpnGateCatalogueException {
  const VpnGateDomainForbiddenException({required Uri uri, required this.snippet})
      : super('Domain forbidden', uri: uri);

  final String snippet;

  @override
  String toString() => '${super.toString()} snippet=${snippet.trim()}';
}

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

  static const _baseEndpoints = <String>{
    'https://www.vpngate.net/api/iphone/',
    'http://www.vpngate.net/api/iphone/',
    'https://vpngate.net/api/iphone/',
    'http://vpngate.net/api/iphone/',
    'https://global.vpngate.net/api/iphone/',
    'http://global.vpngate.net/api/iphone/',
  };
  static const _defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    'Accept': 'text/plain,application/json;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Referer': 'http://www.vpngate.net/',
  };

  final http.Client _client;

  Future<List<VpnGateRecord>> fetchServers() async {
    print('🎬 VpnGateApi.fetchServers() called');
    try {
      final body = await _downloadCatalogue();
      print('📥 Downloaded catalogue: ${body.length} bytes');

      if (body.isEmpty) {
        developer.log('❌ Catalogue is empty', name: 'VpnGateApi');
        throw const VpnGateCatalogueException('VPN Gate returned an empty catalogue');
      }

      final segments = body.split('#');
      print('📊 Split into ${segments.length} segments');

      if (segments.length < 2) {
        developer.log('❌ Not enough segments (need at least 2)', name: 'VpnGateApi');
        throw const VpnGateCatalogueException('VPN Gate response missing CSV segment');
      }

      final csvString = segments[1].replaceAll('*', '');
      print('📄 CSV string length: ${csvString.length}');

      if (csvString.contains('Domain forbidden')) {
        developer.log('⛔️ Catalogue response indicates domain forbidden in CSV segment',
            name: 'VpnGateApi');
        throw const VpnGateCatalogueException(
          'Domain forbidden in CSV segment',
        );
      }

      final cleanedCsv = csvString.trim();
      final rows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(cleanedCsv);
      developer.log('📋 Parsed ${rows.length} rows from CSV', name: 'VpnGateApi');

      if (rows.length <= 1) {
        developer.log('❌ Not enough rows (need more than 1)', name: 'VpnGateApi');
        throw const VpnGateCatalogueException('VPN Gate CSV did not contain server rows');
      }

      final header = rows.first
          .map((value) => value.toString().trim())
          .toList(growable: false);
      developer.log('🔑 Header: $header', name: 'VpnGateApi');

      final records = <VpnGateRecord>[];
      var skippedEmptyConfig = 0;
      var skippedMalformed = 0;
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty ||
            row.every(
              (value) =>
                  value == null || value.toString().trim().isEmpty,
            )) {
          skippedMalformed++;
          continue;
        }
        if (row.length != header.length) {
          skippedMalformed++;
          developer.log(
            '⚠️ Row $i length mismatch: rowLen=${row.length} headerLen=${header.length}',
            name: 'VpnGateApi',
          );
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
          skippedEmptyConfig++;
          developer.log(
            '⏭️ Skipping row $i: host=$host, ip=$ip, config_len=${config.length}',
            name: 'VpnGateApi',
          );
          continue;
        }
        records.add(VpnGateRecord.fromMap(map));
      }
      developer.log(
        '✅ VPNGate catalogue parsed: ${records.length} records (skippedEmptyConfig=$skippedEmptyConfig, skippedMalformed=$skippedMalformed)',
        name: 'VpnGateApi',
      );

      if (records.isEmpty) {
        throw const VpnGateCatalogueException('Parsed zero usable VPN Gate servers');
      }
      return records;
    } on VpnGateCatalogueException {
      rethrow;
    } catch (e, st) {
      developer.log('❌ fetchServers() failed: $e', name: 'VpnGateApi', error: e, stackTrace: st);
      throw VpnGateCatalogueException(
        'Failed to parse VPN Gate catalogue',
        cause: e,
      );
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
        final decoded = const Utf8Decoder(allowMalformed: true)
            .convert(response.bodyBytes);
        final snippet = decoded.substring(0, decoded.length > 200 ? 200 : decoded.length);
        developer.log('🧾 Response preview: ${snippet.replaceAll('\n', ' ')}', name: 'VpnGateApi');
        if (decoded.contains('Domain forbidden')) {
          developer.log('⛔️ Response body reports domain forbidden',
              name: 'VpnGateApi');
          throw VpnGateDomainForbiddenException(uri: uri, snippet: snippet);
        }
        developer.log('✅ Successfully decoded response: ${decoded.length} chars',
            name: 'VpnGateApi');
        return decoded;
      } catch (e, st) {
        print('❌ tryFetch failed: $e');
        print('❌ Stack: $st');
        rethrow;
      }
    }

    try {
      final attempts = <Uri>[];
      final errors = <String>[];
      for (final uri in _candidateUris()) {
        attempts.add(uri);
        developer.log('🔗 Trying endpoint: $uri', name: 'VpnGateApi');
        try {
          final body = await tryFetch(uri);
          if (body.isEmpty) {
            errors.add('Empty body from $uri');
            continue;
          }
          return body;
        } on VpnGateDomainForbiddenException catch (error) {
          errors.add('${error.message} at ${error.uri}');
          developer.log(
            '⛔️ Domain forbidden at ${error.uri}. Snippet: ${error.snippet}',
            name: 'VpnGateApi',
          );
          continue;
        } on http.ClientException catch (error, stackTrace) {
          errors.add('ClientException(${error.message}) at $uri');
          developer.log('⚠️ ClientException for $uri: $error',
              name: 'VpnGateApi', error: error, stackTrace: stackTrace);
          continue;
        } catch (error, stackTrace) {
          errors.add('$error at $uri');
          developer.log('⚠️ Unexpected error for $uri: $error',
              name: 'VpnGateApi', error: error, stackTrace: stackTrace);
          continue;
        }
      }
      throw VpnGateCatalogueException(
        'All VPN Gate endpoints failed',
        cause: errors,
        uri: attempts.isNotEmpty ? attempts.last : null,
      );
    } catch (error, stackTrace) {
      print('❌ _downloadCatalogue failed completely: $error');
      print('❌ Stack: $stackTrace');
      rethrow;
    }
  }

  Iterable<Uri> _candidateUris() sync* {
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();
    final seen = <String>{};
    for (final endpoint in _baseEndpoints) {
      final base = Uri.parse(endpoint);
      final withNonce = base.replace(queryParameters: {
        ...base.queryParameters,
        '_': nonce,
      });
      if (seen.add(withNonce.toString())) {
        yield withNonce;
      }
      if (seen.add(base.toString())) {
        yield base;
      }
    }
  }
}

final vpnGateApiProvider = Provider<VpnGateApi>((ref) {
  return VpnGateApi();
});
