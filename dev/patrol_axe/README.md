# patrol_axe

Optional Patrol extension package for [Deque axe DevTools](https://www.deque.com/axe/devtools/) accessibility scanning.

Core Patrol provides a generic extension hook; this package owns the schema, Dart API (`$.axe`), native routes, and Deque SDK dependencies.

## API

```dart
import 'package:patrol_axe/patrol_axe.dart';

await $.axe.initSession(dequeApiKey: '...', dequeProjectId: '...');
await $.axe.scan(scanName: 'checkout-flow', tags: {'smoke'});
await $.axe.ignoreRules(['rule-id']);
await $.axe.ignoreByViewIdResourceName('com.example:id/toolbar', ['rule-id']);
await $.axe.ignoreExperimental();
```

Pass credentials via `--dart-define` in tests:

```bash
patrol test --target patrol_test/my_axe_test.dart \
  --dart-define=DEQUE_API_KEY=... \
  --dart-define=DEQUE_PROJECT_ID=...
```

## Requirements

- **Android minSdk 26** (required by `axe-devtools-android:8.1.0`)
- Deque axe DevTools API key and project ID
- Patrol with the generic extension hook (`PatrolServerExtension` + `patrolNativeServerUri`)

## How a user adds it

See **[SETUP.md](SETUP.md)** for full instructions (external apps, local clone, Android/iOS wiring, and why the CocoaPods post-install hook is required).

### Dart

```yaml
dev_dependencies:
  patrol_axe:
    path: ../patrol_axe
```

### Android

```kotlin
// app/build.gradle.kts
dependencies {
  androidTestImplementation(project(":patrol_axe"))
}
```

Ensure `minSdk >= 26` in your app.

### iOS (CocoaPods)

Add to your `Podfile` `post_install` hook:

```ruby
require_relative '../patrol_axe/darwin/patrol_axe_post_install'

post_install do |installer|
  flutter_additional_ios_build_settings(installer)
  patrol_axe_post_install(installer)
end
```

This weak-links `axeDevToolsXCUI` in the app target and keeps it embedded only in `RunnerUITests` (required because the SDK depends on `XCUIAutomation`).

With standard Patrol iOS setup (`RunnerUITests` + `inherit! :complete` or `FlutterGeneratedPluginSwiftPackage`), the plugin is picked up automatically.

## Package layout

```
schema/axe.dart
lib/                          # $.axe Dart API + HTTP client
android/                      # AxeServerExtension + Deque Android SDK
darwin/
  axe-devtools-ios/           # vendored axeDevToolsXCUI.xcframework
  patrol_axe/                 # Swift extension + AxeBridge
  patrol_axe.podspec
  patrol_axe_post_install.rb
```

## Runtime flow

```
$.axe.scan()
  → POST localhost:8081/axeScan
    → AxeServerExtension (discovered via PatrolServerExtension hook)
      → AxeAutomator → Deque axe DevTools SDK
```

## Mental model

1. Extension registers native route handlers on Patrol's `:8081` server (SPI on Android, ObjC runtime on iOS)
2. Handlers call the Deque SDK
3. Dart talks to those routes via `patrolNativeServerUri` — same server as `$.platform.mobile.*`
4. Core Patrol has no axe-specific code
