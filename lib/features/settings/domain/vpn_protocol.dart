import 'package:collection/collection.dart';

enum VpnProtocol { wireGuard, openVpn, ikev2 }

enum VpnDnsOption { cloudflare, google, custom }

extension VpnProtocolX on VpnProtocol {
  String get label {
    switch (this) {
      case VpnProtocol.wireGuard:
        return 'WireGuard';
      case VpnProtocol.openVpn:
        return 'OpenVPN (coming soon)';
      case VpnProtocol.ikev2:
        return 'IKEv2 (coming soon)';
    }
  }

  bool get isSupported => this == VpnProtocol.wireGuard;
}

extension VpnDnsOptionX on VpnDnsOption {
  String get label {
    switch (this) {
      case VpnDnsOption.cloudflare:
        return 'Cloudflare (1.1.1.1)';
      case VpnDnsOption.google:
        return 'Google (8.8.8.8)';
      case VpnDnsOption.custom:
        return 'Custom DNS';
    }
  }
}

VpnProtocol protocolFromName(String? name) {
  return VpnProtocol.values.firstWhereOrNull((p) => p.name == name) ??
      VpnProtocol.wireGuard;
}

VpnDnsOption dnsOptionFromName(String? name) {
  return VpnDnsOption.values.firstWhereOrNull((p) => p.name == name) ??
      VpnDnsOption.cloudflare;
}
