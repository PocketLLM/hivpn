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
    onboarding/       # Spotlight tour (tutorial_coach_mark)
    servers/          # Server models and asset repository
    session/          # Session domain, countdown, controller
  widgets/            # Shared UI components
assets/
  servers.json        # Static server catalogue
  reference/          # Visual reference material from design
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

* The app includes a foreground `VpnService` shell (`WireGuardService`) that exposes a `MethodChannel` (`com.example.vpn/VpnChannel`). The native layer currently starts a persistent notification and is the place to finish the WireGuard backend wiring.
* Rewarded ads use Google test identifiers (`ca-app-pub-3940256099942544/5224354917`). Replace with production IDs before release.
* Update `android/app/src/main/AndroidManifest.xml` with your final AdMob app ID and consider requesting the `POST_NOTIFICATIONS` runtime permission on Android 13+ if the notification should be dismissible.
* The WireGuard tunnel dependency (`com.wireguard.android:tunnel:1.0.20230706`) is declared in `android/app/build.gradle.kts`. The current service is a façade; integrate the backend on the Kotlin side when ready.

### iOS status

iOS is deferred for this MVP. The Flutter layer relies on an abstract `VpnPort` so an iOS-specific implementation (likely using `WireGuardKit` in a Packet Tunnel extension) can plug in later without UI changes. Document required Network Extension entitlements before starting that work.

## Rewarded session flow

1. On first launch the app loads `assets/servers.json` to populate the server catalogue.
2. Users tap **Connect**, triggering a rewarded ad via `RewardedAdService`. A successful reward unlocks a 60-minute session.
3. The session controller stores the tunnel metadata (`start`, `duration`, `serverId`) in SharedPreferences and the WireGuard private key in secure storage.
4. A persistent countdown updates from monotonic wall-clock math; if the app is backgrounded or relaunched, the countdown restores from persisted state.
5. After 60 minutes the controller disconnects and prompts the user to watch another ad.

Manual disconnects stop the tunnel immediately; remaining time is discarded.

## Guided spotlight tour

The first launch shows a four-step overlay (servers, connect button, status pill, persistent notification reminder). It uses `tutorial_coach_mark` and only runs once per install (`tour_done` preference). A hidden developer utility can reset the flag by clearing app storage.

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

**How do I reset the onboarding spotlight?**  
Clear the `tour_done` flag from `SharedPreferences` (via Android settings “Clear storage” or by adding a debug hook). The tour will run again on the next launch.
