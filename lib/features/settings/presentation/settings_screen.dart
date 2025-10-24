import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/domain/connection_history_notifier.dart';
import '../../servers/domain/server_catalog_controller.dart';
import '../../../services/apps/installed_apps_provider.dart';
import '../domain/settings_controller.dart';
import '../domain/settings_state.dart';
import '../domain/split_tunnel_config.dart';
import '../domain/vpn_protocol.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final appsAsync = ref.watch(installedAppsProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      children: [
        Text('Connection', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _ProtocolSection(settings: settings, controller: controller),
        const SizedBox(height: 24),
        _SplitTunnelSection(
          settings: settings,
          controller: controller,
          appsAsync: appsAsync,
        ),
        const SizedBox(height: 24),
        _AutoConnectSection(settings: settings, controller: controller),
        const SizedBox(height: 32),
        Text('Appearance', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _AppearanceSection(settings: settings, controller: controller),
        const SizedBox(height: 32),
        Text('Privacy', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _PrivacySection(ref: ref),
      ],
    );
  }
}

class _ProtocolSection extends StatelessWidget {
  const _ProtocolSection({required this.settings, required this.controller});

  final SettingsState settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Protocol', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButton<VpnProtocol>(
            value: settings.protocol.protocol,
            items: VpnProtocol.values
                .map(
                  (protocol) => DropdownMenuItem(
                    value: protocol,
                    child: Text(protocol.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.setProtocol(value);
              }
            },
          ),
          const SizedBox(height: 12),
          Text('MTU (${settings.protocol.mtu})',
              style: theme.textTheme.bodySmall),
          Slider(
            value: settings.protocol.mtu.toDouble(),
            min: 1200,
            max: 1500,
            divisions: 30,
            onChanged: (value) => controller.setMtu(value.round()),
          ),
          const SizedBox(height: 8),
          Text('Keepalive (${settings.protocol.keepaliveSeconds}s)',
              style: theme.textTheme.bodySmall),
          Slider(
            value: settings.protocol.keepaliveSeconds.toDouble(),
            min: 0,
            max: 120,
            divisions: 24,
            onChanged: (value) => controller.setKeepalive(value.round()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: VpnDnsOption.values
                .map(
                  (option) => ChoiceChip(
                    label: Text(option.label),
                    selected: settings.protocol.dnsOption == option,
                    onSelected: (_) => controller.setDnsOption(option),
                  ),
                )
                .toList(),
          ),
          if (settings.protocol.dnsOption == VpnDnsOption.custom) ...[
            const SizedBox(height: 12),
            TextFormField(
              initialValue: settings.protocol.customDnsServers.join(', '),
              decoration: const InputDecoration(
                labelText: 'Custom DNS servers',
                hintText: 'e.g. 9.9.9.9, 149.112.112.112',
              ),
              onFieldSubmitted: (value) {
                final servers = value
                    .split(',')
                    .map((e) => e.trim())
                    .where((element) => element.isNotEmpty)
                    .toList();
                controller.setCustomDns(servers);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SplitTunnelSection extends StatelessWidget {
  const _SplitTunnelSection({
    required this.settings,
    required this.controller,
    required this.appsAsync,
  });

  final SettingsState settings;
  final SettingsController controller;
  final AsyncValue<List<InstalledAppInfo>> appsAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            value: settings.splitTunnel.isEnabled,
            title: const Text('Split tunneling'),
            subtitle: const Text('Route only selected apps through HiVPN'),
            onChanged: (value) {
              controller.toggleSplitTunnel(value);
            },
          ),
          if (settings.splitTunnel.isEnabled)
            appsAsync.when(
              data: (apps) => SizedBox(
                height: 180,
                child: ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final selected =
                        settings.splitTunnel.selectedPackages.contains(app.packageName);
                    return CheckboxListTile(
                      title: Text(app.appName),
                      subtitle: Text(app.packageName),
                      value: selected,
                      onChanged: (value) {
                        final packages = {...settings.splitTunnel.selectedPackages};
                        if (value == true) {
                          packages.add(app.packageName);
                        } else {
                          packages.remove(app.packageName);
                        }
                        controller.setSelectedPackages(packages);
                      },
                    );
                  },
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Unable to load apps: $err'),
              ),
            ),
        ],
      ),
    );
  }
}

class _AutoConnectSection extends StatelessWidget {
  const _AutoConnectSection({required this.settings, required this.controller});

  final SettingsState settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: settings.autoConnect.connectOnLaunch,
            title: const Text('Connect on launch'),
            onChanged: (value) {
              controller.setAutoConnect(onLaunch: value);
            },
          ),
          SwitchListTile.adaptive(
            value: settings.autoConnect.connectOnBoot,
            title: const Text('Connect on device boot'),
            onChanged: (value) {
              controller.setAutoConnect(onBoot: value);
            },
          ),
          SwitchListTile.adaptive(
            value: settings.autoConnect.reconnectOnNetworkChange,
            title: const Text('Reconnect on network change'),
            onChanged: (value) {
              controller.setAutoConnect(onNetworkChange: value);
            },
          ),
          SwitchListTile.adaptive(
            value: settings.batterySaverEnabled,
            title: const Text('Battery saver mode'),
            subtitle: const Text('Reduce background polling to save power'),
            onChanged: (value) {
              controller.setBatterySaver(value);
            },
          ),
          SwitchListTile.adaptive(
            value: settings.networkQualityMonitoring,
            title: const Text('Network quality monitoring'),
            subtitle: const Text('Detect packet loss and suggest faster servers'),
            onChanged: (value) {
              controller.setNetworkQuality(value);
            },
          ),
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.settings, required this.controller});

  final SettingsState settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final swatches = <String, Color>{
      'lavender': const Color(0xFFA78BFA),
      'aqua': const Color(0xFF38BDF8),
      'sunrise': const Color(0xFFF59E0B),
      'forest': const Color(0xFF22C55E),
    };
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: swatches.entries.map((entry) {
          final isSelected = entry.key == settings.accentSeed;
          return GestureDetector(
            onTap: () {
              controller.setAccentSeed(entry.key);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: entry.value,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : Colors.white24,
                  width: isSelected ? 3 : 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data controls', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.read(connectionHistoryProvider.notifier).clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connection history cleared.')),
              );
            },
            child: const Text('Clear connection history'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(serverCatalogProvider.notifier)
                  .clearFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites cleared.')),
              );
            },
            child: const Text('Clear favorites'),
          ),
        ],
      ),
    );
  }
}
