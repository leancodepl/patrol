## 3.12.0

- Add `clear-permissions` flag on ios commands. (#2367)

This version requires version 3.3.0 of `patrol_cli` package.

## 3.11.2

- Bump min Flutter SDK to 3.24.0 and Dart SDK to 3.5.0 (#2371)

## 3.11.1

- Replace whitespace in test case name in `PatrolJUnitRunner.java`. (#2361)

## 3.11.0

- Add code coverage collection support. (#2294)
- No throw error in `selectFineLocation` when it's already selected. (#2302)
- Add option to select tap location in `enterText` and `enterTextByIndex` (#2312)

This version requires version 3.2.0 of `patrol_cli` package.

## 3.10.0

- Implement `enableBluetooth` and `disableBluetooth` methods for Android > 11. (#2254)
- Implement `enableAirplaneMode` and `disableAirplaneMode` methods for Android. (#2254)
- Implement `enableLocation` and `disableLocation` methods for Android. (#2259)
- Fix opening settings app with clean state on iOS. (#2275)
- Add native skip. (#2278)
- Add `tags` and `exclude-tags`. (#2286)

## 3.9.0

- Add privacy manifest for Apple.
- Disabled use of system proxy in iOS/macOS (could lead to broken tests).
- Fix complete breakage of MacOS automations introduced in #2219.

## 3.8.0

- Add `openUrl(String url)` method, for testing deeplinks. (#2219) 
- Add `pressVolumeUp` and `pressVolumeDown()`. (#2223)

## 3.7.3

- Try closing system dialog when disabling wifi on iOS. (#2123)

## 3.7.2

- Bump `test_api` dependency to 0.7.0.
- Bump `patrol_devtools_extension` dependencies.
- Bump min Flutter SDK to 3.22


## 3.7.1

- Revert: Bump `patrol_devtools_extension` dependencies.
- Revert: Bump `test_api` dependency to 0.7.0.

## 3.7.0

- Bump `test_api` dependency to 0.7.0.
- Bump `patrol_devtools_extension` dependencies. 
- Support customization of doubleTap delay (Android only). (#2165)

## 3.6.1

- Fix clearing textfield before entering text on iOS (#2158).

## 3.6.0

- Add clearing textfield before entering text on iOS (#2145).
- Added the NativeAutomator2, which allows to interact with native using selectors designated for a specific platform (AndroidSelector and IOSSelector) (#2132).
- Add support for --app-server-port and --test-server-port on Android (#2154).

## 3.5.2

- Fix reporting fail cause to native on ios in release mode (#2114).

## 3.5.1

- Make more `Selector` properties work on iOS (#2030).
- Fix handling denying Android permissions when invoked second time (#2112).

## 3.5.0

- Add optional timeout parameter to native methods (#2042).
- Add `$.native.tapAt()` (#2053)
- Fix `native.enterText` interacting with first EditText regardless of `Selector` passed (Android-only) (#2072)
- Print link to devtools regardless of open-devtools flag (#2076).

## 3.4.0

- Allow for changing the port when running on iOS (#2027).

  To do so, pass `test-server-port` (default 8081) and `app-server-port`
  (default 8082) to Patrol CLI commands (e.g `patrol test`)

- Fix `patrolSetUp()` and `patrolTearDown()` not working in `patrol develop` (#2023).

This version requires version 2.6.0 of `patrol_cli` package.

## 3.3.0

- Enable selecting individual tests with `xcodebuild`'s `-only-testing` option.
  Currently iOS only, does not support macOS (#2001)
- Fix being unable to interact with the running app during testing with a finger
  (#2008)
- Fix non-ASCII characters displaying as gibberish in Patrol's DevTools
  extension (#2010)
- Fix Dart-side crash in test causing test suite to hang on iOS (#2013)

## 3.2.0

- Add support for running patrol tests on macOS (alpha) (#1847)

## 3.1.0

- Implement `patrolSetUp()` and `patrolTearDown()`, which are equivalents of
  vanilla `setUp()` and `tearDown()` but work with Patrol's native automation
  and test bundling feature (#1967) (#1721)

## 3.0.3

- Implement `$.native.swipe()` on iOS (#1927)

## 3.0.2+1

- Add screenshots to `pubspec.yaml` (#1917)

## 3.0.2

- Bump dependencies for Flutter 3.16 and Dart 3.2
- Populate `topics` in pubspec

## 3.0.1

- Fix extension code not being bundled by GitHub Actions workflow (#1902)

## 3.0.0

Give a warm welcome to the new **Patrol DevTools Extension**!

Patrol DevTools extension allows you to explore the native view hierarchy when
developing tests with `patrol develop`. Now you can easily see what Android /
iOS views are currently visible and discover their properties so that they can
be used in native selectors like `$.native.tap()`. You don’t have to use any
external tools for that. This is just the beginning, and we plan to add more
features to our extension in the future.

Other changes:

- Bump minimum supported Flutter version to 3.16
- **BREAKING:**

  - Remove `bindingType` parameter from `patrolTest()` function. Now only
    `PatrolBinding` is used and it's automatically initialized (#1882)
  - Remove `nativeAutomation` parameter from `patrolTest()` function. Now it's
    enabled by default (#1882)
  - This release also depends on [patrol_finders
    v2](https://pub.dev/packages/patrol_finders/changelog#200) and includes
    its breaking changes.

- Remove dependency on `integration_test` plugin (#1882)

This version requires version 2.3.0 of `patrol_cli` package.

## 2.3.2

- Add `PatrolFinder.longPress()` (#1825)

## 2.3.1

- Add support for iOS 11 and 12 (#1733)
- Fix build-time and run-time crashes when app doesn't use Kotlin 1.8.x (#1782)

## 2.3.0

- Add support for nested test hierarchies using `group()`s (#1634)
- Replace Protocol Buffers and gRPC with a custom code generation solution that
  is more lightweight (#1681)
- Fix test name label blocking hit testing (#1731)

This version requires version 2.2.0 of `patrol_cli` package.

## 2.2.5

- Fix `grantPermissionOnlyThisTime()` crashing on Android <11 (#1698)

## 2.2.4

- Remove deprecation of `nativeAutomation` and add message about migration to
  `patrol_finders` (#1670)

## 2.2.3

- Make `KeyboardBehavior.alternative` not automatically try to hide the keyboard
  on iOS (#1638)

## 2.2.2

- Fix deprecation message for `andSettle` (settleBehavior -> settlePolicy)
  (#1622)

## 2.2.1

- Fix `appId` parameter missing from `NativeAutomator.waitUntilVisible()`
  (#1611)
- Fix tests crashing by stopping depending on `dart:io` when running with
  `flutter_driver` on the Web (#1578)

## 2.2.0

- Use proper context in `PatrolJUnitRunner` (#1591)
- Make `Selector.instance` work on iOS (#1569)
- Ignore calls to `select[Fine|Coarse]Location()` on iOS < 14 (#1564)
- Add support for `getNativeViews` on iOS (#1553)

## 2.1.0

- Add `$.native.waitUntilVisible()` (#1543)
- Add `KeyboardBehavior` enum to native enterText() methods (#1511)

## 2.0.7

- Add an alternative `BrowserstackPatrolJUnitRunner`, which implements a fix to
  make tests run on BrowserStack (#1402)

## 2.0.6

- Implement `$.native.openQuickSettings()` for iPhones without notch (#1510)

## 2.0.5

- Fix occasional cryptic failures of Gradle builds (#1509)

## 2.0.4

- Fix tests occasionally failing on iOS because of dangling `SemanticsHandle`s
  (#1491)

## 2.0.3

- Remove dependency on `package:http` (#1485)

## 2.0.2

- Fix `enterText()` not working when running with `flutter_driver` on the web
  (#1459)

## 2.0.1

- Fix WebViews on modern Android versions (#1398). See #244 for more details.
- Implement a proper fix for tests failing when using native automation on
  Android + Flutter 3.10 (#1398). This replaces a workaround implemented in
  #1352
- Bump dependencies (#1446)

This version requires version 2.0.1 of `patrol_cli` package.

## 2.0.0

Patrol 2.0 is released!

- Read the changelog and migration guide [here](https://patrol.leancode.co/v2)
- Read the article about how Patrol 2.0 fixes the `integration_test` plugin
  [here](https://leancode.co/blog/patrol-2-0-improved-flutter-ui-testing)

This version requires version 2.0.0 of `patrol_cli` package.

## 1.1.5

- Fix tests failing when using native automation on Android + Flutter 3.10
  (#1352)

## 1.1.4

- Fix build with Android Gradle Plugin v8 (#1276)

## 1.1.3

- Fix `which()` not taking previous finder(s) into account (#1271)

## 1.1.2

- Fix crashing when using Gradle 8 (#1262)

## 1.1.1

- Add support for Flutter 3.10 (#1254)

## 1.1.0

This version marks the official release of Hot Restart. [Learn more
here](https://leancode.co/blog/hot-restart-in-patrol-framework).

## 1.0.9

**This version requires version 1.1.4 of the `patrol_cli` package**

- Rewrite native test reporting (#1178)

## 1.0.8

- Fix App Store warnings about non-public selectors from `patrol.framework`
  (#1096)

## 1.0.7

- Fix `tap()` sometimes not being able to tap on a widget that was previously
  found and scrolled to by `scrollTo()` (#1072)

## 1.0.6

- Add preliminary support for `patrol develop`. Requires version 1.0.6 of
  `patrol_cli`.

## 1.0.5+1

- Update small typo in pub.dev listing (#1034)

## 1.0.5

- Fix build of example app for Android when building on Windows (#998)

## 1.0.4

- Remove unnecessary dependency on `vm_service` (#986)

## 1.0.3

- Fix `PATROL_WAIT` (passed through `--wait` argument to `patrol test`)
  preventing frames from being pumped (#959)
- Fix tapping on notification crashing on iPads (#963)
- Remove no longer functional methods from `PatrolBinding` (#970)

## 1.0.2

- Make `NativeAutomator.enterTextByIndex()` have a default timeout, just like
  `NativeAutomator.enterText()` (#943)

  Documentation of these 2 methods has also been updated to explain the behavior
  in more detail.

- Use automated publishing with GitHub Actions on pub.dev (#953) (#955) (#956)
  (#957)

## 1.0.1

- Fix IndexOutOfBounds exception when waiting for native views on Android (#939)
- Fix `flutter run` not working in example app because of an error in Gradle
  build file (#940)

## 1.0.0

- [Patrol 1.0 is
  released!](https://leancode.co/blog/patrol-1-0-powerful-flutter-ui-testing-framework)

## 0.10.12

- Minor documentation fixes (#912)

## 0.10.11

- Remove unnecessary dependency on `json_serializable` and `json_annotation`
  (#904)

## 0.10.10

- Fix crash `Instrumentation run failed due to Process crashed` on Android
  (#902)

## 0.10.9

- Improve error message when trying to use `NativeAutomator`, but it's not
  initialized (#856)

## 0.10.8

- Add GitHub Actions showing to run Patrol tests natively on both Android and
  iOS (#747, #752)
- Add `PatrolTestRunner` class, which should be used instead of
  `FlutterTestRunner` in `MainActivityTest.java` file (#754)

## 0.10.7

- Strip out code that App Store is angry about by default in release iOS builds
  (#727)

## 0.10.6

- Make it possible to change `LiveTestWidgetsFlutterBindingFramePolicy` in
  `patrolTest()` (#716)

## 0.10.5

- Add support for test label overlay in PatrolBinding (#701)

## 0.10.4

- Migrate to lite Protocol Buffers and gRPC to avoid conflicts with Firebase on
  Android (#688)

## 0.10.3

- Fix Android dependencies leaking into dependent apps (#683)

## 0.10.2

- Fix breaking iOS builds by migrating off `CGVectorMake()`, which is
  unavailable in Swift (#676)

## 0.10.1

- Fix breaking iOS builds by setting minimum iOS version to 13.0 (#674)

## 0.10.0

- Allow for running as native Android/iOS instrumented test (Patrol Next) (#646,
  #671)

## 0.9.1

- Add `NativeAutomator.swipe()` to enable simple swiping (#669)

## 0.9.0

- **Breaking:** Remove `PatrolTester.log()` - it did not fit in there and was
  rarely used (#665)
- **Breaking:** Remove `PatrolTesterConfig.appName` - it's only usage was in
  `PatrolTester.log()`, and since it was removed, this field is removed as well
  (#665)

## 0.8.0

- **Breaking:** Change signature of `PatrolTester.pumpAndSettle()` method to use
  named arguments (#657)
- Fix `PatrolTester.dragUntilVisible()` not calling `first` on its `Finder view`
  parameter (#656)

## 0.7.6

- Make it possible to configure loggers of `NativeAutomator` and `HostAutomator`
  (#644)
- Throw `PatrolFinderException` when `PatrolFinder.text` fails (#644)

## 0.7.5

- Revamp configuration of testers, letting for more granural setup (#640):
  - Rename `PatrolTestConfig` to `PatrolTesterConfig`
  - Introduce `NativeAutomatorConfig`
  - Introduce `HostAutomatorConfig`
- Introduce `HostAutomator.run()` method, which lets you run programs on your
  computer from within your Flutter integration tests (#630)

## 0.7.4

- Fix minor bug with custom binding initialization (#636)

## 0.7.3

- Add `patrolIntegrationDriver`, which extends the default `integrationDriver`
  with cool features like taking screenshots. More features enabled by
  `patrolIntegrationDriver` are coming soon! (#593)
- Warn when package name and bundle identifier is not set in `PatrolTestConfig`
  (#591)

## 0.7.2

- Add `PatrolFinder.which()` (#571)

## 0.7.1

- Add `andSettle` param to `PatrolFinder.scrollTo()` (#501)
- Add more integration tests to the example app (#491)

## 0.7.0

In this release, we've focused on stability, reliability, and reducing
flakiness.

- Add timeouts when interacting with native UI (#437)
- Implement `isPermissionDialogVisible()` method (#448)

## 0.6.12

- Add useBinding flag to `patrolTest` (#419)

## 0.6.11

- **Breaking:** Rename `NativeAutomator.forTest()` constructor to an unnamed
  constructor (#410)
- Add `useBinding` flag to `NativeAutomator` constructor. Defaults to true,
  which means that `PatrolBinding` is initialized during the constructor call
  (#410)
- Fix `timeout` argument to `NativeAutomator` being ignored (#410)

## 0.6.10

- Make `$()` accept a `Widget` as an argument (#402)

## 0.6.9

- Remove the unused `appId` argument from most methods (#399)
- **Breaking:** Rename `getNativeWidgets()` to `getNativeViews()` (#399)

## 0.6.8

- Fix handling permission prompts now working in some edge cases (#383)

## 0.6.7+1

- Fix package score on pub.dev (#375)

## 0.6.7

- Implement enabling and disabling cellular on iOS (#371)

## 0.6.6

- Make `openApp()` open the app under test when no `appId` is passed (#338)
- Implement `enableWifi()`, `disableWifi()`, and `openRecentApps()` on iOS
  (#338)
- Completely rewrite communication with native automation servers (#338)

## 0.6.5

- Implement enabling and disabling dark mode on iOS (#345)

## 0.6.4+1

- Fix spelling of "cellular" (was "celluar") (#336)
- Fix a typo in docs (#337)
- Fix README and docs mentioning the removed `Patrol` class (#349)

## 0.6.4

- A bunch of post-release fixes (#330)

## 0.6.3

- Stop re-exporting `package:flutter_test` (#308)

## 0.6.2

- Don't require `host` and `port` to be defined in `patrol.toml` or passed in as
  command-line arguments (#301)
- Rename `Patrol` to `NativeAutomator` and embed it in `PatrolTester` (#297)
- Print cleaner, more readable logs when native action fails (#295)

## 0.6.1

- Fix handling native permission request dialogs on older Android versions
  (#260)
- Populate `homepage` field in `pubspec.yaml` (#254)

## 0.6.0

- **Rename to patrol** (#258)
- Remove `sleep` from `MaestroTestConfig`. Use the new `--wait` argument
  available in the CLI (#251)

## 0.5.5

- Bring more functionality to iOS (#246)
  - Implement native `tap()`, `enterText()`, and `handlePermission()` methods on
    iOS
  - `Maestro.forTest()`: add optional `packageName` and `bundleId` arguments

## 0.5.4

- Add support for handling native permission request dialogs on Android (#232)
- Attempt to fix a weird issue with scroll not working in some rare cases (#237)
- Re-export `package:flutter_test`

## 0.5.3

- Make `MaestroFinder.text` getter more robust

## 0.5.2

- Fix a problem with `StateError` being thrown when
  MaestroTester.dragUntilVisible found more than 1 finder after dragging to it
  (#228)

## 0.5.1

- Some fixes to the scrolling and dragging

## 0.5.0+1

- Set minimum Dart version to 2.17 (#224)

## 0.5.0

- Revamp scrolling and dragging (#217)

  - New `MaestroTester.dragUntilExists()`
  - Fixed `MaestroTester.dragUntilVisible()`'s behavior
  - New `MaestroTester.scrollUntilExists` method
  - New `MaestroTester.scrollUntilVisible` method
  - `MaestroFinder.dragTo` was renamed to `MaestroFinder.scrollTo` and now also
    scrolls to widgets that are not yet built (e.g in a lazily-built `ListView`)

- Allow for more fine-grained control over timeouts (#191)
  - `settleTimeout`, which is used for `MaestroTester.pumpAndSettle` (which
    forwards it to `WidgetTester.pumpAndSettle`)
  - `existsTimeout`, which is used for `MaestroFinder.waitUntilExists`
  - `visibleTimeout` (previously `findTimeout`), which is used by
    `MaestroFinder.waitUntilVisible` (which is then used internally by
    `MaestroFinder.tap()` and `MaestroFinder.enterText()`.

## 0.4.6

- Downgrade `package:freezed` to v1 beacuse customer project is not able to
  update to v2

## 0.4.5

- Create `MaestroTestConfig` class which is accepted by `maestroTest` function.
  Use it to share common configuration across all tests
- Upgrade `package:freezed` to v2. Dependent projects should also make this
  change

## 0.4.4

`MaestroFinder`:

- Rename `visible` method to `waitUntilVisible`
- Add `waitUntilExists` method
- Add `exists` getter
- Add `visible` getter

## 0.4.3

- Add `MaestroFinder.dragTo`
- Remove unused `MaestroTester.drag` and `MaestroTester.dragFrom`

## 0.4.2

- Convert `MaestroFinder.visible` getter to a method, which now also takes a
  timeout
- Rename `MAESTRO_ARTIFACT_PATH` environment variable to `MAESTRO_CACHE
- Fix `MaestroTester.dragUntilVisible` not waiting for the scrollable to appear
- Fix `MaestroFinder.allCandidates` returning incorrect results

## 0.4.1

- Throw `MaestroFinderFoundNothingException` when [MaestroFinder.visible]
  doesn't find any widget during [MaestroTester.findTimeout]

## 0.4.0

`MaestroFinder`:

- Now `tap()` and `enterText()` wait for the widget to become visible. The
  timeout can be configured by setting `findTimeout` in `maestroTest()`
- Remove `index` parameter from `tap()` and `enterText()`. The new way to select
  the widget to be tapped is to use `at()` before tapping. Same goes for
  entering text
- Add `bool andSettle` parameter to `maestroTest` function. This lets you
  globally configure whether to call `pumpAndSettle` after actions such as
  `tap()` or `enterText()`
- Refactor `MaestroTester.dragUntilVisible` to be simpler to use
- Rename `withDescendant()` to `containing()`

Native:

- Make `Maestro.openNotifications()` and `Maestro.openQuickSettings()` more
  robust

## 0.3.3

- Make it possible to pass Flutter's `Finder` to `$`
- Make `MaestroFinder.first`, `MaestroFinder.last`, `MaestroFinder.at()` return
  `MaestroFinder`, not `Finder`

## 0.3.2

- Improve selector engine:

  - Make it possible to pass a `Key` as `matching` to
    `MaestroTester.call(dynamic matching)` and `MaestroFinder.$(dynamic
matching)`

- Add `sleep` parameter for `maestroTest` method
- Make `WidgetTester`'s forwarded methods in `MaestroTester` accept less
  arguments
- Add more in-code documentation

## 0.3.1

- Improve selector engine:

  - Make it possible to pass a `MaestroFinder` as `matching` to
    `MaestroTester.call(dynamic matching)` and `MaestroFinder.$(dynamic
matching)`
  - Fix a bug which caused chaining `MaestroFinder`s (e.g
    `$(Scaffold).$(Container).$(#someText)`) to not work.

- Add more in-code documentation and improve README

## 0.3.0

- Add selector engine

## 0.2.0

- Introduce `Selector` class, which can be passed into `Maestro.tap(selector)`.
- Add more platform functionality:

  - `Maestro.enableWifi()` and `Maestro.disableWifi()`
  - `Maestro.enableCellular()` and `Maestro.disableCellular()`
  - `Maestro.enableDarkMode()` and `Maestro.disableDarkMode()`
  - `Maestro.getNotifications()`, `Maestro.getFirstNotification()`, and
    `Maestro.tapOnNotification(int index)`

- Make `Maestro.forTest()` automatically call
  `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
- Fix many smaller issues

## 0.1.4

- Allow for running on many devices simultaneously
- Rename class `Automator` to `Maestro`
- Simpified test-side initialization. Now all you need is `Maestro.forTest()`
- Simpified driver-side initialization. Now all you need is
  `Maestro.forDriver()`

## 0.1.3

- Add support for enabling/disabling Bluetooth

## 0.1.2

- Be more noisy when an error occurs

## 0.1.1

- Fix minor logging bug

## 0.1.0

- Add basic means of controlling platform-native Widgets (`TextView`,
  `EditText`, and `Button` on Android). This also applies to WebView.
- Add enabling and disabling of Wi-Fi, Cellular, and Night Mode
- Improve stability

## 0.0.6

- Set minimum Dart version to 2.16
- Fix links to `package:leancode_lint` in README

## 0.0.5

- Update broken link in README.

## 0.0.4

- Update README

## 0.0.3

- Rename from `maestro` to `maestro_test`

## 0.0.2

- Split `maestro` and `maestro_cli` into separate packages

## 0.0.1

- Initial version
