# Setting up `patrol_axe` in your app

This guide covers wiring `patrol_axe` into a **Flutter app outside the patrol repo**, using a **local clone** of the patrol branch that includes:

- the generic extension hook in core `patrol` (`PatrolServerExtension`, `patrolNativeServerUri`)
- the `dev/patrol_axe` package

## Prerequisites

- Standard [Patrol install](https://patrol.leancode.co/documentation) already done in your app (`PatrolJUnitRunner` on Android, `RunnerUITests` on iOS, `patrol` section in `pubspec.yaml`).
- Deque axe DevTools API key and project ID.
- **Android minSdk ≥ 26** (required by `axe-devtools-android:8.1.0`).

## Example layout

```
repos/
  patrol/          # local clone of the patrol branch
  my_app/          # your Flutter app
```

Paths below assume `my_app` sits next to `patrol`. Adjust `../patrol/...` if your layout differs.

---

## 1. `pubspec.yaml`

Use **path dependencies** so you pick up the branch with the extension hook (not pub.dev `patrol` alone, unless a published version includes it).

```yaml
dev_dependencies:
  patrol:
    path: ../patrol/packages/patrol
  patrol_cli: ^<compatible version>   # see patrol compatibility table
  patrol_axe:
    path: ../patrol/dev/patrol_axe

patrol:
  app_name: My App
  android:
    package_name: com.example.myapp
  ios:
    bundle_id: com.example.MyApp
```

Then:

```bash
flutter pub get
```

---

## 2. Android

### minSdk

```kotlin
// android/app/build.gradle.kts
defaultConfig {
    minSdk = 26
    testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
    testInstrumentationRunnerArguments["clearPackageData"] = "true"
}
```

### Instrumentation classpath

`PatrolServer` runs in the **androidTest / instrumentation** process. `patrol_axe` must be on that classpath:

```kotlin
// android/app/build.gradle.kts
dependencies {
    androidTestImplementation(project(":patrol_axe"))
}
```

### `settings.gradle.kts` (if Gradle can't resolve `:patrol_axe`)

Flutter's plugin loader usually registers plugins from `pubspec.yaml`. If `:patrol_axe` is not found, add (paths relative to `my_app/android/`):

```kotlin
include(":patrol_axe")
project(":patrol_axe").projectDir = file("../patrol/dev/patrol_axe/android")
```

---

## 3. iOS

### Standard Patrol iOS setup

You still need the normal Patrol UITest target:

- **CocoaPods:** nested `RunnerUITests` with `inherit! :complete` in `Podfile`
- **SPM:** `FlutterGeneratedPluginSwiftPackage` linked to **RunnerUITests** in Xcode

With that in place, `patrol_axe` is picked up as a Flutter plugin like other iOS plugins.

### CocoaPods: `patrol_axe_post_install` (required)

Add to `ios/Podfile` (after `flutter pub get`, which creates the plugin symlink):

```ruby
def load_patrol_axe_post_install
  path = File.expand_path(
    '.symlinks/plugins/patrol_axe/darwin/patrol_axe_post_install.rb',
    __dir__,
  )
  unless File.exist?(path)
    Pod::UI.warn "patrol_axe: post_install hook not found. Run `flutter pub get` first."
    return
  end
  require path
end

load_patrol_axe_post_install

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
  patrol_axe_post_install(installer) if defined?(patrol_axe_post_install)
end
```

This resolves the hook from Flutter's plugin symlink (`.symlinks/plugins/patrol_axe/...`), so it works with `path:`, `git:`, or pub.dev dependencies — no hardcoded path to a local patrol clone.

Then:

```bash
cd ios && pod install
```

#### Why is `patrol_axe_post_install` necessary?

`axeDevToolsXCUI` links against `XCUIAutomation.framework`, which exists only in the **XCUITest runner** process — not in a normal app.

With default Flutter + CocoaPods wiring:

1. `patrol_axe` is added to the **Runner** target via `flutter_install_all_ios_pods`.
2. `RunnerUITests` also gets it (`inherit! :complete`).
3. CocoaPods cannot scope a vendored xcframework to UITests only.

Without the post-install hook, `axeDevToolsXCUI` can be **embedded in the app bundle**. At launch, dyld may crash with:

```
Library not loaded: @rpath/XCUIAutomation.framework/XCUIAutomation
Referenced from: .../Runner.app/Frameworks/axeDevToolsXCUI.framework/...
```

`patrol_axe_post_install` fixes this by:

| Action | Target |
|--------|--------|
| Remove axe from embed/copy scripts | Runner (app) |
| Weak-link `axeDevToolsXCUI` | Runner (app) |
| Leave axe linked and embedded | `RunnerUITests` only |

`weak_frameworks` in the podspec alone is usually **not** enough — embed scripts may still copy the framework into `Runner.app`.

#### When can you skip it?

Only if you **do not** use the default Flutter plugin wiring on Runner — e.g. you manually link `patrol_axe` **only** to `RunnerUITests` and never embed the Deque xcframework in the app. That is more manual and fights Flutter's defaults.

**Android has no equivalent** — this problem is iOS-specific.

---

## 4. Write a test

```dart
// patrol_test/axe_test.dart
import 'package:patrol/patrol.dart';
import 'package:patrol_axe/patrol_axe.dart';

void main() {
  patrol('axe smoke', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    const apiKey = String.fromEnvironment('DEQUE_API_KEY');
    const projectId = String.fromEnvironment('DEQUE_PROJECT_ID');
    if (apiKey.isEmpty || projectId.isEmpty) {
      $.log('Set DEQUE_API_KEY and DEQUE_PROJECT_ID via --dart-define to run axe.');
      return;
    }

    await $.axe.initSession(dequeApiKey: apiKey, dequeProjectId: projectId);
    await $.axe.scan(scanName: 'smoke', uploadToDashboard: false);
  });
}
```

Run:

```bash
patrol test --target patrol_test/axe_test.dart \
  --dart-define=DEQUE_API_KEY=... \
  --dart-define=DEQUE_PROJECT_ID=...
```

---

## Checklist

| Step | Android | iOS |
|------|---------|-----|
| `patrol` from branch with extension hook | ✅ path dep | ✅ path dep |
| `patrol_axe` path dep | ✅ | ✅ |
| minSdk ≥ 26 | ✅ | — |
| `androidTestImplementation(project(":patrol_axe"))` | ✅ | — |
| `patrol_axe_post_install` in Podfile | — | ✅ (CocoaPods) |
| `PATROL_ENABLED` (via `patrol_axe` podspec / `Package.swift`) | — | ✅ automatic |
| Patrol UITest target configured | — | ✅ |
| `import patrol_axe` → `$.axe` in tests | ✅ | ✅ |

---

## Troubleshooting

**Android: extension routes not found / connection refused**

- Confirm `androidTestImplementation(project(":patrol_axe"))` is present.
- Logcat should show: `Loaded Patrol server extension: patrol_axe`.

**iOS: app crashes on launch**

- Missing `patrol_axe_post_install` — add it and run `pod install`.

**iOS: axe not discovered in UITests**

- Confirm `RunnerUITests` links plugins (`inherit! :complete` or `FlutterGeneratedPluginSwiftPackage`).
- `PATROL_ENABLED` is set by `patrol_axe` itself (podspec / `Package.swift`) — no Podfile flag needed.
