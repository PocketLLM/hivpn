import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/android/vpn_channel.dart';
import 'vpn_port.dart';

final vpnPortProvider = Provider<VpnPort>((ref) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidVpnChannel();
  }
  throw UnsupportedError('VpnPort not implemented for this platform');
});
