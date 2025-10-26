import 'package:equatable/equatable.dart';

class IpInfo extends Equatable {
  const IpInfo({
    required this.ip,
    required this.country,
    required this.region,
    required this.city,
    required this.isp,
    required this.zip,
    required this.timezone,
  });

  factory IpInfo.fromJson(Map<String, dynamic> json) {
    return IpInfo(
      ip: (json['query'] as String?)?.trim() ?? '',
      country: (json['country'] as String?)?.trim() ?? '',
      region: (json['regionName'] as String?)?.trim() ?? '',
      city: (json['city'] as String?)?.trim() ?? '',
      isp: (json['isp'] as String?)?.trim() ?? '',
      zip: (json['zip'] as String?)?.trim() ?? '',
      timezone: (json['timezone'] as String?)?.trim() ?? '',
    );
  }

  final String ip;
  final String country;
  final String region;
  final String city;
  final String isp;
  final String zip;
  final String timezone;

  String get formattedLocation {
    final parts = <String>[
      if (city.isNotEmpty) city,
      if (region.isNotEmpty) region,
      if (country.isNotEmpty) country,
    ];
    if (parts.isEmpty) {
      return '';
    }
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [ip, country, region, city, isp, zip, timezone];
}
