import 'dart:convert';

import '../../../core/errors/app_error.dart';

/// VPN server model from VPN Gate API
class Vpn {
  final String hostName;
  final String ip;
  final String ping;
  final int speed;
  final String countryLong;
  final String countryShort;
  final int numVpnSessions;
  final String openVpnConfigDataBase64;

  Vpn({
    required this.hostName,
    required this.ip,
    required this.ping,
    required this.speed,
    required this.countryLong,
    required this.countryShort,
    required this.numVpnSessions,
    required this.openVpnConfigDataBase64,
  });

  factory Vpn.fromJson(Map<String, dynamic> json) {
    return Vpn(
      hostName: json['HostName'] ?? '',
      ip: json['IP'] ?? '',
      ping: json['Ping'] ?? '0',
      speed: json['Speed'] ?? 0,
      countryLong: json['CountryLong'] ?? '',
      countryShort: json['CountryShort'] ?? '',
      numVpnSessions: json['NumVpnSessions'] ?? 0,
      openVpnConfigDataBase64: json['OpenVPN_ConfigData_Base64'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'HostName': hostName,
      'IP': ip,
      'Ping': ping,
      'Speed': speed,
      'CountryLong': countryLong,
      'CountryShort': countryShort,
      'NumVpnSessions': numVpnSessions,
      'OpenVPN_ConfigData_Base64': openVpnConfigDataBase64,
    };
  }

  /// Get decoded OpenVPN config
  String get openVpnConfig {
    final raw = openVpnConfigDataBase64.trim();
    if (raw.isEmpty) {
      throw const AppError('OpenVPN configuration is missing.');
    }

    try {
      final normalized = base64.normalize(raw);
      final decodedBytes = base64.decode(normalized);
      if (decodedBytes.isEmpty) {
        throw const FormatException('Decoded OpenVPN config is empty.');
      }

      final decoded = utf8.decode(decodedBytes);
      if (decoded.trim().isEmpty) {
        throw const FormatException(
          'Decoded OpenVPN config is empty after trim.',
        );
      }

      return decoded;
    } on FormatException catch (error) {
      throw AppError('Failed to decode OpenVPN configuration.', cause: error);
    } catch (error) {
      if (error is AppError) {
        rethrow;
      }
      throw AppError(
        'An unexpected error occurred while decoding the configuration.',
        cause: error,
      );
    }
  }

  @override
  String toString() {
    return 'Vpn(hostName: $hostName, ip: $ip, country: $countryLong, ping: $ping ms)';
  }
}

