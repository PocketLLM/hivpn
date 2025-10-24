import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'server.dart';
import 'server_catalog_controller.dart';
import 'server_selection.dart';

final serverCatalogProvider =
    StateNotifierProvider<ServerCatalogController, ServerCatalogState>((ref) {
  return ServerCatalogController(ref);
});

/// Alias retained for legacy imports that still expect [serverCatalogProvider].
final serverCatalogStateProvider = serverCatalogProvider;

final serversProvider = Provider<List<Server>>((ref) {
  final state = ref.watch(serverCatalogProvider);
  return state.sortedServers;
});

final serversAsync = Provider<AsyncValue<List<Server>>>((ref) {
  final state = ref.watch(serverCatalogProvider);
  if (state.isLoading) {
    return const AsyncValue.loading();
  }
  if (state.error != null) {
    return AsyncValue.error(state.error!, StackTrace.current);
  }
  return AsyncValue.data(state.sortedServers);
});

final selectedServerProvider =
    StateNotifierProvider<ServerSelectionNotifier, Server?>((ref) {
  return ServerSelectionNotifier(ref, serverCatalogProvider);
});

final serverLatencyProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(serverCatalogProvider).latencyMs;
});
