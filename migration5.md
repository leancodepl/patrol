# Migrating to Patrol 5.0

Working notes for the Patrol 5.0 migration guide. Every change on `release/5.0`
that needs action from users adds a section here, or a line to the Inbox at the
end. Before the release, this file becomes the migration guide in the docs.

Each section says which packages it affects, what changed and what to do.

## Package versions

Update `patrol` and `patrol_cli` together: Patrol 5.0 is `patrol` 5.x with
`patrol_cli` 5.x. Prereleases are published as `5.0.0-dev.N`.

| Package | 5.0 | Notes |
|---|---|---|
| `patrol` | 5.x | |
| `patrol_cli` | 5.x | |
| `patrol_mcp` | not released yet | needs a release that depends on `patrol_cli` 5.x; until then it resolves `patrol_cli` 4.x |
| `patrol_finders` | 4.x | `pumpAndSettle()` returns `Future<int>` and other API changes, see below |
| `patrol_log` | 0.10.x, no change so far | |

To try a prerelease, pin it explicitly, since pub doesn't pick prereleases on
its own:

```yaml
dev_dependencies:
  patrol: 5.0.0-dev.1
```

```bash
dart pub global activate patrol_cli 5.0.0-dev.1
```

## Flutter 3.44 and Dart 3.12 are required

**Packages:** `patrol`, `patrol_cli`

| Package | Before | 5.0 |
|---|---|---|
| `patrol` | Flutter 3.32, Dart 3.8 | Flutter 3.44, Dart 3.12 |
| `patrol_cli` | Dart 3.8 | Dart 3.12 (Flutter 3.44) |

`patrol_cli` moved to `platform` 3.2.0, which needs `meta` 1.18. Flutter pins
`meta` 1.18 only from 3.44 on, so `patrol_cli` can't resolve on older Flutter
versions. `patrol` follows, so both packages have the same minimum.

**What to do:**

1. Upgrade Flutter to 3.44 or newer (`flutter upgrade`, or bump the version in
   your FVM config or CI).
2. Update `patrol` in your `pubspec.yaml` and reactivate `patrol_cli`:

   ```bash
   dart pub global activate patrol_cli
   ```

If you can't upgrade Flutter yet, stay on Patrol 4.x: keep `patrol: ^4.11.0` in
your `pubspec.yaml`. `dart pub global activate patrol_cli` on an older Flutter
picks the newest `patrol_cli` 4.x on its own.

## Android API 24 and macOS 10.15 are the minimum platform versions

**Packages:** `patrol`

| Platform | Before | 5.0 |
|---|---|---|
| Android | API 21 (Android 5.0) | API 24 (Android 7.0) |
| iOS | 13.0 | 13.0 (no change) |
| macOS | 10.14 | 10.15 |

These are the minimums of Flutter 3.44, so an app that builds with Flutter 3.44
already meets them, unless it sets lower values explicitly.

**What to do:**

- **Android:** in `android/app/build.gradle(.kts)`, set `minSdk` to 24 or
  higher, or use `flutter.minSdkVersion`. A lower value fails the build with
  `uses-sdk:minSdkVersion 21 cannot be smaller than version 24 declared in library [:patrol]`.
- **macOS:** set the deployment target to 10.15 or higher: `platform :osx,
  '10.15'` in `macos/Podfile`, and **macOS Deployment Target** of both `Runner`
  and `RunnerUITests` in Xcode.

## The native API (`$.native`, `$.native2`) is removed

**Packages:** `patrol` (#3417)

Removed APIs, deprecated since Patrol 4.0:

- `$.native`, `$.native2`, `$.nativeAutomator`, `$.nativeAutomator2`
- `NativeAutomator`, `NativeAutomator2`, `NativeAutomatorConfig`
- `NativeSelector` and `GetNativeViewsResult`, which only the native API used
- the `nativeAutomatorConfig` parameter of `patrolTest`
- the `timeout` parameter of `PatrolBinding.runTest`, which had no effect since Patrol 2.6

`NativeView` and `PatrolActionException` stay.

**What to do:**

1. Run `dart fix --apply`. It rewrites `$.native` and `$.native2` to `$.platform.mobile`, and
   `NativeSelector` to `MobileSelector`, among others. It only fixes files that import
   `package:patrol/patrol.dart` directly. On Dart 3.14+, `dart migrate --apply` applies the same
   fixes, but only when it bumps your `environment.sdk`. A package already at the latest SDK is
   skipped, so run `dart fix --apply` there.
2. Run `dart analyze` and fix what's left by hand: Android-only calls (`pressBack()`,
   `enableLocation()`, ...) move to `$.platform.android`, iOS-only calls to `$.platform.ios`.
3. Remove `timeout:` from overrides or calls of `PatrolBinding.runTest`; use `timeout` on
   `patrolTest` instead.

Full list of rewrites and manual steps: [Migrate from native to platform](https://patrol.leancode.co/native-to-platform-migration#dart-fix-in-patrol-50).

## `pumpAndSettle()` returns the number of pumped frames

**Packages:** `patrol_finders`, `patrol`

`PatrolTester.pumpAndSettle()` (`$.pumpAndSettle()`) returns `Future<int>`
instead of `Future<void>`: the number of frames it pumped, the same value
`WidgetTester.pumpAndSettle()` returns. This makes `patrol_finders` 4.x, and
`patrol` 5.x depends on it.

**What to do:**

- **`await $.pumpAndSettle()`:** nothing, it compiles unchanged.
- **`patrol_finders` in your own `pubspec.yaml`:** change the constraint to
  `^4.0.0`, otherwise it conflicts with `patrol` 5.x.
- **A subclass that overrides `pumpAndSettle()`:** return `Future<int>`, e.g.
  the value of `super.pumpAndSettle()`.
- **A class that implements `PatrolTester`:** return `Future<int>` from
  `pumpAndSettle()`, e.g. the value of `WidgetTester.pumpAndSettle()`.
- **A mock that stubs `pumpAndSettle()`:** answer with an `int`, e.g.
  `thenAnswer((_) async => 1)`; `thenAnswer((_) async {})` no longer compiles.

## Other `patrol_finders` 4.x API changes

**Packages:** `patrol_finders`, `patrol`

`PatrolFinder` extends `Finder` instead of implementing `MatchFinder`.
`PatrolTester.pumpWidget()` takes `duration` and `phase` as named parameters
instead of positional ones, and both `pumpWidget()` and `pumpWidgetAndSettle()`
take `wrapWithView`, like `WidgetTester.pumpWidget()`.
`pumpWidgetAndSettle()` returns `Future<int>`, the number of frames pumped while
settling. Tests that only find, tap and pump with one argument compile
unchanged.

**What to do:**

- **`$.pumpWidget(app, duration)` or `$.pumpWidget(app, duration, phase)`:**
  name the arguments: `$.pumpWidget(app, duration: duration, phase: phase)`.
- **A `PatrolFinder` stored as `MatchFinder`:** use `Finder`. `$(...).matches()`
  still works.
- **A subclass or implementation of `PatrolTester` that overrides
  `pumpWidget()` or `pumpWidgetAndSettle()`:** take `duration` and `phase` as
  named parameters, add `bool wrapWithView = true`, and return `Future<int>`
  from `pumpWidgetAndSettle()`, e.g. the value of `super.pumpWidgetAndSettle()`.
- **A mock that stubs them:** match `duration` and `phase` by name, e.g.
  `mock.pumpWidget(any(), duration: any(named: 'duration'))`, and answer
  `pumpWidgetAndSettle()` with an `int`, e.g. `thenAnswer((_) async => 1)`.

## Build-time test discovery is the default

**Packages:** `patrol`, `patrol_cli`

`patrol test` and `patrol build` on Android and iOS now discover your tests on
your computer before the build and generate one native test class per Dart test
file. Before 5.0 this was opt-in (`emit_test_manifest: true`). Runtime
discovery is still there as an opt-out, and `patrol develop` keeps using it
unless you turn build-time discovery on.

What changes for you:

| | Before | 5.0 |
|---|---|---|
| iOS native test name | `RunnerUITests/<dart test name>` | `PatrolGeneratedTests_<file>/test_<name>` |
| Android native test name | `MainActivityTest#runDartTest[<dart test name>]` | `PatrolGeneratedTests_<file>#test_<name>` |
| Tests in `integration_test/` | Runtime discovery | Runtime discovery, with a warning on every build |
| Registration that depends on `Platform` | Works | The test can go missing or fail on the device |

**What to do:**

1. **Move your tests out of `integration_test/`**, for example to
   `patrol_test/`, and set `patrol.test_directory` if you pick another name.
   Flutter runs everything under `integration_test/` on a device, so it can't
   be discovered on your computer.
2. **Use `patrolTargetPlatform` where a test is registered.** Discovery runs
   your test files on your computer, where `dart:io`'s `Platform` and
   `defaultTargetPlatform` describe your computer, not the device. Anything that
   decides whether a test exists or is skipped, and any code in `main()` outside
   a test body, must use `patrolTargetPlatform`:

   ```dart
   patrolTest(
     'shares the invoice',
     ($) async { ... },
     skip: patrolTargetPlatform == PatrolTargetPlatform.iOS,
   );
   ```

   A test file that throws while it loads (for example
   `throw UnsupportedError('Unsupported platform')` in `main()`) fails the
   build, and the error is shown.
3. **iOS: include the generated tests in `RunnerUITests.m`.** Add three lines
   after the runner macro in `ios/RunnerUITests/RunnerUITests.m`. The file then
   looks like this and works with both discovery modes:

   ```objc
   @import XCTest;
   @import patrol;
   @import ObjectiveC.runtime;

   PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
   #if __has_include("PatrolGeneratedTests.inc")
   #include "PatrolGeneratedTests.inc"
   #endif
   ```

   Patrol doesn't edit the file. Until the lines are there, iOS builds use
   runtime discovery and print a warning with them (a build with
   `--emit-test-manifest` or `emit_test_manifest: true` stops instead). A runner
   set up for the 4.x opt-in
   (`PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BASE`) keeps working; the 4.7.0
   `PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BEGIN`/`_END` pair doesn't compile
   any more, replace it with the snippet.
4. **Ignore the generated files.** Add to `.gitignore`:

   ```text
   PatrolGeneratedTests.inc
   PatrolGeneratedTests.java
   PatrolGeneratedTests_*.java
   ```

5. **Update anything that matches native test names**: test filters and shard
   lists on device farms (Firebase Test Lab, emulator.wtf, BrowserStack,
   SauceLabs, LambdaTest, Marathon), JUnit report parsing, flaky-test
   dashboards. Use the generated class and method names (see the table above),
   or select tests by Dart name or file with `patrol test-without-building
   --only`.

**To keep runtime discovery**, set it in `pubspec.yaml`:

```yaml
patrol:
  emit_test_manifest: false
```

or pass `--no-emit-test-manifest` to a single command. Nothing else is needed,
`RunnerUITests.m` works in both modes.

## Inbox

Short notes on changes that don't have a section yet, one line each: the PR or
branch, the packages, what changed and what users have to do (`TODO` when that
isn't known yet). A line leaves the Inbox when it becomes a section above. Empty
the Inbox before 5.0.0 is released.

- #3382, `patrol_cli`: `patrol develop` no longer accepts `--tags`, which it never applied. Remove
  `--tags` from `patrol develop` commands and scripts; `patrol test` keeps it.
- #3040, `patrol_cli`: `patrol develop` on web requires Flutter 3.47.0 or newer, since hot restart
  needs flutter/flutter#183838; every other platform and `patrol test` on web keep the 3.44 floor.
  Upgrade Flutter, or point patrol at a newer SDK with `--flutter-command`, to keep using
  `patrol develop -d chrome`.
