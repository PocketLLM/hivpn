import 'wg_config.dart';

abstract class VpnPort {
  Future<bool> prepare();
  Future<bool> connect(WgConfig config);
  Future<void> disconnect();
  Future<bool> isConnected();
}
