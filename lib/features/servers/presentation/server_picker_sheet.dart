import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hivpn/core/utils/time.dart';
import 'package:hivpn/l10n/app_localizations.dart';

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

    final serversAsyncValue = ref.watch(serversAsync);

    return serversAsyncValue.when(
      data: (servers) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context);
        final refreshLabel =
            MaterialLocalizations.of(context).refreshIndicatorSemanticLabel;
        final lastUpdated = catalog.lastUpdated;
        final updatedLabel =
            lastUpdated != null ? formatDateTime(lastUpdated) : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Text(
                    '${l10n.locations} (${servers.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (updatedLabel != null)
                    Semantics(
                      label: 'Last updated $updatedLabel',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            updatedLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    tooltip: refreshLabel,
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref
                        .read(serverCatalogProvider.notifier)
                        .refreshServers(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(serverCatalogProvider.notifier)
                    .refreshServers(),
                child: servers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(l10n.failedToLoadServers),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: servers.length,
                        itemBuilder: (context, index) {
                          final server = servers[index];
                          return ServerTile(
                            server: server,
                            selected: selectedServer?.id == server.id,
                            onTap: isConnected
                                ? null
                                : () {
                                    unawaited(ref
                                        .read(hapticsServiceProvider)
                                        .selection());
                                    ref
                                        .read(selectedServerProvider.notifier)
                                        .select(server);
                                    Navigator.of(context).pop();
                                  },
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Failed to load servers: $err'),
      ),
    );
  }
}
