## 3.3.0

- Add `clear-permissions` flag on ios commands. (#2367)

This version requires version 3.12.0 of `patrol` package.

## 3.2.1

- Allow running Patrol tests from any subfolder of the project (#2351)
- Bump min Flutter SDK to 3.24.0 and Dart SDK to 3.5.0 (#2371)

## 3.2.0

- Add code coverage collection support (#2294)

This version requires version 3.11.0 of `patrol` package.

## 3.1.1

- Fix checking `java` version. (#2301)
- Change selecting `java` path. (#2300)

## 3.1.0

- Add `tags` and `exclude-tags`. (#2286)
- Run `flutter build apk --config-only` during android build.(#2293)

This version requires version 3.10.0 of `patrol` package.

## 3.0.1

- Fallback to read `java` version from `JAVA_HOME` when `flutter doctor` doesn't print any.

## 3.0.0

- **Breaking:** Use `java` version from `flutter doctor`

## 2.8.1

- Fix parsing non string values from --dart-define-from-file (#2243).

## 2.8.0

- Add support for --dart-define-from-file (#2232).

## 2.7.0

- Add support for custom flutter commands (#2124).

## 2.6.5
- Add support for --app-server-port and --test-server-port on Android (#2154).

## 2.6.4

- Fix compatibility_checker getting stuck (#2091).

## 2.6.3

- Fix invalid JSON output of version check command (#2087).

## 2.6.2

- Print link to devtools regardless of open-devtools flag (#2076).

## 2.6.1

- Fix passing port on iOS when `patrol build` is executed (#2061). 

## 2.6.0

- Allow for changing the port when running on iOS (#2027).

  To do so, pass `test-server-port` (default 8081) and `app-server-port`
  (default 8082) to Patrol CLI commands (e.g `patrol test`)

- Do not open devtools by default when `patrol develop` is executed (#2048).

This version requires version 3.4.0 of `patrol` package.

## 2.5.0

- Allow for defining a custom test file suffix (#2009)
- Fix opening devtools on Windows (#2011)

## 2.4.0

- Add support for running patrol tests on macOS (alpha) (#1847)
- Set `--destination-timeout 1` when calling `xcodebuild test-without-building`
  to fail faster in error conditions (#1979)
- Set `--only-testing RunnerUITests/RunnerUITests` to ignore other XCTest that
  might be present (#1991)

## 2.3.1+1

- Add screenshots to `pubspec.yaml` (#1917)

## 2.3.1

- Bump dependencies for Flutter 3.16 and Dart 3.2
- Populate `topics` in pubspec (#1904)
- Remove warning about `patrol_finders` being split from `patrol`
- Allow to disable autogenerating shell completion code in `~/.zshrc` (and
  alike) by setting the `PATROL_NO_COMPLETION` environment variable

## 2.3.0

- Add support for Patrol 3.0 and its DevTools extension (#1829)
  - Automatically open DevTools when running `patrol develop`. This behavior can
    be disabled by passing `--no-open-devtools` flag.

This version requires version 3.0.0 of `patrol` package.

## 2.2.2

- Fix parsing `--dart-defines` when a value contains a comma (#1845)

## 2.2.1

- Fix bug with `test_bundle.dart` being sometimes garbled on Windows (#1797)

## 2.2.0

- Add support for `group()` (#1634)
- Adjust generated `test_bundle.dart` to not depend on gRPC contracts (#1681)

This version requires version 2.3.0 of `patrol` package.

## 2.1.5

- Remove notice about migrating to Patrol 2.0 (#1738)

## 2.1.4

- Uninstall RunnerUITests app on iOS when flavor is present (#1694)

## 2.1.3

- Add migration message due to release of `patrol_finders`

## 2.1.2

- Fix `.xctestrun` file not being found when the `RunnerUITests` targe uses
  XCTestPlans (#1636)

## 2.1.1

- Change the location of iOS test reports to `build/ios_results` with timestamp
  appended. The path to the report is printed after `patrol test` exits (#1623)

## 2.1.0

- Add `--no-generate-bundle` flag (#1565)
- Don't check for `patrol_cli` updates on CI (#1557)

## 2.0.4

- Fix crashes on some older Android versions when speculative `adb uninstall` is
  called (#1529)

## 2.0.3

- Uninstall the app before `patrol test` and `patrol develop`, in addition to
  uninstalling them after tests finish (#1500)

## 2.0.2

- Fix `--release` not working when building/running on Android (#1484)

## 2.0.1

- Support for fix for WebViews on modern Android versions (#1398)
- Implement a proper fix for tests failing when using native automation on
  Android + Flutter 3.10 (#1398). This replaces a workaround implemented in
  #1352.

This version requires version 2.0.1 of `patrol` package.

## 2.0.0

Patrol 2.0 is released!

- Read the changelog and migration guide [here](https://patrol.leancode.co/v2)
- Read the article about how Patrol 2.0 fixes the `integration_test` plugin
  [here](https://leancode.co/blog/patrol-2-0-improved-flutter-ui-testing)

This version requires version 2.0.0 of `patrol` package.

## 1.1.11

- Deprecate running test on many devices simultaneously (#1318)

## 1.1.10

- Fix `dart pub global activate patrol_cli` failing because of transitive
  dependency not following semver (#1290)

## 1.1.9

- Add support for Flutter 3.10 (#1254)
- Fix crashes on Windows (#1255)

## 1.1.8

- Fix analytics being always enabled (#1246)

## 1.1.7

- Fix `patrol develop` not attaching to the app on the other-than-first attached
  device (#1210)

## 1.1.6

- Default to "Yes" when asking for telemetry (#1201)

## 1.1.5

- Don't ask to collect analytics if running on CI (#1197)

## 1.1.4

**This version requires version 1.0.9 of the `patrol` package**

- Add optional telemetry (#1157), (#1182)
- Rewrite native test reporting (#1178)

## 1.1.3

- Add `--exclude` flag to `patrol test` (#1137)

## 1.1.2

- Fix `patrol test`/`patrol develop` being stuck after tests finish if `adb`
  executable is not in $PATH. Now an error is thrown (#1119)

## 1.1.1

- Fix bug when running on iOS (`.xctestrun` file couldn't be found) (#1111)
- Make `patrol develop` command visible (#1104)

## 1.1.0

- Automatically infer iOS-specific build options: `scheme` and `configuration`
  (#1090). The following options were removed from `patrol test` and `patrol
develop` commands: `--scheme`, `--xcconfig`, `--configuration`
- Add `patrol build android` and `patrol build ios` commands (#1097)

## 1.0.10

- Fix error when scheme name is not `Runner` (#1076)

## 1.0.9

- Fix "error while disposing" when SIGINT (CTRL+C) is received when waiting for
  app to start on physical iOS device (#1073)
- Fix `patrol build` crashing (#1074)

## 1.0.8

- Disable forwarding `q` from `patrol develop` to `flutter attach` because it's
  broken (#1069)
- Improve error when patrol develop is missing `--target` option (#1064)

## 1.0.7

- Fix disposing error when SIGINT (CTRL+C) is sent during `patrol develop`
  (#1057)

## 1.0.6

- Add `patrol develop` command which supports **Hot Restart** (#1057). It's not
  stable, but you can already try it out and report bugs.

## 1.0.5

- Add `patrol build` command to make it easier to build app binaries for cloud
  device farms (#1006). It's not stable, but you can already try it out and
  report bugs. Also, for now it only builds Android APKs.

## 1.0.4

- Make it possible to run x86-only iOS apps on the Simulator (#1005)
- Make it possible to define flavor per OS in `patrol` in `pubspec.yaml`
- Generate CLI completion in `$XDG_USER_HOME` instead of `$HOME` (#1002)

## 1.0.3

- Add `--no-uninstall` flag, which lets you not uninstall the apps after the
  tests finish (#983)

## 1.0.2

- Make output of `patrol test` much less verbose when test fails on Android.
  (#964)

  Run with `--verbose` to still see all the logs that were previously visible.

## 1.0.1+1

- Fix publish workflow (#955) (#956)

## 1.0.1

- Add shell completion (#950)
- Use automated publishing with GitHub Actions on pub.dev (#953)

## 1.0.0

- [Patrol 1.0 is
  released!](https://leancode.co/blog/patrol-1-0-powerful-flutter-ui-testing-framework)

## 0.9.4

- `patrol test`: Improve how external tool invocations are logged when running
  with `--verbose` (#906)
- `patrol test:` Fix `.xctrunner` app not being uninstalled after tests finish
  on iOS Simulator (#907)

## 0.9.3

- Add support for `flavor` in Patrol configuration block in `pubspec.yaml`
  (#892)
- Fix `patrol test` not propagating `PATROL_VERBOSE` (activated with `--verbose`
  flag) to the Flutter side (#892)

## 0.9.2

- Fix `patrol test` broken on Windows when running tests on Android (#889)

## 0.9.1

- Improve error message of `patrol test` when the `integration_test` directory
  doesn't exist (#876)
- Make `patrol test` run tests in a more predictable, `ls`-like order (#882)
- Fix `patrol test` incorrectly encoding `--dart-define` when running on Android
  (#885)
- Display name of currently running test file in top-left corner (#885)

## 0.9.0

- Enable `patrol test` for physical iOS devices (#863)
- Make it possible to specify `package_name` and `bundle_id` in `pubspec.yaml`
  (#868)

  If these values are set, the tool automatically uninstalls the app after every
  test. It's recommended to set them.

  Example:

  ```yaml
  dependencies:
    # ...

  dev_dependencies:
    # ...

  patrol:
    android:
      package_name: pl.leancode.awesomeapp
      app_name: Awesome App
    ios:
      bundle_id: pl.leancode.AwesomeApp
      app_name: Awesome App
  ```

## 0.8.6

- Uninstall app under test after `patrol test` (#848)

  This currently requires package name (on Android) and bundle identifier (on
  iOS) to be passed through respective arguments to `patrol test`. Soon it'll
  also be possible to define these values in `pubspec.yaml.

- Print helpful links when called without arguments (#865)
- Fix verbose output from Gradle having garbled newlines (#858)

## 0.8.5

- Add a deprecation warning to `patrol drive` command (#833)

  Use the new `patrol test` command. [See setup
  instructions](https://patrol.leancode.co/native/setup).

## 0.8.4

- When using `patrol test`, infer `--configuration` from `--flavor` when
  possible (#796)

- Fix `patrol test` on Windows (#805)

## 0.8.3

- Make `patrol test` more configurable (#791)

## 0.8.2+1

- Fix typo in changelog (#783)

## 0.8.2

- Add `patrol test` command (#731)

  `patrol test` runs tests natively (using Gradle on Android and `xcodebuild` on
  iOS). This command is hidden from `patrol --help` for now until we're sure it
  has the same features `patrol drive`, but you can already use it. In a future
  release, `patrol drive` will be deprecated, and in 1.0, `patrol drive` will be
  removed in favor of `patrol test`.

  [Learn more
  here](https://patrol.leancode.co/roadmap#why-is-patrol-drive-being-deprecated)
  about why we're deprecating `patrol drive`.

  [Learn more here](https://patrol.leancode.co/ci) about how to setup your
  project to use `patrol test`.

## 0.8.1

- Add `--label/--no-label` flag to `patrol drive`, that displays the test name
  over the running app, making it easier to identify which test is currently
  running (#701)

## 0.8.0

- Add support for Patrol Next (#646, #671)

## 0.7.17

- Add support for `NativeAutomator.swipe()` (#669)

## 0.7.16

- Add support for `--use-application-binary` argument for `patrol drive` (#667)

## 0.7.15

- Update `bootstrap` command to generate code working with `patrol` v0.9.0
  (#665)
- Display short name instead of UUID in test results when running on iPhone
  (#664)

## 0.7.14

- AutomatorServer:
  - Add 1 second delay after performing permission action on Android (#647)

## 0.7.13

- Improve output (#644)

## 0.7.12

- AutomatorServer:
  - Migrate gRPC server from Netty to OkHttp (#642)

## 0.7.11

- Print status of test runs after `patrol drive` finishes (#624)

## 0.7.10

- Print error message when screenshot fails on host side (#625)
- Perform internal refactoring to make testing the CLI easier (#626)

## 0.7.9

- Fix running tests that failed to build (#615)
- Fix rare crashes on slower machines caused by `activity` service not running
  on Android emulator (#615)

## 0.7.8

- Add support for `patrolIntegrationDriver` (#593)
- Remove port forwarding, which wasn't needed for some time (#597, #603)

## 0.7.7+1

- Fix `--dart-define`s being malformed (#589)

## 0.7.7

- Add support for optional `.patrol.env` file where `--dart-define`s can be
  stored to avoid typing them manually in `patrol drive` invocations (#585)

## 0.7.6+2

- Fix crashing on Windows (#586)
- Fix bug with tests running n^2 times instead of n times (#580)

## 0.7.6+1

- Fix crashing on Windows (#574)

## 0.7.6

- Add `--repeat` argument to `patrol drive`, which makes flake detection easier
  (#552)

## 0.7.5

- Reenable terminal animations (#521)
- Fix infinite wait when more than 2 Android devices are connected (#553)

## 0.7.4+1

- Fix `patrol doctor` crashing on Windows (#546)

## 0.7.4

- Print more useful info in `patrol doctor` (#541)
- Accept both device name and device ID for the `--device` argument to `patrol
drive` (#537)
- Wait for the `package` service to become active on Android before installing
  apk (#539, #540)

## 0.7.3+1

- Disable terminal animations to fix logs on the CI (#498)

## 0.7.3

- AutomatorServer:
  - Improve reliability of native interactions on iOS (#489)
  - Set minimum iOS version to 14.0 (#496)

## 0.7.2+1

- Fix too aggressive logging when downloading artifacts (#484)

## 0.7.2

- Make `--target` flag accept directories (#473)
- Use prebuilt artifacts when running on iOS Simulator (#465)
- Automatically download new artifacts during `patrol update` (#465)

## 0.7.1+3

- Minimize iOS artifact size (#469)

## 0.7.1+2

- Prebuild iOS artifacts for iPhones (#454)

## 0.7.1+1

- Add version to prebuild iOS artifacts (#460)

## 0.7.1

- Fix occasional crashes caused by Flutter's version prompt (#456)

## 0.7.0+1

- Build iOS artifacts on CI (#452, #452)

## 0.7.0

In this release, we've focused on stability, reliability, and reducing
flakiness.

- AutomatorServer:
  - Add timeouts when interacting with native UI (#437)
  - Implement `isPermissionDialogVisible()` method (#448)
  - Fix entering text into SecureTextField on iOS (#446)

## 0.6.15

- Fix trying to run on all attached devices (instead of only the first one) when
  no device is specified (#442)

## 0.6.14

- AutomatorServer:
  - Further improve error messages occuring on the native side (#429)

## 0.6.13

- AutomatorServer:
  - Print more info about errors occuring on the native side (#414)

## 0.6.12

- AutomatorServer:
  - Fix `denyPermission()` not working on iOS (#413)

## 0.6.11

- Improve stability (#397)
- AutomatorServer:
  - Rename `getNativeWidgets()` to `getNativeViews()` (#399)
  - Add `tapOnNotificationByIndex()`, `tapOnNotificationBySelector()`, and
    `closeHeadsUpNotification()` on iOS (#398)

## 0.6.10

- Fix artifacts being downloaded on every run on Linux and Windows (#392)
- Fix a small typo during `patrol drive` (#391)
- AutomatorServer:
  - Fix `getNativeWidgets()` crashing on Android (#393)

## 0.6.9

- AutomatorServer:
  - Fix handling permission prompts now working in some edge cases (#383)

## 0.6.8

- Improve update prompt (#377)
- AutomatorServer:
  - Remove remaining Objective-C code (#374)

## 0.6.7

- AutomatorServer:
  - Implement enabling and disabling cellular on iOS (#371)
  - Fix crash with trying to use non-existent `AutomatorServer.xcworkspace` when
    running tests on iOS (#371)

## 0.6.6+2

- Build iOS test runner artifact in GitHub Actions (#362)

## 0.6.6+1

- Download artifacts from GitHub Releases insted of LeanCode's Azure Storage
  (#363)

## 0.6.6

- Release updated `AutomatorServer`s (#338)

## 0.6.5

- Fix `--targets` argument to `patrol drive` (#330)

## 0.6.4

- Add the `targets` alias for `target` option for `patrol drive` (#314)
- Add the `devices` alias for `device` option for `patrol drive` (#314)
- Add the `dart-defines` alias for `dart-define` option for `patrol drive`
  (#314)
- Remove support for the `patrol.toml` config file (#313)

## 0.6.3

- Don't require `host` and `port` to be defined in `patrol.toml` or passed in as
  command-line arguments (#301)
- Print cleaner, more readable logs when native action fails (#295)

## 0.6.2

- Restart `flutter drive` on connection failure (#280)
- Rename `--devices` to `--device` to be more consistent (#280)
- Populate `homepage` field in `pubspec.yaml` (#254)

## 0.6.1

- Fix handling native permissions on older Android API levels (#260)

## 0.6.0+1

- Fix URL of artifact storage (#259)

## 0.6.0

- **Rename to patrol_cli** (#258)

## 0.5.3

- Add new `--wait` argument which accepts the number of seconds to wait after
  the test finishes (#251)
- Make `maestro drive` run all tests (#253)

## 0.5.2

- Migrate iOS AutomatorServer to a more stable HTTP server, which doesn't crash
  randomly (#220)
- Add new `packageName` and `bundleId` fields to `maestro.toml`
- Add new arguments to the tool: `--package-name` and `--bundle-id`

## 0.5.1

- Add support for handling native permission requests on Android (#232)
- Fix Android AutomatorServer suppressing all accessibility services (#235)

## 0.5.0

- Now `maestro_cli` will clean up after itself, either when it exits normally or
  is stopped by the user (#209):
  - port forwarding is automatically stopped
  - artifacts are automatically uninstalled
- `pod install` is automatically run when iOS artifacts are downloaded (macOS
  only) (#206)

## 0.4.4+3

- Fix not working on Windows because of `flutter` command not being found

## 0.4.4+2

- Fix problem with project not building because of a breaking change in
  `package:mason_logger` dependency

## 0.4.4+1

- Fix issue with CI

## 0.4.4

- Add support for physical iOS devices

## 0.4.3

- Fix bug with APKs failing to force install when certificates don't match, this
  time once and for all

## 0.4.2

- Fix bug with APKs failing to force install when certificates don't match

## 0.4.1

- Rename `MAESTRO_ARTIFACT_PATH` environment variable to `MAESTRO_CACHE`
- Add `maestro devices` command
- Some work made under the hood to enable support for iOS

## 0.4.0

- Support [maestro_test
  0.4.0](https://pub.dev/packages/maestro_test/changelog#040)

## 0.3.5

- Fix dependency resolution problem

## 0.3.4

- Improve output of `maestro drive`

## 0.3.3

- Fix a crash which occured when ADB daemon was not initialized

## 0.3.2

- Fix a crash which occured when ADB daemon was not initialized
- Make it possible to add `--dart-define`s in `maestro.toml`
- Fix templates generated by `maestro bootstrap`

## 0.3.1

- Automatically inform about new version when it is available
- Add `maestro update` command to easily update the package

## 0.3.0

- Add support for new features in [maestro_test
  0.3.0](https://pub.dev/packages/maestro_test/changelog#030)

## 0.2.0

- Add support for new features in [maestro_test
  0.2.0](https://pub.dev/packages/maestro_test/changelog#020)

## 0.1.5

- Allow for running on many devices simultaneously
- A usual portion of smaller improvements and bug fixes

## 0.1.4

- Be more noisy when an error occurs
- Change waiting timeout for native widgets from 10s to 2s

## 0.1.3

- Fix a bug which made `flavor` option required
- Add `--debug` flag to `maestro drive`, which allows to use default,
  non-versioned artifacts from `$MAESTRO_ARTIFACT_PATH`

## 0.1.2

- Fix typo in generated `integration_test/app_test.dart`
- Depend on [package:adb](https://pub.dev/packages/adb)

## 0.1.1

- Set minimum Dart version to 2.16.
- Fix links to `package:leancode_lint` in README

## 0.1.0

- Add `--template` option for `maestro bootstrap`
- Add `--flavor` options for `maestro drive`
- Rename `maestro config` to `maestro doctor`

## 0.0.9

- Add `--device` option for `maestro drive`, which allows you to specify the
  device to use. Devices can be obtained using `adb devices`

## 0.0.8

- Fix `maestro drive` on Windows crashing with ProcessException

## 0.0.7

- Fix a few bugs

## 0.0.6

- Fix `maestro bootstrap` on Windows crashing with ProcessException

## 0.0.5

- Make versions match AutomatorServer

## 0.0.4

- Nothing

## 0.0.3

- Add support for `maestro.toml` config file

## 0.0.2

- Split `maestro` and `maestro_cli` into separate packages
- Add basic, working command line interface with

## 0.0.1

- Initial version
