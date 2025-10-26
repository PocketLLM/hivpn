import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'server.dart';
import '../data/server_preferences_repository.dart';
import '../data/server_repository.dart';

class ServerCatalogState {
  const ServerCatalogState({
    this.servers = const [],
    this.favorites = const <String>{},
    this.latencyMs = const {},
    this.query = '',
    this.isLoading = true,
    this.error,
  });

  final List<Server> servers;
  final Set<String> favorites;
  final Map<String, int> latencyMs;
  final String query;
  final bool isLoading;
  final String? error;

  List<Server> get sortedServers {
    final comparator = (Server a, Server b) {
      final favA = favorites.contains(a.id);
      final favB = favorites.contains(b.id);
      if (favA != favB) {
        return favA ? -1 : 1;
      }
      final latencyA = latencyMs[a.id] ?? 9999;
      final latencyB = latencyMs[b.id] ?? 9999;
      if (latencyA != latencyB) {
        return latencyA.compareTo(latencyB);
      }
      return a.name.compareTo(b.name);
    };
    final filtered = query.isEmpty
        ? servers
        : servers
            .where((s) =>
                s.name.toLowerCase().contains(query.toLowerCase()) ||
                s.countryCode.toLowerCase().contains(query.toLowerCase()))
            .toList();
    final sorted = [...filtered];
    sorted.sort(comparator);
    return sorted;
  }

  ServerCatalogState copyWith({
    List<Server>? servers,
    Set<String>? favorites,
    Map<String, int>? latencyMs,
    String? query,
    bool? isLoading,
    String? error,
  }) {
    return ServerCatalogState(
      servers: servers ?? this.servers,
      favorites: favorites ?? this.favorites,
      latencyMs: latencyMs ?? this.latencyMs,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ServerCatalogController extends StateNotifier<ServerCatalogState> {
  ServerCatalogController(this._ref)
      : super(const ServerCatalogState()) {
    _init();
  }

  final Ref _ref;
  Timer? _latencyTimer;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final servers = await _ref.read(serverRepositoryProvider).loadServers();
      final prefs = _ref.read(serverPreferencesRepositoryProvider);
      final favorites = prefs?.loadFavorites() ?? <String>{};
      state = state.copyWith(
        servers: servers,
        favorites: favorites,
        isLoading: false,
      );
      await _measureLatency();
      _latencyTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        unawaited(_measureLatency());
      });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> _measureLatency() async {
    if (state.servers.isEmpty) {
      return;
    }
    final results = <String, int>{};
    for (final server in state.servers) {
      if (server.pingMs != null) {
        results[server.id] = server.pingMs!;
        continue;
      }
      try {
        final stopwatch = Stopwatch()..start();
        final parts = server.endpoint.split(':');
        final host = parts.isNotEmpty ? parts.first : server.endpoint;
        final port = parts.length >= 2
            ? int.tryParse(parts[1]) ?? 443
            : 443;
        final socket = await Socket.connect(host, port,
            timeout: const Duration(seconds: 3));
        socket.destroy();
        stopwatch.stop();
        results[server.id] = stopwatch.elapsedMilliseconds;
      } catch (_) {
        results[server.id] = 9999;
      }
    }
    state = state.copyWith(latencyMs: results);
  }

  void search(String query) {
    state = state.copyWith(query: query);
  }

  Future<void> toggleFavorite(Server server) async {
    final updated = {...state.favorites};
    if (updated.contains(server.id)) {
      updated.remove(server.id);
    } else {
      updated.add(server.id);
    }
    state = state.copyWith(favorites: updated);
    await _ref
        .read(serverPreferencesRepositoryProvider)
        ?.saveFavorites(updated);
  }

  Future<void> clearFavorites() async {
    state = state.copyWith(favorites: <String>{});
    await _ref
        .read(serverPreferencesRepositoryProvider)
        ?.saveFavorites(state.favorites);
  }

  Future<void> rememberSelection(Server server) async {
    await _ref
        .read(serverPreferencesRepositoryProvider)
        ?.saveLastServerId(server.id);
  }

  @override
  void dispose() {
    _latencyTimer?.cancel();
    super.dispose();
  }
}
