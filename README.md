<p align="center">
  <img src="screenshots/appicon.png" alt="hiVPN Logo" width="120"/>
</p>

<h1 align="center">
  <span style="color: #0E1116;">hi</span><span style="color: #2E7CF6;">VPN</span><span style="color: #FF3B30; font-size: 0.5em; vertical-align: super;">•</span>
</h1>

<p align="center">
  <a href="https://github.com/Mr-Dark-debug/hivpn/releases/latest">
    <img src="https://img.shields.io/github/v/release/Mr-Dark-debug/hivpn?style=for-the-badge&color=2E7CF6" alt="GitHub release">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge" alt="License: MIT">
  </a>
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Flutter-3.13.0-2E7CF6?style=for-the-badge&logo=flutter" alt="Flutter">
  </a>
</p>

<p align="center">
  Secure, community-powered VPN for Android today, with iOS support on the roadmap. hiVPN provides fast and reliable connections with a focus on privacy and ease of use.
</p>

<p align="center">
  <a href="https://github.com/Mr-Dark-debug/hivpn/releases/latest">
    <img src="https://img.shields.io/badge/Download-Latest_Release-2E7CF6?style=for-the-badge&logo=github" alt="Download Latest Release">
  </a>
</p>

## 🌟 Key Features

- 🚀 One-tap connection to fastest available server
- 🌍 1000+ servers in 30+ countries
- 🔒 Strong encryption for maximum security
- 📊 Built-in speed testing
- 📈 Connection history and statistics
- 🎯 Smart server selection
- 🌙 Dark/Light theme support
- 🛡️ No-logs policy
- 🆓 Free to use with premium features

## 📱 Screenshots

### Onboarding
| Step 1 | Step 2 | Step 3 |
|--------|--------|--------|
| ![Onboarding 1](screenshots/ob1.png) | ![Onboarding 2](screenshots/ob2.png) | ![Onboarding 3](screenshots/ob3.png) |

### Main App
| Splash Screen | Home Screen | Server Selection |
|--------------|-------------|-----------------|
| ![Splash](screenshots/splash_screen.png) | ![Home](screenshots/homepage.png) | ![Servers](screenshots/serverlist.png) |

| Speed Test | Settings | Connection Info |
|------------|----------|-----------------|
| ![Speed Test](screenshots/speedtest.png) | ![Settings](screenshots/settings.png) | ![More Info](screenshots/moreinfo.png) |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.13.0)
- Android Studio / Xcode (for mobile development)
- Google Mobile Ads account (for ad integration)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mr-Dark-debug/hivpn.git
   cd hivpn
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🛠️ Project Structure

```
lib/
├── app/                 # App configuration and theme
├── core/                # Core utilities and constants
├── features/            # Feature modules
│   ├── connection/      # VPN connection management
│   ├── history/         # Connection history and stats
│   ├── network/         # Network utilities
│   ├── onboarding/      # User onboarding flow
│   ├── referral/        # Referral system
│   ├── servers/         # Server management
│   ├── session/         # Session management
│   └── settings/        # App settings
└── main.dart           # App entry point
```

## 1. Overview
hiVPN is an Android-first Flutter client that drives OpenVPN via the `openvpn_flutter` engine, discovers volunteer VPNGate servers, and offers built-in network diagnostics with `flutter_speed_test_plus`, all coordinated through Riverpod providers. <!-- evidence: lib/services/vpn/openvpn_port.dart:1-170 --> <!-- evidence: lib/features/servers/data/server_repository.dart:1-190 --> <!-- evidence: lib/services/speedtest/speedtest_service.dart:1-120 --> <!-- evidence: pubspec.yaml:1-60 -->

- **What this is:** an open-source reference app showing how to ship an Android VPN that respects modern platform requirements (VpnService, foreground + notifications) while leaning on community servers.
- **What this is not:** a zero-trust or audited security solution; commercial uptime, privacy guarantees, and enterprise tunneling policies are out of scope.

![hiVPN hero](docs/images/hero.png)

*iOS build targets are planned but not yet available; today the shipped binary supports Android devices only.*

## 2. Badges
![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white) ![minSdk](https://img.shields.io/badge/minSdk-26-3DDC84?logo=android&logoColor=white) ![targetSdk](https://img.shields.io/badge/targetSdk-36-3DDC84?logo=android&logoColor=white) ![Platform](https://img.shields.io/badge/platform-Android-blueviolet?logo=android&logoColor=white) ![License](https://img.shields.io/badge/license-TODO-lightgrey) ![CI](https://img.shields.io/badge/CI-TODO-lightgrey)

## 3. Table of Contents
- [Overview](#1-overview)
- [Badges](#2-badges)
- [Features](#4-features)
- [Screenshots](#5-screenshots)
- [Quick Start (Users)](#6-quick-start-users)
- [Build From Source](#7-build-from-source)
- [Configuration](#8-configuration)
- [Architecture](#9-architecture)
- [Permissions](#10-permissions)
- [Privacy & Security](#11-privacy--security)
- [Troubleshooting](#12-troubleshooting)
- [Contributing](#13-contributing)
- [Roadmap](#14-roadmap)
- [Release process](#15-release-process)
- [License](#16-license)
- [Acknowledgements](#17-acknowledgements)

## 🔌 Dependencies

- **State Management**: `flutter_riverpod`
- **VPN**: `openvpn_flutter`
- **Ads**: `google_mobile_ads`
- **Local Storage**: `shared_preferences`, `flutter_secure_storage`
- **Networking**: `dio`, `http`
- **UI**: `google_fonts`, `flutter_svg`
- **Analytics**: `firebase_analytics`
- **Localization**: `intl`

## 4. Features
- ✅ OpenVPN tunnel management with staged status updates through `openvpn_flutter`. <!-- evidence: lib/services/vpn/openvpn_port.dart:1-200 -->
- ✅ VPNGate server discovery, caching, and `.ovpn` import with validation for host/port/cipher. <!-- evidence: lib/features/servers/data/server_repository.dart:1-200 --> <!-- evidence: lib/features/onboarding/presentation/onboarding_flow.dart:500-620 -->
- ✅ Built-in speed test using `flutter_speed_test_plus`, Fast.com defaults, and ipify IP lookups. <!-- evidence: lib/services/speedtest/speedtest_service.dart:1-120 --> <!-- evidence: lib/features/speedtest/data/speedtest_repository.dart:1-80 -->
- ⚙️ Auto-connect rules (on launch/on network change) with Riverpod-backed settings. <!-- evidence: lib/features/settings/domain/auto_connect_rules.dart:1-120 --> <!-- evidence: lib/features/session/domain/session_controller.dart:500-620 -->
- ✅ Foreground session notifications with disconnect/extend actions plus Quick Settings tile refresh. <!-- evidence: lib/services/notifications/session_notification_service.dart:1-200 --> <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/vpn/HiVpnTileService.kt:1-80 -->
- ✅ Shortcut to Android’s Always-on VPN settings from onboarding. <!-- evidence: lib/features/onboarding/presentation/onboarding_flow.dart:500-540 -->
- 🚧 Split tunnel selections persisted but not yet enforced by the OpenVPN layer. <!-- evidence: lib/features/settings/domain/split_tunnel_config.dart:1-120 -->
- 🚧 Dark mode theming still to come (current palette is light-only). <!-- evidence: lib/theme/theme.dart:1-160 -->

### What’s working / What’s not (yet)

| Working today | Not yet / planned |
| --- | --- |
| OpenVPN tunnel lifecycle, notification actions, connection timeout handling. <!-- evidence: lib/features/session/domain/session_controller.dart:1-200 --> | Auto-reconnect on boot/network change receivers are placeholders that currently log only. <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/vpn/AutoConnectReceivers.kt:1-120 --> |
| VPNGate catalogue fetch with SharedPreferences cache fallback. <!-- evidence: lib/features/servers/data/server_repository.dart:1-150 --> | Enforcing split tunnel packages inside the OpenVPN engine. |
| Speed test telemetry stored locally for quick resume. <!-- evidence: lib/features/speedtest/domain/speedtest_controller.dart:1-320 --> | Continuous integration / automated release pipeline. |
| Connection history and data usage tracking persisted in SharedPreferences. <!-- evidence: lib/features/history/data/connection_history_repository.dart:1-80 --> | Dark mode, tablet layout polishing. |

## 5. Screenshots
| Home | Server list |
| --- | --- |
| ![Home screen](docs/images/home.png) <br/>Dashboard & session controls | ![Server list](docs/images/server-list.png) <br/>VPNGate catalogue with filters |

| Speed test | Settings |
| --- | --- |
| ![Speed test](docs/images/speedtest.png) <br/>Live bandwidth graph | ![Settings](docs/images/settings.png) <br/>Auto-connect & personalization |

<!-- Maintainers: keep screenshots ≤1600px wide and provide @2x variants where appropriate. -->

| # | Path | Description |
| - | - | - |
| 1 | `docs/images/home.png` | Main session dashboard |
| 2 | `docs/images/server-list.png` | VPNGate server browser |
| 3 | `docs/images/speedtest.png` | Speed test results view |
| 4 | `docs/images/settings.png` | Settings and personalization |

## 6. Quick Start (Users)
### Download
- Grab the latest Android APK from [GitHub Releases](https://github.com/OWNER/hivpn/releases); no Play Store listing is available yet.
- iOS builds are planned but not yet published.

### Install on Android
1. Transfer the APK to your device.
2. Enable *Install unknown apps* for your file manager/browser.
3. Open the APK and follow the prompts.

### First run
- Accept the Android VPN permission prompt triggered by the `VpnService.prepare` flow. <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/MainActivity.kt:1-120 -->
- Optionally grant notification access so ongoing session status can be shown. <!-- evidence: android/app/src/main/AndroidManifest.xml:1-80 --> <!-- evidence: lib/services/notifications/session_notification_service.dart:1-200 -->

### Connect
- **Auto server:** Use the quick connect button; the app uses the last selected VPNGate entry.
- **Browse VPNGate:** Open the server picker, filter by country or latency, then connect. <!-- evidence: lib/features/servers/data/server_repository.dart:1-200 -->
- **Import `.ovpn`:** From onboarding or settings, choose “Import .ovpn,” pick a file, and the app validates host/port directives before adding it. <!-- evidence: lib/features/onboarding/presentation/onboarding_flow.dart:540-620 -->

### Speed test
- Run the in-app test to measure download/upload (Fast.com defaults) and fetch your public IP via ipify; remember the test endpoint will see your real IP at that moment. <!-- evidence: lib/features/speedtest/data/speedtest_repository.dart:1-80 --> <!-- evidence: lib/services/speedtest/speedtest_service.dart:1-120 -->

### Known limitations
- VPNGate servers are volunteer-operated; speed and availability vary widely.
- Auto-reconnect on boot/network change is not yet wired through to the tunnel engine.
- Dark theme and tablet UX are in progress.
- iOS support is under development.

## 7. Build From Source
### Prerequisites
- Flutter stable channel (SDK constraint `>=3.3.0 <4.0.0`). <!-- evidence: pubspec.yaml:1-20 -->
- Android Studio or CLI tools with compile SDK 36, minSdk 26, targetSdk 36, and NDK 27.0.12077973. <!-- evidence: android/app/build.gradle.kts:1-80 -->
- Java 17 toolchain (`sourceCompatibility`/`targetCompatibility` & Kotlin JVM target). <!-- evidence: android/app/build.gradle.kts:8-40 -->
- Kotlin 1.9.22 and Android Gradle Plugin 8.1.4. <!-- evidence: android/build.gradle.kts:1-80 -->
- Gradle wrapper 8.10.2 (managed via the repo). <!-- evidence: android/gradle/wrapper/gradle-wrapper.properties:1-10 -->

### Commands
```bash
flutter --version         # confirm toolchain
flutter pub get
flutter test
flutter build apk --debug
flutter build apk --release
```

### Android identifiers
- Application ID: `com.example.hivpn`. <!-- evidence: android/app/build.gradle.kts:8-40 -->
- Min SDK: 26; Target SDK: 36; Compile SDK: 36. <!-- evidence: android/app/build.gradle.kts:8-40 -->
- Foreground service + special-use permissions declared for long-lived VPN sessions. <!-- evidence: android/app/src/main/AndroidManifest.xml:1-80 -->

No extra Gradle properties or environment variables are required beyond the defaults in `android/gradle.properties`. <!-- evidence: android/gradle.properties:1-40 -->

## 8. Configuration
- **Server catalogue:** Pulled from multiple VPNGate endpoints, decoded from CSV, and cached in `SharedPreferences` for offline fallback. <!-- evidence: lib/features/servers/data/server_repository.dart:1-200 -->
- **User preferences:** Stored via a Riverpod-backed `PrefsStore` wrapper around `SharedPreferences`. <!-- evidence: lib/services/storage/prefs.dart:1-80 -->
- **Secure secrets:** Anything sensitive can be persisted through `SecureStore` (`flutter_secure_storage`). <!-- evidence: lib/services/storage/secure_store.dart:1-40 -->
- **Speed test:** Config defaults (Fast.com & ipify) plus last results persisted in preferences for quick rehydration. <!-- evidence: lib/features/speedtest/domain/speedtest_controller.dart:1-320 -->
- **`.ovpn` import:** File picker enforces extension, validates `remote` directive, and stores sanitized config for later use. <!-- evidence: lib/features/onboarding/presentation/onboarding_flow.dart:540-620 -->
- **Auto-connect:** `AutoConnectRules` toggles (launch, boot, network change) saved for future tunnel automation. <!-- evidence: lib/features/settings/domain/auto_connect_rules.dart:1-120 -->
- **Build-time flags:** None at present; consider `--dart-define` for future secrets/toggles.

## 9. Architecture
```mermaid
graph TD
  UI[Flutter UI<br/>Riverpod providers] -->|MethodChannel + plugins| AndroidVpn[Android layer<br/>VpnService + OpenVPN engine]
  AndroidVpn --> Tunnel[OpenVPN tunnel<br/>Community VPNGate server]
  UI --> SpeedTest[Speed test module<br/>FlutterInternetSpeedTest + Dio]
  SpeedTest --> Diagnostics[Fast.com / ipify endpoints]
```

- `lib/features/*` contains feature slices (servers, session, speedtest, onboarding).
- `lib/services/*` houses platform abstractions (VPN port, notifications, storage).
- `lib/platform/android` bridges method channel intents such as Quick Settings tile updates. <!-- evidence: lib/platform/android/extend_intent_handler.dart:1-120 -->
- `android/app/src/main/kotlin` covers `MainActivity` and receivers/services required for Android integration. <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/MainActivity.kt:1-160 --> <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/vpn/HiVpnTileService.kt:1-80 -->

## 10. Permissions
- `android.permission.ACCESS_NETWORK_STATE` — detect connectivity before/after tunnels. <!-- evidence: android/app/src/main/AndroidManifest.xml:1-20 -->
- `android.permission.INTERNET` — tunnel establishment and API calls. <!-- evidence: android/app/src/main/AndroidManifest.xml:1-20 -->
- `android.permission.FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_SPECIAL_USE` — comply with Android 14+ VPN foreground requirements. <!-- evidence: android/app/src/main/AndroidManifest.xml:1-20 -->
- `android.permission.ACCESS_WIFI_STATE` / `CHANGE_NETWORK_STATE` — server recommendations and potential split-tunnel prep. <!-- evidence: android/app/src/main/AndroidManifest.xml:1-20 -->
- `android.permission.POST_NOTIFICATIONS` — show session state + action buttons. <!-- evidence: android/app/src/main/AndroidManifest.xml:1-40 --> <!-- evidence: lib/services/notifications/session_notification_service.dart:1-200 -->
- `android.permission.RECEIVE_BOOT_COMPLETED` — placeholder receiver for future auto-reconnect. <!-- evidence: android/app/src/main/AndroidManifest.xml:1-80 --> <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/vpn/AutoConnectReceivers.kt:1-120 -->
- `android.permission.BIND_QUICK_SETTINGS_TILE` — Quick Settings tile integration. <!-- evidence: android/app/src/main/AndroidManifest.xml:40-80 -->

## 11. Privacy & Security
- **Local storage:** Connection history, speed test results, and settings are persisted in `SharedPreferences`; secure values can flow through `SecureStore`. <!-- evidence: lib/features/history/data/connection_history_repository.dart:1-80 --> <!-- evidence: lib/services/storage/prefs.dart:1-80 --> <!-- evidence: lib/services/storage/secure_store.dart:1-40 -->
- **In-flight data:** OpenVPN configs (username/password `vpn`) are used to connect to VPNGate nodes; traffic is relayed through whichever volunteer server you pick. <!-- evidence: lib/services/vpn/openvpn_port.dart:1-200 -->
- **VPNGate disclosure:** Servers are community-run, so operators may log metadata; use only if you trust the endpoint. <!-- evidence: lib/features/servers/data/vpngate_api.dart:1-160 -->
- **Speed test telemetry:** Downloads/uploads run against Fast.com endpoints and IP lookups call api64.ipify.org. <!-- evidence: lib/features/speedtest/data/speedtest_repository.dart:1-80 -->
- **Analytics/telemetry:** No third-party analytics; the `AnalyticsService` only logs to console in debug builds. <!-- evidence: lib/services/analytics/analytics_service.dart:1-60 -->
- **Ads:** A Google AdMob test ID is bundled for extension prompts; swap with your own before production. <!-- evidence: android/app/src/main/AndroidManifest.xml:20-80 -->

## 12. Troubleshooting
- **VPN permission denied:** Re-launch; Android will re-prompt `VpnService.prepare`. Settings → Network & Internet → VPN to grant manually. <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/MainActivity.kt:1-160 -->
- **Connect loop or timeouts:** Try another VPNGate node; connection attempts auto-cancel after 45 seconds. <!-- evidence: lib/features/session/domain/session_controller.dart:1-120 -->
- **Background session stopped:** Ensure notifications are enabled and battery optimizations are relaxed for hiVPN.
- **Speed test stuck:** Network filters/firewalls can block Fast.com; rerun later or disable split tunnel (if enabled). <!-- evidence: lib/features/speedtest/domain/speedtest_controller.dart:1-240 -->
- **Quick Settings tile stale:** Open the app to trigger `updateQuickTile`. <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/MainActivity.kt:1-120 -->

## 13. Contributing
1. Fork and clone the repository.
2. Create a feature branch using Conventional Commit prefixes (e.g., `feat/`, `fix/`).
3. Run `flutter pub get`, `flutter analyze`, and `flutter test` before submitting.
4. Format Dart with `flutter format .` and Kotlin/Gradle via Android Studio or `ktlint` (optional).
5. Open a pull request describing your change and include screenshots if UI is affected.

Use Riverpod providers for state, keep business logic inside `lib/features/*` slices, and follow the Material 3 design tokens in `lib/theme`. <!-- evidence: lib/app/app.dart:1-80 --> <!-- evidence: lib/theme/theme.dart:1-160 -->

## 14. Roadmap
- [ ] Wire auto-reconnect receivers into the VPN port for boot/network recovery. <!-- evidence: android/app/src/main/kotlin/com/example/hivpn/vpn/AutoConnectReceivers.kt:1-120 -->
- [ ] Enforce split tunnel selections within OpenVPN config generation. <!-- evidence: lib/features/settings/domain/split_tunnel_config.dart:1-120 -->
- [ ] Add dark theme variants and dynamic color support. <!-- evidence: lib/theme/theme.dart:1-160 -->
- [ ] Stand up CI (GitHub Actions) for analysis, tests, and release artifacts.
- [ ] Replace AdMob test ID with production credentials and privacy strings.
- [ ] Publish iOS build alongside Android APKs.

## 15. Release process
1. Bump `version` in `pubspec.yaml`.
2. Update changelog (TODO).
3. Run the build commands above for release APK/AAB.
4. Sign artifacts (replace debug signingConfig) and upload to GitHub Releases (APK distribution) / Play Console when ready.
5. TODO: Automate via CI once workflows are added.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## 📄 Privacy Policy

Please read our [Privacy Policy](PRIVACY.md) to understand how we handle your data.

## 📬 Contact

For feature requests and support, please open an issue on GitHub.

## 📱 Download

[![Download on the App Store](https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://apps.apple.com/app/hivpn/idYOUR_APP_ID)
[![Get it on Google Play](https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png)](https://play.google.com/store/apps/details?id=com.mrdark.hivpn)

Or download the latest APK from our [GitHub Releases](https://github.com/Mr-Dark-debug/hivpn/releases) page.

---

Made with ❤️ by hiVPN Team
## 📄 License

This project is licensed under the [Apache License 2.0](LICENSE).

## 17. Acknowledgements
- [VPNGate Project](https://www.vpngate.net/) for the public VPN catalogue.
- [`openvpn_flutter`](https://pub.dev/packages/openvpn_flutter) for embedding the OpenVPN engine. <!-- evidence: lib/services/vpn/openvpn_port.dart:1-200 -->
- [`flutter_speed_test_plus`](https://pub.dev/packages/flutter_speed_test_plus) for easy network diagnostics. <!-- evidence: lib/services/speedtest/speedtest_service.dart:1-120 -->
- [Riverpod](https://riverpod.dev/) for reactive state management. <!-- evidence: pubspec.yaml:1-40 -->
- [Shared Preferences](https://pub.dev/packages/shared_preferences) & [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) for lightweight persistence. <!-- evidence: lib/services/storage/prefs.dart:1-80 --> <!-- evidence: lib/services/storage/secure_store.dart:1-40 -->
