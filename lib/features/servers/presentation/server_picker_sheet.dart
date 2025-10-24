import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/server.dart';
import '../domain/server_catalog_controller.dart';
import '../domain/server_selection.dart';
import '../../session/domain/session_controller.dart';
import '../../session/domain/session_status.dart';
import '../../../widgets/server_tile.dart';

class ServerPickerSheet extends ConsumerWidget {
  const ServerPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(serverCatalogProvider);
    final selectedServer = ref.watch(selectedServerProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final isConnected = sessionState.status == SessionStatus.connected;

    final favorites = catalog.sortedServers
        .where((server) => catalog.favorites.contains(server.id))
        .toList();
    final allServers = catalog.sortedServers;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search locations',
              ),
              onChanged: ref.read(serverCatalogProvider.notifier).search,
            ),
          ),
          const SizedBox(height: 12),
          const TabBar(
            tabs: [
              Tab(text: 'Favorites'),
              Tab(text: 'All'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ServerList(
                  servers: favorites,
                  catalog: catalog,
                  selectedServer: selectedServer,
                  isConnected: isConnected,
                  ref: ref,
                ),
                _ServerList(
                  servers: allServers,
                  catalog: catalog,
                  selectedServer: selectedServer,
                  isConnected: isConnected,
                  ref: ref,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerList extends StatelessWidget {
  const _ServerList({
    required this.servers,
    required this.catalog,
    required this.selectedServer,
    required this.isConnected,
    required this.ref,
  });

  final List<Server> servers;
  final ServerCatalogState catalog;
  final Server? selectedServer;
  final bool isConnected;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (servers.isEmpty) {
      return const Center(child: Text('No servers available.'));
    }
    return ListView.builder(
      itemCount: servers.length,
      itemBuilder: (context, index) {
        final server = servers[index];
        return ServerTile(
          server: server,
          selected: selectedServer?.id == server.id,
          latencyMs: catalog.latencyMs[server.id],
          isFavorite: catalog.favorites.contains(server.id),
          onFavoriteToggle: () =>
              ref.read(serverCatalogProvider.notifier).toggleFavorite(server),
          onTap: isConnected
              ? null
              : () {
                  ref.read(selectedServerProvider.notifier).select(server);
                  Navigator.of(context).pop();
                },
        );
      },
    );
  }
}
