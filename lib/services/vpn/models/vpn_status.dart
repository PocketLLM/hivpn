import 'dart:convert';

/// VPN connection status with traffic statistics
class VpnStatus {
  final String? duration;
  final String? lastPacketReceive;
  final String? byteIn;
  final String? byteOut;

  VpnStatus({
    this.duration,
    this.lastPacketReceive,
    this.byteIn,
    this.byteOut,
  });

  factory VpnStatus.fromJson(Map<String, dynamic> json) {
    return VpnStatus(
      duration: json['duration']?.toString(),
      lastPacketReceive: json['last_packet_receive']?.toString(),
      byteIn: json['byte_in']?.toString(),
      byteOut: json['byte_out']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'last_packet_receive': lastPacketReceive,
      'byte_in': byteIn,
      'byte_out': byteOut,
    };
  }

  @override
  String toString() {
    return 'VpnStatus(duration: $duration, byteIn: $byteIn, byteOut: $byteOut)';
  }
}

