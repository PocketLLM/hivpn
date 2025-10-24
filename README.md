# HiVPN

HiVPN is a dark-themed Flutter VPN client MVP for Android that unlocks one-hour WireGuard sessions after the user watches a rewarded advertisement. The architecture separates presentation, application, and infrastructure concerns and keeps the codebase ready for an iOS packet tunnel extension in a future iteration.

## Project structure

```
lib/
  app/                # App root and theme wiring
  core/               # Errors, utilities
  theme/              # Color tokens and Material 3 theme
  services/           # Ads, storage, time, VPN abstractions
  platform/           # Method channel bridges (Android)
  features/
    home/             # Home screen and primary UX
    history/          # Connection history timeline and metrics
    onboarding/       # Spotlight tour (tutorial_coach_mark)
    servers/          # Server models and asset repository
    settings/         # Protocol, auto-connect, split tunneling controls
    session/          # Session domain, countdown, controller
    speedtest/        # Speed test controller, UI, and endpoints loader
  widgets/            # Shared UI components
assets/
  servers.json        # Static server catalogue
  reference/          # Visual reference material from design
  speedtest_endpoints.json # Download/upload/ping configuration
```

All business logic lives in controllers and services. Widgets receive the data they need from Riverpod providers.

## Getting started

### Prerequisites

* Flutter 3.22 or newer
* Android Studio / command-line Android SDK (API 34 recommended, minSdk 26)
* Dart 3.3+

### Setup

1. Fetch dependencies and generate freezed/json_serializable output:

   ```bash
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. Run the app on an Android 8.0 (API 26) or newer device/emulator:

   ```bash
   flutter run
   ```

### Android build notes

* The app includes a foreground `VpnService` shell (`WireGuardService`) that exposes a `MethodChannel` (`com.example.vpn/VpnChannel`). The native layer owns the persistent telemetry notification (channel `hivpn.tunnel`) with 1 Hz updates while interactive, ~15 s updates in doze, and actions to disconnect or return to Flutter for an “extend session” ad gate.
* Kotlin Gradle plugin 2.1.0 ships with AGP 8.7.0. Upgrade your local Android Studio/Gradle wrapper if builds warn about the Kotlin toolchain.
* Rewarded ads use Google test identifiers (`ca-app-pub-3940256099942544/5224354917`). Replace with production IDs before release.
* Update `android/app/src/main/AndroidManifest.xml` with your final AdMob app ID and consider requesting the `POST_NOTIFICATIONS` runtime permission on Android 13+ if the notification should be dismissible.
* Sensitive tunnel material never lands in plain `SharedPreferences`. The Dart layer keeps the WireGuard private key in `flutter_secure_storage` and only serialises a `SessionMeta` (server id/name, ISO country code, monotonic start/duration) for restore. The Kotlin side mirrors that metadata in memory for notification telemetry.
* The WireGuard tunnel dependency (`com.wireguard.android:tunnel:1.0.20230706`) is declared in `android/app/build.gradle.kts`. The current service is a façade; integrate the backend on the Kotlin side when ready.

### iOS status

iOS is deferred for this MVP. The Flutter layer relies on an abstract `VpnPort` so an iOS-specific implementation (likely using `WireGuardKit` in a Packet Tunnel extension) can plug in later without UI changes. Document required Network Extension entitlements before starting that work.

## Rewarded session flow

1. On first launch the app loads `assets/servers.json` to populate the server catalogue.
2. Users tap **Connect**, triggering a rewarded ad via `RewardedAdService`. A successful reward unlocks a 60-minute session.
3. The session controller stores a lightweight `SessionMeta` (server id/name, country code, monotonic start/duration) in SharedPreferences and the WireGuard private key in secure storage; full configs never leave memory.
4. A persistent countdown updates from the platform monotonic clock; if the app is backgrounded or relaunched, the countdown restores from persisted state without wall-clock drift.
5. After 60 minutes the controller disconnects and prompts the user to watch another ad.

Manual disconnects stop the tunnel immediately; remaining time is discarded.

### Advanced connection controls

* **Protocol selection** – the Settings tab exposes WireGuard plus placeholders for OpenVPN and IKEv2. Unsupported protocols are surfaced as disabled options so the UI stays future proof.
* **DNS, MTU, and keepalive tuning** – sliders and chips let power users swap between Cloudflare, Google, or custom DNS pools and adjust WireGuard interface parameters.
* **Split tunneling** – enable app-based routing and pick which installed packages should traverse the tunnel. The selection persists via secure storage and is surfaced to the Android service for enforcement.
* **Auto-connect rules** – toggles for launch, boot, and network-change reconnection feed the native receivers so the service comes back up after restarts or network flips.

## Server favourites & latency

HiVPN now keeps a searchable carousel of servers with latency probes (simple TCP connects) and favourite starring. The picker bottom sheet separates favourites from the full list and disables server switching while connected.

## Guided spotlight tour

The first launch shows a four-step overlay (server carousel, connect control, status pill, Speed Test tab). It uses `tutorial_coach_mark` and only runs once per install (`tour_done` preference). A hidden developer utility can reset the flag by clearing app storage.

## Speed Test

The second tab runs latency, download, and upload checks using the endpoints defined in `assets/speedtest_endpoints.json`. `SpeedTestService` streams rolling throughput samples every 500 ms and surfaces the smoothed five-sample average in the gauge UI. Results persist locally so users see their last run immediately after relaunching. Update the endpoint list or IP resolver URL as needed for your infrastructure.

## Foreground notification & quick tile

The Android foreground service posts updates on channel `hivpn.tunnel` with a live countdown sourced from `SystemClock.elapsedRealtime()`, the server’s flag/country, current IP, and actions to disconnect immediately or jump back into Flutter to watch an “extend” rewarded ad (which adds 60 minutes without re-dialling). While the screen is interactive the notification refreshes every second; when idle it throttles to ~15 s cadence. Capture a device screenshot of the notification on your QA build and place it under `assets/reference/` for release documentation.

Android 7.0+ devices also get a Quick Settings tile (`HiVPN`) that mirrors the session state and can toggle the tunnel. The tile reuses the persisted WireGuard JSON so auto-connect rules (boot/network change) stay honoured even when the Flutter layer is cold.

## Connection history

The History tab records every completed session with start/end timestamps, duration, and approximated throughput stats from the native service. A summary card aggregates total time online and combined traffic for the current install.

## Assets and branding

* Dark theme based on the HiVPN palette:
  * Primary `#4C5BD7`, Accent `#A78BFA`, Background `#0E1220`, Surface `#131A2A`
  * Status accents: Connected `#22C55E`, Warning `#F59E0B`, Error `#EF4444`, Info `#38BDF8`
* Typography: system default/Inter with large tap targets (≥48dp) and 4.5:1 contrast.
* Reference imagery lives under `assets/reference/` for visual QA; it is not loaded by the app.

## Legal quick note

The in-app legal dialog reminds users that VPN usage can be regulated. Update the copy to fit your region and consult counsel before shipping.

## FAQ

**How do I enable WireGuard on Android?**  
Complete the Kotlin service by applying the `GoBackend` API from the WireGuard tunnel library and feed the JSON configuration produced in Dart. Ensure you request VPN permission via `VpnService.prepare` (already exposed on the method channel).

**Can I test rewarded ads without production inventory?**  
Yes. The project uses Google’s official test ad unit IDs, so you can exercise the flow without risking policy violations. Swap to production IDs when you are ready to submit.

**Where is the private key stored?**
The controller persists the generated private key via `flutter_secure_storage` under the key `wg_private_key`. Clearing app data regenerates a new keypair on the next connection.

**How do I reset favourites or history?**
Visit **Settings → Privacy** and tap the respective clear buttons. Favourites update immediately in the carousel and history wipes the timeline plus cached stats.

**How do I reset the onboarding spotlight?**
Clear the `tour_done` flag from `SharedPreferences` (via Android settings “Clear storage” or by adding a debug hook). The tour will run again on the next launch.
