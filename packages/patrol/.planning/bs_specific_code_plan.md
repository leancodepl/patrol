# Gate BrowserStack-Specific Initialization Behind a CLI Flag

## Context

`SwiftPatrolPlugin.register()` unconditionally calls `CameraViewfinderInjector.shared.installSwizzles()`, which swizzles `AVCaptureSession.startRunning()` to track camera sessions. This swizzle runs for **all** users of the patrol package -- even on local devices, simulators, and Firebase Test Lab where BrowserStack camera injection is irrelevant. We need a `--browserstack` CLI flag that users opt into, so these side-effects only occur when explicitly requested.

## Approach

Use the existing dart-define mechanism: patrol CLI `--browserstack` flag adds `--dart-define PATROL_BROWSERSTACK=true` to the Flutter build. On the Dart side, this constant is read at compile time. During iOS `configure()`, if the flag is set, a method channel call installs the swizzles on the Swift side. Without the flag, no swizzles are installed.

## Changes

### 1. Patrol CLI: Add `--browserstack` flag

**`packages/patrol_cli/lib/src/runner/patrol_command.dart`** -- add flag in `usesIOSOptions()`:
```dart
..addFlag(
  'browserstack',
  help: 'Enable BrowserStack-specific features like camera image injection.',
  negatable: false,
)
```

**`packages/patrol_cli/lib/src/commands/test.dart`** -- add to `internalDartDefines` (around line 218):
```dart
if (boolArg('browserstack')) 'PATROL_BROWSERSTACK': 'true',
```

**`packages/patrol_cli/lib/src/commands/build_ios.dart`** -- same pattern, read the flag and add the dart-define.

### 2. Patrol package Dart: Read flag and call method channel

**`packages/patrol/lib/src/constants.dart`** -- add constant:
```dart
const browserStackEnabled = bool.fromEnvironment('PATROL_BROWSERSTACK');
```

**`packages/patrol/lib/src/platform/ios/ios_automator_native.dart`** -- override `configure()` to install swizzles when flag is set:
```dart
@override
Future<void> configure() async {
  await super.configure();
  if (constants.browserStackEnabled) {
    const channel = MethodChannel('pl.leancode.patrol/main');
    await channel.invokeMethod('enableBrowserStackFeatures');
  }
}
```

This uses the same method channel (`pl.leancode.patrol/main`) already used by `feedInjectedImageToViewfinder` in this file.

### 3. Patrol package Swift: Gate swizzle behind method channel call

**`packages/patrol/darwin/Classes/SwiftPatrolPlugin.swift`**:
- **Remove** `CameraViewfinderInjector.shared.installSwizzles()` from `register(with:)`
- **Add** `"enableBrowserStackFeatures"` case in `handle(_:result:)`:
```swift
case "enableBrowserStackFeatures":
  CameraViewfinderInjector.shared.installSwizzles()
  result(nil)
```

No changes needed to `CameraViewfinderInjector.swift` itself.

### 4. Update CLI tests

**`packages/patrol_cli/test/crossplatform/app_options_test.dart`** and **`packages/patrol_cli/test/commands/build_ios_command_test.dart`** -- update any test expectations for `IOSAppOptions` or dart-defines if they verify the exact set of options.

## Files Summary

| File | Action |
|------|--------|
| `packages/patrol_cli/lib/src/runner/patrol_command.dart` | Add `--browserstack` flag |
| `packages/patrol_cli/lib/src/commands/test.dart` | Add dart-define when flag set |
| `packages/patrol_cli/lib/src/commands/build_ios.dart` | Add dart-define when flag set |
| `packages/patrol/lib/src/constants.dart` | Add `browserStackEnabled` constant |
| `packages/patrol/lib/src/platform/ios/ios_automator_native.dart` | Override `configure()` |
| `packages/patrol/darwin/Classes/SwiftPatrolPlugin.swift` | Move swizzle to method channel handler |
| CLI test files | Update if needed |

## Usage

```bash
# BrowserStack builds -- swizzles installed, camera injection works
patrol test --browserstack --target patrol_test/qr_scanner_test.dart

# Non-BrowserStack builds -- no swizzles, no side effects
patrol test --target patrol_test/some_other_test.dart
```

Or via dart-define directly (without CLI flag):
```bash
flutter test --dart-define PATROL_BROWSERSTACK=true ...
```

## Verification

1. Build example app without `--browserstack` -- confirm no `[Patrol] AVCaptureSession.startRunning swizzled` log message
2. Build example app with `--browserstack` -- confirm swizzle log appears after configure
3. Run QR scanner test on BrowserStack with `--browserstack` -- confirm camera injection still works end-to-end
