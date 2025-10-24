import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/server.dart';
import '../domain/server_providers.dart';
import '../../session/domain/session_controller.dart';
import '../../session/domain/session_status.dart';
import '../../../widgets/server_tile.dart';
import '../../../services/haptics/haptics_service.dart';

class ServerPickerSheet extends ConsumerWidget {
  const ServerPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(serverCatalogProvider);
    final selectedServer = ref.watch(selectedServerProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final isConnected = sessionState.status == SessionStatus.connected;
    final servers = catalog.sortedServers;

    if (servers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
          onFavoriteToggle: () {
            unawaited(
              ref.read(serverCatalogProvider.notifier).toggleFavorite(server),
            );
          },
          onTap: isConnected
              ? null
              : () {
                  unawaited(ref.read(hapticsServiceProvider).selection());
                  ref.read(selectedServerProvider.notifier).select(server);
                  Navigator.of(context).pop();
                },
        );
      },
    );
  }
}
