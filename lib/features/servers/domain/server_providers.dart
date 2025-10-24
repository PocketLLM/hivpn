import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'server.dart';
import 'server_catalog_controller.dart' as catalog;
import 'server_selection.dart' as selection;

export 'server_catalog_controller.dart'
    show ServerCatalogController, ServerCatalogState;
export 'server_selection.dart' show ServerSelectionNotifier;

final StateNotifierProvider<ServerCatalogController, ServerCatalogState>
    serverCatalogProvider = catalog.serverCatalogProvider;
final StateNotifierProvider<ServerSelectionNotifier, Server?>
    selectedServerProvider = selection.selectedServerProvider;

final Provider<List<Server>> serversProvider = Provider<List<Server>>((ref) {
  final state = ref.watch(serverCatalogProvider);
  return state.sortedServers;
});
