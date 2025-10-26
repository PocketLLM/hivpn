/// OpenVPN configuration for connection
class VpnConfig {
  final String config;
  final String country;
  final String username;
  final String password;

  const VpnConfig({
    required this.config,
    required this.country,
    this.username = '',
    this.password = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'config': config,
      'country': country,
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'VpnConfig(country: $country, hasConfig: ${config.isNotEmpty})';
  }
}

