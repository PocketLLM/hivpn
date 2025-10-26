import 'package:flutter/material.dart';

import 'package:characters/characters.dart';

import '../features/servers/domain/server.dart';
import '../l10n/app_localizations.dart';

class ServerTile extends StatelessWidget {
  const ServerTile({
    super.key,
    required this.server,
    required this.onTap,
    this.selected = false,
    this.latencyMs,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  final Server server;
  final VoidCallback? onTap;
  final bool selected;
  final int? latencyMs;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return ListTile(
      onTap: onTap,
      selected: selected,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
        child: Text(_flagEmoji(server.countryCode)),
      ),
      title: Text(server.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${l10n.locations}: ${server.countryCode.toUpperCase()}'),
          if ((server.hostName?.isNotEmpty ?? false) ||
              (server.ip?.isNotEmpty ?? false))
            Text(
              _buildDetailsText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  String _buildDetailsText() {
    final ping = server.pingMs != null ? '${server.pingMs} ms' : null;
    final ip = (server.ip?.isNotEmpty ?? false)
        ? server.ip
        : server.endpoint.split(':').first;
    if (ping != null && ip != null && ip.isNotEmpty) {
      return 'Ping: $ping • IP: $ip';
    }
    if (ping != null) {
      return 'Ping: $ping';
    }
    if (ip != null && ip.isNotEmpty) {
      return 'IP: $ip';
    }
    return '';
  }

  String _flagEmoji(String countryCode) {
    const base = 0x1F1E6;
    return countryCode.toUpperCase().characters.map((char) {
      final codeUnit = char.codeUnitAt(0) - 0x41 + base;
      return String.fromCharCode(codeUnit);
    }).join();
  }
}
