import 'package:flutter/material.dart';

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
        child: Text(server.countryCode.toUpperCase()),
      ),
      title: Text(server.name),
      subtitle: Text('Country: ${server.countryCode.toUpperCase()}'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
