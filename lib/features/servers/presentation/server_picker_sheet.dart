import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/server.dart';
import '../domain/server_providers.dart';
import '../../session/domain/session_controller.dart';
import '../../session/domain/session_status.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/haptics/haptics_service.dart';
import '../../../widgets/server_tile.dart';

class ServerPickerSheet extends ConsumerStatefulWidget {
  const ServerPickerSheet({super.key});

  @override
  ConsumerState<ServerPickerSheet> createState() => _ServerPickerSheetState();
}

class _ServerPickerSheetState extends ConsumerState<ServerPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim().toLowerCase();
    });
  }

  bool _matchesQuery(Server server) {
    if (_query.isEmpty) {
      return true;
    }
    final needle = _query;
    final fields = <String?>[
      server.countryName,
      server.countryCode,
      server.name,
      server.hostName,
      server.cityName,
      server.regionName,
    ];
    return fields.whereType<String>().any(
          (field) => field.toLowerCase().contains(needle),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(serverCatalogProvider);
    final selectedServer = ref.watch(selectedServerProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final isConnected = sessionState.status == SessionStatus.connected;
    final serversAsyncValue = ref.watch(serversAsync);

    final allServers = catalog.sortedServers;
    final filteredServers =
        allServers.where(_matchesQuery).toList(growable: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.locations} (${allServers.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.connectionQualityRefresh,
                onPressed: () async {
                  await ref
                      .read(serverCatalogProvider.notifier)
                      .refreshServers();
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              labelText: l10n.searchLocations,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.showingLocations(filteredServers.length, allServers.length),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ),
        ),
        Expanded(
          child: serversAsyncValue.when(
            data: (_) {
              if (filteredServers.isEmpty) {
                final message = _query.isEmpty
                    ? l10n.failedToLoadServers
                    : l10n.noLocationsMatch(_searchController.text.trim());
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: filteredServers.length,
                itemBuilder: (context, index) {
                  final server = filteredServers[index];
                  return ServerTile(
                    server: server,
                    selected: selectedServer?.id == server.id,
                    onTap: isConnected
                        ? null
                        : () {
                            unawaited(
                              ref.read(hapticsServiceProvider).selection(),
                            );
                            ref
                                .read(selectedServerProvider.notifier)
                                .select(server);
                            Navigator.of(context).pop();
                          },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('${l10n.failedToLoadServers}: $err'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
