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
    final hostLabel =
        (server.hostName?.isNotEmpty ?? false) ? server.hostName! : server.endpoint;
    final ipLabel =
        (server.ip?.isNotEmpty ?? false) ? server.ip! : server.endpoint.split(':').first;
    final locationSegments = [
      if (server.countryName?.isNotEmpty ?? false) server.countryName!,
      if (server.regionName?.isNotEmpty ?? false) server.regionName!,
      if (server.cityName?.isNotEmpty ?? false) server.cityName!,
    ];
    final locationLabel = locationSegments.isNotEmpty
        ? locationSegments.join(' • ')
        : '${l10n.locations}: ${server.countryCode.toUpperCase()}';
    final pingValue = latencyMs ?? server.pingMs;
    final pingText = (pingValue != null && pingValue < 9999) ? '$pingValue ms' : '--';
    final downloadValue = server.downloadSpeed ?? server.bandwidth;
    final uploadValue = server.uploadSpeed ?? downloadValue;
    final downloadText =
        downloadValue != null ? _formatBandwidth(downloadValue) : '--';
    final uploadText =
        uploadValue != null ? _formatBandwidth(uploadValue) : '--';
    final hasSessions = server.sessions != null;

    return ListTile(
      onTap: onTap,
      selected: selected,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
        child: Text(
          _flagEmoji(server.countryCode),
          style: const TextStyle(fontSize: 20),
        ),
      ),
      title: Text(server.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            locationLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Host: $hostLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            'IP: $ipLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoBadge(
                icon: Icons.speed,
                label: 'Ping $pingText',
                theme: theme,
              ),
              _InfoBadge(
                icon: Icons.arrow_downward,
                label: 'Down $downloadText',
                theme: theme,
              ),
              _InfoBadge(
                icon: Icons.arrow_upward,
                label: 'Up $uploadText',
                theme: theme,
              ),
              if (hasSessions)
                _InfoBadge(
                  icon: Icons.people_alt_outlined,
                  label: 'Sessions ${server.sessions}',
                  theme: theme,
                ),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  String _formatBandwidth(int bytesPerSecond) {
    if (bytesPerSecond <= 0) {
      return '--';
    }
    const units = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    var value = bytesPerSecond.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }
    return '${value.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  String _flagEmoji(String countryCode) {
    const base = 0x1F1E6;
    return countryCode.toUpperCase().characters.map((char) {
      final codeUnit = char.codeUnitAt(0) - 0x41 + base;
      return String.fromCharCode(codeUnit);
    }).join();
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
