import 'package:flutter_test/flutter_test.dart';

import 'package:hivpn/features/servers/domain/server.dart';
import 'package:hivpn/features/servers/domain/server_catalog_controller.dart';

void main() {
  test('sortedServers prioritizes favorites and latency', () {
    const servers = [
      Server(
        id: 'a',
        name: 'Alpha',
        countryCode: 'US',
        publicKey: 'key',
        endpoint: '1.1.1.1:51820',
        allowedIps: '0.0.0.0/0',
      ),
      Server(
        id: 'b',
        name: 'Beta',
        countryCode: 'DE',
        publicKey: 'key',
        endpoint: '2.2.2.2:51820',
        allowedIps: '0.0.0.0/0',
      ),
      Server(
        id: 'c',
        name: 'Gamma',
        countryCode: 'IN',
        publicKey: 'key',
        endpoint: '3.3.3.3:51820',
        allowedIps: '0.0.0.0/0',
      ),
    ];

    final state = ServerCatalogState(
      servers: servers,
      favorites: {'c'},
      latencyMs: {'a': 90, 'b': 70, 'c': 120},
    );

    final sorted = state.sortedServers;
    expect(sorted.first.id, 'c');
    expect(sorted[1].id, 'b');
    expect(sorted[2].id, 'a');
  });
}
