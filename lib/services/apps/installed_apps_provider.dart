import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'installed_apps_service.dart';

final installedAppsServiceProvider = Provider<InstalledAppsService>((ref) {
  return InstalledAppsService();
});

final installedAppsProvider = FutureProvider<List<InstalledAppInfo>>((ref) async {
  final service = ref.watch(installedAppsServiceProvider);
  return service.fetchInstalledApps();
});
