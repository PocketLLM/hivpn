import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/server_repository.dart';
import 'server.dart';

class ServerSelectionNotifier extends StateNotifier<Server?> {
  ServerSelectionNotifier(this._servers)
      : super(_servers.isNotEmpty ? _servers.first : null);

  final List<Server> _servers;

  void select(Server server) {
    state = server;
  }
}

final selectedServerProvider =
    StateNotifierProvider<ServerSelectionNotifier, Server?>((ref) {
  final serversAsync = ref.watch(serversProvider);
  return serversAsync.maybeWhen(
    data: (servers) => ServerSelectionNotifier(servers),
    orElse: () => ServerSelectionNotifier(const []),
  );
});
