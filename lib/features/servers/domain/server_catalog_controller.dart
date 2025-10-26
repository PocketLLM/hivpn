import 'dart:async';
import 'dart:developer' as developer;
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
    print('🎯🎯🎯 ServerCatalogController constructor called!');
    developer.log('🎯 ServerCatalogController constructor called!', name: 'ServerCatalogController');
    _init();
  }

  final Ref _ref;
  Timer? _latencyTimer;

  Future<void> _init() async {
    print('🚀🚀🚀 ServerCatalogController._init() called');
    developer.log('🚀 ServerCatalogController._init() called', name: 'ServerCatalogController');
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('📡📡📡 Calling ServerRepository.loadServers()');
      developer.log('📡 Calling ServerRepository.loadServers()', name: 'ServerCatalogController');
      final servers = await _ref.read(serverRepositoryProvider).loadServers();
      print('✅✅✅ Received ${servers.length} servers from repository');
      developer.log('✅ Received ${servers.length} servers from repository', name: 'ServerCatalogController');

      final prefs = _ref.read(serverPreferencesRepositoryProvider);
      final favorites = prefs?.loadFavorites() ?? <String>{};
      state = state.copyWith(
        servers: servers,
        favorites: favorites,
        isLoading: false,
      );
      developer.log('✅ State updated with ${servers.length} servers', name: 'ServerCatalogController');

      await _measureLatency();
      _latencyTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        unawaited(_measureLatency());
      });
    } catch (error, stackTrace) {
      developer.log('❌ Error in _init()', name: 'ServerCatalogController', error: error, stackTrace: stackTrace);
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
      try {
        final stopwatch = Stopwatch()..start();
        final uri = Uri.parse('https://${server.endpoint.split(':').first}');
        final socket = await Socket.connect(uri.host, 443,
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

  /// Refresh servers from VPN Gate API
  Future<void> refreshServers() async {
    developer.log('🔄 Refreshing servers...', name: 'ServerCatalogController');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final servers = await _ref.read(serverRepositoryProvider).loadServers();
      developer.log('✅ Refreshed ${servers.length} servers', name: 'ServerCatalogController');

      final prefs = _ref.read(serverPreferencesRepositoryProvider);
      final favorites = prefs?.loadFavorites() ?? <String>{};
      state = state.copyWith(
        servers: servers,
        favorites: favorites,
        isLoading: false,
      );

      await _measureLatency();
    } catch (error, stackTrace) {
      developer.log('❌ Error refreshing servers', name: 'ServerCatalogController', error: error, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  @override
  void dispose() {
    _latencyTimer?.cancel();
    super.dispose();
  }
}
