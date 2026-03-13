# GitHub Workflows Documentation

This document describes all GitHub Actions workflows used in the Patrol project. Each workflow is listed with its purpose, trigger conditions, and Flutter/Dart versions.

## Testing Workflows

### Android Testing

| Workflow name | Workflow file | Schedule? | Device name | API level | Flutter version | Tags | Description |
|--------------|--------------|-----------|-------------|-----------|----------------|------|-------------|
| test android device | `test-android-device.yaml` | Every 12h | Pixel 8 Pro (shiba) | 35 | Flutter 3.38.x (stable) | `android && physical_device` | Runs E2E tests on Firebase Test Lab physical devices. Excludes `native_tests/` to reduce test duration. |
| test android emulator | `test-android-emulator.yaml` | PR, every 12h | Pixel7 | 36, 35, 34, 33, 32 | Flutter 3.38.x (stable) | `android && emulator` | Runs E2E tests on emulator.wtf emulators across multiple API levels. Excludes `volume_test.dart` due to emulator instability issues. |
| test android emulator webview | `test-android-emulator-webview.yaml` | PR, daily at 23:00 | Pixel7 | 31 | Flutter 3.38.x (stable) | `webview && android` | Runs webview-specific E2E tests on emulator.wtf. |
| test locales on android device | `test-android-locales.yaml` | Every 12h | MediumPhone.arm | 34 | Flutter 3.38.x (stable) | `locale_testing_android` | Tests locale support on Firebase Test Lab for English, French, German, and Polish locales. Excludes `native_tests/` directory. |

### iOS Testing

| Workflow name | Workflow file | Schedule? | Device name | iOS version | Flutter version | Tags | Description |
|--------------|--------------|-----------|-------------|-------------|----------------|------|-------------|
| test ios device | `test-ios-device.yaml` | Daily at 21:30 | iPhone 14 Pro | 16.6 | Flutter 3.38.x (stable) | `ios && physical_device` | Runs E2E tests on Firebase Test Lab physical devices. Excludes `native_tests/`, `overflow_test.dart`, and specific permission tests (`clear_permissions_test.dart`, `deny_many_permissions_test.dart`) because camera permissions are not cleared between tests on physical devices. Uses older iOS version to enable video recording in Test Lab. |
| test ios simulator | `test-ios-simulator.yaml` | Monthly on 1st | iPhone 16 | 26.0 | Flutter 3.38.x (stable) | `ios && simulator` | Runs E2E tests on iOS simulator. Excludes `web/` directory, `volume_test.dart`, `service_bluetooth_test.dart`, and permission tests (`clear_permissions_test.dart`, `deny_many_permissions_twice_test.dart`, `permissions_many_test.dart`) - TODO: investigate why permission tests fail on CI/CD. Records video and logs (TODO: videos need to be fixed). Uses xcresultparser to generate JUnit reports and converts them to CTRF format for test reporting. Timeout: 100 minutes. Runs with `--full-isolation` flag. |
| test ios simulator webview | `test-ios-simulator-webview.yaml` | Monthly on 1st | iPhone 17 Pro | 26.0 | Flutter 3.38.x (stable) | `webview && ios` | Runs webview-specific E2E tests on iOS simulator. Excludes `web_example_test.dart` and `volume_test.dart`. Uses xcresultparser to generate JUnit reports and converts them to CTRF format for test reporting. |
| test locales on ios device | `test-ios-locales.yaml` | No | iPhone 14 Pro | 16.6 | Flutter 3.38.x (stable) | `locale_testing_ios` | Tests locale support on Firebase Test Lab for English, French, German (de_DE), and Polish locales. Excludes `web_example_test.dart`. Currently disabled for PR triggers. |

### Other Platform Testing

| Workflow name | Workflow file | Schedule? | Flutter version | Tags | Description |
|--------------|--------------|-----------|----------------|------|-------------|
| test web | `test-web.yaml` | No | Flutter 3.38.x (stable) | — | Runs web-specific E2E tests on Chrome in headless mode. Triggers on PR for web-related changes. Uses target file instead of tags. |
| test macos | `test-macos.yaml` | Every 12h | Flutter 3.38.x (stable) | — | Runs E2E tests on macOS desktop platform. Runs tests from `patrol_test/macos` directory. Uses xcresulttool v1.7.1 for test reporting. |

## Package Preparation (CI) Workflows

| Workflow name | Workflow file | Runs on | Dart/Flutter version | Description |
|--------------|--------------|---------|---------------------|-------------|
| patrol prepare | `patrol-prepare.yaml` | PR (on patrol package changes), manual | Flutter 3.38.x (stable) | Runs CI checks for the `patrol` package: Android builds (Windows/Linux), Darwin code formatting (swift-format, clang-format), Flutter tests, analyzer, formatter, and schema regeneration. |
| patrol_cli prepare | `patrol_cli-prepare.yaml` | PR (on patrol_cli changes), manual | Flutter 3.38.x (stable) | Runs CI checks for `patrol_cli` package on Ubuntu and Windows: builds executable, runs tests, analyzer, formatter, and pub publish dry-run. |
| patrol_finders prepare | `patrol_finders-prepare.yaml` | PR (on patrol_finders changes), manual | Flutter 3.38.x (stable) | Runs CI checks for `patrol_finders` package: tests, analyzer, formatter, and pub publish dry-run. |
| patrol_log prepare | `patrol_log-prepare.yaml` | PR (on patrol_log changes), manual | Flutter 3.38.x (stable) | Runs CI checks for `patrol_log` package: analyzer, formatter, and pub publish dry-run. |
| patrol_devtools_extension prepare | `patrol_devtools_extension-prepare.yaml` | PR (on devtools extension changes), manual | Flutter 3.38.x (stable) | Runs CI checks for DevTools extension: tests, analyzer, formatter, and builds extension. |
| adb prepare | `adb-prepare.yaml` | PR (on adb package changes), manual | Dart 3.8 | Runs CI checks for `adb` package: tests, analyzer, formatter, and pub publish dry-run. |
| prepare e2e_app | `prepare-e2e_app.yaml` | PR (on all changes except docs), manual | Flutter 3.38.x (Windows), Flutter 3.32.x (Linux/iOS) | Runs CI checks for E2E test app: Android builds (Windows/Linux) with ktlint, iOS builds with swift-format/clang-format and unit tests, Flutter tests, analyzer, and formatter. |
| patrol_gen prepare | `patrol_gen-prepare.yaml` | PR (on patrol_gen changes), manual | Dart 3.8 | Runs CI checks for patrol contracts generator: analyzer and formatter. |

## Publishing Workflows

| Workflow name | Workflow file | Runs on | Description |
|--------------|--------------|---------|-------------|
| patrol publish | `patrol-publish.yaml` | Tag push (`patrol-v*`) | Publishes `patrol` package to pub.dev. Builds DevTools extension before publishing. Sends Slack notification for releases. |
| patrol_cli publish | `patrol_cli-publish.yaml` | Tag push (`patrol_cli-v*`) | Publishes `patrol_cli` package to pub.dev. Verifies version consistency. Sends Slack notification for releases. |
| patrol_finders publish | `patrol_finders-publish.yaml` | Tag push (`patrol_finders-v*`) | Publishes `patrol_finders` package to pub.dev. Sends Slack notification for releases. |
| patrol_log publish | `patrol_log-publish.yaml` | Tag push (`patrol_log-v*`) | Publishes `patrol_log` package to pub.dev. Sends Slack notification for releases. |
| adb publish | `adb-publish.yaml` | Tag push (`adb-v*`) | Publishes `adb` package to pub.dev. |

### PR-Triggered Workflows with Permission Checks

Some workflows run on `pull_request_target` (which has access to secrets) require repository write permission:
- `test-android-emulator.yaml` - Requires repository write permission
- `test-android-emulator-webview.yaml` - Requires repository write permission

These workflows verify the user has write access before running. If you don't have write access, the workflow will fail with a permission error. Contact a Patrol team member to run these workflows on your PR.

## Semver Check Workflows

| Workflow name | Workflow file | Runs on | Description |
|--------------|--------------|---------|-------------|
| patrol check semver | `patrol-check-semver.yaml` | PR (on patrol package changes) | Verifies semantic versioning compliance for `patrol` package changes. |
| patrol_finders check semver | `patrol_finders-check-semver.yaml` | PR (on patrol_finders changes) | Verifies semantic versioning compliance for `patrol_finders` package changes. |
| patrol_log check semver | `patrol_log-check-semver.yaml` | PR (on patrol_log changes) | Verifies semantic versioning compliance for `patrol_log` package changes. |

## Documentation Workflows

| Workflow name | Workflow file | Runs on | Description |
|--------------|--------------|---------|-------------|
| Vercel Production Deployment | `docs-production.yaml` | Push to master (on docs changes) | Deploys documentation to Vercel production environment. Uses Node.js 24. |
| Vercel Preview Deployment | `docs-preview.yaml` | PR (on docs changes) | Deploys documentation preview to Vercel with stable PR-specific alias. Comments preview URL on PR. Uses Node.js 24. |

## Utility Workflows

| Workflow name | Workflow file | Runs on | Description |
|--------------|--------------|---------|-------------|
| Verify Version Compatibility | `verify_compatibility.yml` | PR/push (on compatibility checker changes) | Runs compatibility tests and verifies compatibility tables are up-to-date. |
| send slack message | `send-slack-message.yaml` | Reusable workflow | Reusable workflow for sending test results notifications to Slack. Called by test workflows. |
| label pull request | `label_pull_request.yaml` | All PRs | Automatically labels PRs based on changed files. |
| Add prioritized issues to project | `add-to-project.yaml` | Issue labeled (P0, P1, P2) | Automatically adds prioritized issues to GitHub project board. |
| Potential Duplicates | `potential-duplicates.yaml` | Issue opened/edited | Automatically detects and labels potential duplicate issues using similarity threshold. |
| close inactive issues | `close-inactive-issues.yaml` | Schedule (hourly), issue comment | Closes issues labeled "waiting for response" after 7 days of inactivity. |
| lock closed issues | `lock-closed-issues.yaml` | Schedule (hourly) | Locks closed issues after 7 days of inactivity. |

## Schedule Summary

- **Every 12 hours**: `test-android-device.yaml`, `test-android-emulator.yaml`, `test-android-locales.yaml`, `test-macos.yaml`
- **Daily at 21:30 UTC**: `test-ios-device.yaml`
- **Daily at 23:00 UTC**: `test-android-emulator-webview.yaml`
- **Monthly (1st day)**: `test-ios-simulator.yaml`, `test-ios-simulator-webview.yaml`
- **Hourly**: `close-inactive-issues.yaml`, `lock-closed-issues.yaml`

## Notes

- Most test workflows run on Flutter 3.38.x from the stable channel
- Test workflows use various testing services:
  - Firebase Test Lab (FTL) for Android/iOS physical devices
  - emulator.wtf for Android emulators
  - Local simulators/emulators for iOS/Android simulator tests
- Test workflows send notifications to Slack via the reusable `send-slack-message` workflow
- All publish workflows require tag pushes with specific prefixes and send Slack notifications for non-prerelease versions
- Documentation deployments use Vercel with Node.js 24
- Android projects use Kotlin 2.1.0 for compatibility with Java 21 and modern Flutter tooling

### Tag-Based Test Selection

Test workflows use a tag-based system to select which tests to run. Tests are tagged in their source files using the `tags` parameter.

All tests in both the main `patrol_test` directory and the `patrol_test/native_tests` directory use the same tagging system.

**Common tags:**
- **Platform**: `android`, `ios`, `web`, `macos`
- **Environment**: `physical_device`, `emulator`, `simulator`
- **Features**: `webview`, `locale_testing_android`, `locale_testing_ios`

**Tag filtering in workflows:**

Workflows use the `--tags` flag with boolean expressions to select which tests to run:
- `--tags='android && physical_device'` - Tests must have BOTH tags
- `--tags='android && emulator'` - Tests with android AND emulator tags
- `--tags='webview && ios'` - Tests with webview AND ios tags
- `--tags='ios && simulator'` - Tests with ios AND simulator tags
- `--tags='ios && physical_device'` - Tests with ios AND physical_device tags

A test is selected if it matches ALL conditions in the boolean expression (AND operator). Tests can declare multiple tags in their `tags` parameter array, and the workflow filter will match tests that satisfy the expression.

**Test directories:**
- `dev/e2e_app/patrol_test/` - Main test directory with platform.mobile API tests
- `dev/e2e_app/patrol_test/native_tests/` - Tests using deprecated native/native2 API (both directories use the same tagging system)

**Test exclusions for physical device workflows:**
- Physical device workflows (`test-android-device.yaml`, `test-ios-device.yaml`) exclude the entire `patrol_test/native_tests/` directory to reduce test duration on expensive cloud testing infrastructure
- This is configured using the `--exclude` flag: `--exclude=patrol_test/web/,patrol_test/native_tests/,patrol_test/volume_test.dart`

