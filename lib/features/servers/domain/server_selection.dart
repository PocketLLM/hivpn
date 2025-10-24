import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hivpn/core/utils/iterable_extensions.dart';

import '../data/server_preferences_repository.dart';
import 'server.dart';
import 'server_catalog_controller.dart';

class ServerSelectionNotifier extends StateNotifier<Server?> {
  ServerSelectionNotifier(
    this._ref,
    this._catalogProvider,
  ) : super(null) {
    _subscription =
        _ref.listen<ServerCatalogState>(_catalogProvider, (prev, next) {
      _onCatalogUpdated(next);
    });
    _hydrate();
  }

  final Ref _ref;
  final StateNotifierProvider<ServerCatalogController, ServerCatalogState>
      _catalogProvider;
  ProviderSubscription<ServerCatalogState>? _subscription;

  void select(Server server) {
    state = server;
    _ref
        .read(_catalogProvider.notifier)
        .rememberSelection(server);
  }

  Future<void> _hydrate() async {
    final catalog = _ref.read(_catalogProvider);
    final prefs = _ref.read(serverPreferencesRepositoryProvider);
    final lastId = prefs?.loadLastServerId();
    if (catalog.servers.isEmpty) {
      state = null;
      return;
    }
    if (lastId != null) {
      final match = catalog.servers.firstWhereOrNull((s) => s.id == lastId);
      if (match != null) {
        state = match;
        return;
      }
    }
    state = catalog.servers.first;
  }

  void _onCatalogUpdated(ServerCatalogState catalog) {
    if (state != null) {
      final stillExists = catalog.servers.any((s) => s.id == state!.id);
      if (stillExists) {
        return;
      }
    }
    if (catalog.servers.isEmpty) {
      state = null;
      return;
    }
    state = catalog.servers.first;
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }
}
