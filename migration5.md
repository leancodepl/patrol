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
| `patrol_mcp` | discontinued | replaced by the `patrol mcp` command of `patrol_cli`, see below |
| `patrol_finders` | 4.x | `pumpAndSettle()` returns `Future<int>`, see below |
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
| Registration that depends on `Platform` | Works | The run fails (see [Runs in which tests didn't run fail](#runs-in-which-tests-didnt-run-fail)) |

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

## Runs in which tests didn't run fail

**Packages:** `patrol`, `patrol_cli`

With build-time discovery Patrol knows which tests a run should execute, so
runs that used to pass while running fewer tests now fail:

| Situation | Before | 5.0 |
|---|---|---|
| No `MainActivityTest.java` in `android/app/src/androidTest` | `Total: 0`, exit 0 | The build stops with a setup error |
| Fewer tests ran than discovered (app not installed, stale test APK) | Passes | Fails and lists the tests that didn't run |
| A test registered only on the device (`Platform.isAndroid` around `patrolTest`) | Never runs, passes | Every test fails with the list of missing tests |

Runtime discovery doesn't run these checks, including the fallback for tests
in `integration_test/` or an iOS `RunnerUITests.m` without the `#include`.

**What to do:**

1. **Android:** make sure `MainActivityTest.java` is in place, as in the
   [setup](https://patrol.leancode.co/documentation#setup).
2. Use `patrolTargetPlatform` for anything that decides whether a test is
   registered (see step 2 of the previous section).
3. If CI goes red after the upgrade, read the error: it names the tests that
   didn't run, which a green run used to hide.

## `patrol_mcp` is replaced by `patrol mcp`

**Packages:** `patrol_mcp`, `patrol_cli` (#3368)

The MCP server ships with `patrol_cli` as the `patrol mcp` command. `patrol_mcp`
gets no 5.x release.

**What to do:**

1. Remove the `patrol_mcp` dev dependency.
2. In your MCP client config, replace `dart run patrol_mcp` with `patrol mcp`
   (`patrol_cli` activated globally) or `dart run patrol_cli:main mcp`
   (`patrol_cli` as a dev dependency).
3. Pass flags for `patrol develop` after `--`, for example
   `patrol mcp -- --flavor dev`. `PROJECT_ROOT`, `PATROL_FLAGS` and
   `SHOW_TERMINAL` keep working.

## The text cursor doesn't blink in `patrolTest`

**Packages:** `patrol` (#3439)

`patrolTest` sets `EditableText.debugDeterministicCursor` while the test body
runs. On iOS, and with `CupertinoTextField` on any platform, the blinking cursor
kept scheduling frames, so every action that settled while a text field was
focused waited several seconds (up to the settle timeout). These actions now
return as soon as the app settles.

**What to do:**

- **Most tests:** nothing, they get faster.
- **A test that passed only because of that wait** (for example a bare
  `expect(...)` right after typing, while a request is still loading): wait for
  the result explicitly, e.g. `await $('Welcome').waitUntilVisible()`.
- **Screenshot or video comparisons with a focused field:** the cursor is now
  always visible; update the baselines once.
- **A focused `obscureText` field that gets a single new character** (for
  example `enterText('a')` into an empty field with `hideKeyboard: false`):
  that character stays visible until the field loses focus.
- **To keep the blinking cursor:** pass `deterministicCursor: false` to
  `patrolTest`.

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
- `fix/ios-selector-instance`, `patrol`: `Selector(instance: n)` now reaches iOS, so `tap`,
  `doubleTap`, `enterText` and `waitUntilVisible` target the n-th match instead of the first, and
  `waitUntilVisible` with `instance` fails on iOS and macOS when there are fewer matches. iOS counts
  every matching element (a web heading and its text are 2 matches), so n can differ from Android.
  Tests that passed `instance` for Android only: use `PlatformSelector` or drop `instance` on iOS.
