import 'package:flutter/material.dart';

import 'package:characters/characters.dart';

import '../features/servers/domain/server.dart';

class ServerTile extends StatelessWidget {
  const ServerTile({
    super.key,
    required this.server,
    required this.onTap,
    this.selected = false,
  });

  final Server server;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      selected: selected,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
        child: Text(_flagEmoji(server.countryCode)),
      ),
      title: Text(server.name),
      subtitle: Text('Country: ${server.countryCode.toUpperCase()}'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  String _flagEmoji(String countryCode) {
    const base = 0x1F1E6;
    return countryCode.toUpperCase().characters.map((char) {
      final codeUnit = char.codeUnitAt(0) - 0x41 + base;
      return String.fromCharCode(codeUnit);
    }).join();
  }
}
