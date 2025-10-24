import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/server.dart';

class ServerRepository {
  const ServerRepository();

  Future<List<Server>> loadServers() async {
    final jsonString = await rootBundle.loadString('assets/servers.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final servers = (data['servers'] as List<dynamic>)
        .map((e) => Server.fromJson(e as Map<String, dynamic>))
        .toList();
    return servers;
  }
}

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  return const ServerRepository();
});

final serversProvider = FutureProvider<List<Server>>((ref) async {
  final repo = ref.watch(serverRepositoryProvider);
  return repo.loadServers();
});
