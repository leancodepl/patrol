# GitHub Workflows Documentation

This document describes all GitHub Actions workflows used in the Patrol project. Each workflow is listed with its purpose, trigger conditions, and Flutter/Dart versions.

## Required checks

This is the agreed split of PR checks: what blocks a merge, what only advises, and what never runs on a PR. Enforcement is not on yet, see Rollout at the end of this section.

The last neglect happened because failing workflows were not blocking merges. Required status checks fix that, with one catch we hit head-on (see Why a gate job).

**Mandatory: must be green to merge**

- Package CI: patrol prepare, patrol_cli prepare, patrol_finders prepare, patrol_log prepare, patrol_devtools_extension prepare, patrol_gen prepare, patrol_mcp prepare, adb prepare, prepare e2e_app
- Fast checks: check changelog, check skills, Verify Version Compatibility
- Android E2E on emulator.wtf: test android emulator, test android emulator webview
- Other E2E: test macos, test web, test patrol develop, test ios simulator (keep a retry on the iOS simulator, it is the flakiest of the gates)

**Advisory: read but never block**

- Semver: patrol check semver, patrol_finders check semver, patrol_log check semver. A version bump is the author's call, sometimes breaking on purpose, so we look at these and move on.
- pana scores: they run `continue-on-error` and sit outside every gate. A pub.dev score is a publish-time concern, not something a PR has to clear.
- patrol_mcp cli-compat: reports without failing CI by design.
- `pub publish --dry-run` inside the prepare jobs: set to `continue-on-error`. pub runs its own bundled `dart analyze`, which can lag the SDK version and flag a phantom, unactionable warning (exit 65) even when the job's own `flutter analyze` is clean. The real publish workflow validates at tag-push, so the dry-run stays advisory here.

**Never a PR gate: scheduled only**

- test flutter main channel, test flutter beta channel (they track upstream Flutter, a red there is usually not the PR's fault)
- test android device, test ios device, test locales on android device, test locales on ios device (Firebase Test Lab, real hardware, slow and paid)
- test ios simulator webview (monthly)

### Why a gate job

A required check that never reports leaves the PR stuck on "Expected — Waiting for status to be reported". GitHub does this whenever a required workflow is filtered out by `on: paths`: the run never starts, so no status arrives, and no branch-protection or ruleset setting counts a missing check as passed. A job skipped by a job-level `if:` reports success instead, and that does satisfy the check.

So each mandatory workflow drops the `on: paths` filter and gains two jobs:

- a `changes` job that calls the reusable [_relevant][_relevant] workflow with its filter globs and outputs whether the PR touches relevant files (the paths-filter + decide logic lives in one place instead of being copy-pasted per workflow),
- a gate job (named `<workflow> gate`) that `needs` every real job, runs with `if: always()`, and fails only when one of them failed or was cancelled.

The real jobs get `if: needs.changes.outputs.relevant == 'true'`, so a PR that does not touch a package skips its jobs (reported as success) and the gate still goes green. Branch protection requires the gate names, not the individual matrix jobs, so the required list stays short and the matrices can change freely. `pana` and the Slack notifier are left out of the gate, they stay advisory.

emulator.wtf runs on `pull_request_target`, so it has the base repo's secrets. Its inline `access` job lets `run_tests` run only when the PR branch lives in this repository (`head.repo == github.repository`, i.e. a trusted author with write access pushed it) and the paths are relevant. A fork PR skips `run_tests`, so fork code never sees the secrets and the gate still passes (the PR is not wedged). It checks `head.repo`, not `github.triggering_actor`: the actor becomes the maintainer on a re-run, which would otherwise hand fork code the secrets. A maintainer tests a fork PR from a trusted in-repo branch.

### Rollout

1. Land the gate jobs (this change).
2. Open one throwaway PR and confirm every gate goes green, including a docs-only PR and a single-package PR.
3. Add the `<workflow> gate` contexts to branch protection or a ruleset as required. This needs repo admin. The API read returned 404 for the current user, so someone with admin has to do this step.

Confirm dorny/paths-filter is allowed by the org action policy before step 2, or the changes jobs will fail.

### Bypass

Not built. Two routes if we want one: a bypass list on the ruleset for maintainers (native, shows in the audit log), or a label the gate reads and turns green on demand (same idea as the existing `skip changelog` label).

## Testing Workflows

### Android Testing

| Workflow name | Triggered | Device name | API level | Flutter version | Tags | Description |
|--------------|-----------|-------------|-----------|----------------|------|-------------|
| [test android device][test-android-device] | Weekly Mon 06:00 UTC | Pixel 8 Pro (shiba) | 35 | Flutter 3.38.x (stable) | `android && physical_device` | Runs E2E tests on Firebase Test Lab physical devices. Excludes `native_tests/` to reduce test duration. |
| [test android emulator][test-android-emulator] | PR, every 12h | Pixel7 | 36, 35, 34, 33, 32 | Flutter 3.38.x (stable) | `android && emulator` | Runs E2E tests on emulator.wtf emulators across multiple API levels. Excludes `volume_test.dart` due to emulator instability issues. |
| [test android emulator webview][test-android-emulator-webview] | PR, daily at 23:00 | Pixel7 | 31 | Flutter 3.38.x (stable) | `webview && android` | Runs webview-specific E2E tests on emulator.wtf. |
| [test flutter beta channel][test-flutter-beta] | Daily at 8:00, manual | Pixel7 | 35 | Flutter beta | — | Runs smoke test on Flutter beta channel using `example_test.dart` to verify Patrol compatibility with beta Flutter releases. |
| [test locales on android device][test-android-locales] | Every 12h | MediumPhone.arm | 36 | Flutter 3.38.x (stable) | `locale_testing_android` | Tests locale support on Firebase Test Lab for English, French, German, Polish, and Japanese locales. Excludes `web/`, `native_tests/`, and `volume_test.dart`. |

### iOS Testing

| Workflow name | Triggered | Device name | iOS version | Flutter version | Tags | Description |
|--------------|-----------|-------------|-------------|----------------|------|-------------|
| [test ios device][test-ios-device] | Weekly Mon 06:00 UTC | iPhone 16 Pro | 18.3 | Flutter 3.38.x (stable) | `ios && physical_device` | Runs E2E tests on Firebase Test Lab physical devices. Excludes `native_tests/`, `overflow_test.dart`, and specific permission tests (`clear_permissions_test.dart`, `deny_many_permissions_test.dart`, `deny_many_permissions_twice_test.dart`) because camera permissions are not cleared between tests on physical devices. |
| [test ios simulator][test-ios-simulator] | PR only | iPhone 17 | 26.2 | Flutter 3.38.x (stable) | `ios && simulator` | Runs E2E tests on iOS simulator. Triggers on PR for changes to packages, e2e_app, and schema (excludes docs). Excludes `web/` directory, `volume_test.dart`, `service_bluetooth_test.dart`, and permission tests (`clear_permissions_test.dart`, `deny_many_permissions_twice_test.dart`, `permissions_many_test.dart`). Records one MP4 per test case via `patrol test --record-video` (saved to `dev/e2e_app/videos`, uploaded as artifacts with a download link in the job summary) plus simulator logs. Uses xcresultparser to generate JUnit reports and converts them to CTRF format for test reporting. Pins iOS runtime via `--ios 26.2` during `patrol test` and runs with `--full-isolation`. Timeout: 30 minutes. |
| [test ios simulator webview][test-ios-simulator-webview] | Monthly on 1st | iPhone 17 Pro | 26.2 | Flutter 3.38.x (stable) | `webview && ios` | Runs webview-specific E2E tests on iOS simulator (`macos-latest`, 40 min timeout). Uses the same `patrol test --record-video` per-test recording and xcresult → JUnit → CTRF reporting flow as [test ios simulator][test-ios-simulator]. Excludes `web_example_test.dart` and `volume_test.dart`. |
| [test locales on ios device][test-ios-locales] | No | iPhone 16 Pro | 18.3 | Flutter 3.38.x (stable) | `locale_testing_ios` | Tests locale support on Firebase Test Lab for English, French, German (de_DE), Polish, and Japanese locales. Excludes `web_example_test.dart`. Currently disabled for PR triggers. |

### Other Platform Testing

| Workflow name | Triggered | Flutter version | Tags | Description |
|--------------|-----------|----------------|------|-------------|
| [test flutter main channel][test-flutter-main] | Weekly Tue 4:00 UTC, manual | Flutter master | — | Rebases `fix/flutter-patrol-tests` onto `master`, then runs internal tests (`flutter analyze` + `flutter test` on `patrol_finders` and `patrol_cli`) against Flutter main channel. Always creates a PR with test results. Sends Slack notification on failure when triggered by schedule. |
| [test web][test-web] | No | Flutter 3.38.x (stable) | — | Runs web-specific E2E tests on Chrome in headless mode. Triggers on PR for web-related changes. Uses target file instead of tags. |
| [test macos][test-macos] | PR, daily at 00:00 UTC | Flutter 3.38.x (stable) | — | Runs E2E tests on macOS desktop platform. Triggers on PR for changes to packages, e2e_app, and schema (excludes docs). Runs tests from `patrol_test/macos` directory. Uses xcresultparser to generate JUnit reports and converts them to CTRF format for test reporting. |
| [test patrol develop][test-patrol-develop] | PR (opened/synchronize on package, e2e_app, and schema changes; excludes docs), manual | Flutter 3.38.x (stable) | — | Tests `patrol develop` command on Linux (Android emulator, API 34) and macOS (iOS simulator: iPhone 17 on iOS 26.2). The macOS job pins simulator runtime and passes `--ios 26.2` to `patrol_develop_test.dart` to keep xcode destination selection deterministic. Timeout: 30 minutes per job. |

## Package Preparation (CI) Workflows

| Workflow name | Triggered | Dart/Flutter version | Description |
|--------------|---------|---------------------|-------------|
| [patrol prepare][patrol-prepare] | PR (on patrol package changes), manual | Flutter 3.38.x (stable) | Runs CI checks for the `patrol` package: Android builds (Windows/Linux), Darwin code formatting (swift-format, clang-format), Flutter tests, analyzer, formatter, schema regeneration, and a [pana][pana-score-action] pub.dev score check (non-blocking). |
| [patrol_cli prepare][patrol_cli-prepare] | PR (on patrol_cli changes), manual | Flutter 3.38.x (stable) | Runs CI checks for `patrol_cli` package on Ubuntu and Windows: builds executable, runs tests, analyzer, formatter, pub publish dry-run, and a [pana][pana-score-action] pub.dev score check (non-blocking). |
| [patrol_finders prepare][patrol_finders-prepare] | PR (on patrol_finders changes), manual | Flutter 3.38.x (stable) | Runs CI checks for `patrol_finders` package: tests, analyzer, formatter, pub publish dry-run, and a [pana][pana-score-action] pub.dev score check (non-blocking). |
| [patrol_log prepare][patrol_log-prepare] | PR (on patrol_log changes), manual | Flutter 3.38.x (stable) | Runs CI checks for `patrol_log` package: analyzer, formatter, pub publish dry-run, and a [pana][pana-score-action] pub.dev score check (non-blocking). |
| [patrol_devtools_extension prepare][patrol_devtools_extension-prepare] | PR (on devtools extension changes), manual | Flutter 3.38.x (stable) | Runs CI checks for DevTools extension: tests, analyzer, formatter, and builds extension. |
| [adb prepare][adb-prepare] | PR (on adb package changes), manual | Dart 3.8 | Runs CI checks for `adb` package: tests, analyzer, formatter, pub publish dry-run, and a [pana][pana-score-action] pub.dev score check (non-blocking). |
| [prepare e2e_app][prepare-e2e_app] | PR (on all changes except docs), manual | Flutter 3.38.x (stable) | Runs CI checks for E2E test app: Android builds (Windows/Linux) with ktlint, iOS builds with swift-format/clang-format and unit tests, Flutter tests, analyzer, and formatter. |
| [patrol_gen prepare][patrol_gen-prepare] | PR (on patrol_gen changes), manual | Dart 3.8 | Runs CI checks for patrol contracts generator: analyzer and formatter. |
| [patrol_mcp prepare][patrol_mcp-prepare] | PR (on patrol_mcp changes), manual | Dart (stable) | Runs the MCP server checks on Ubuntu and Windows against the newest and floor `patrol_cli` (from pub.dev): a smoke test (starts, handshakes, shuts down on stdin EOF), unit tests (`dart test`), and a [pana][pana-score-action] pub.dev score check (non-blocking). The floor run guards against a stale `patrol_cli` constraint. |
| [patrol_mcp cli-compat][patrol_mcp-cli-compat] | PR (on patrol_cli `lib/` or pubspec changes), manual | Flutter 3.38.x (stable) | Non-blocking: builds `patrol_mcp` against the PR's local `patrol_cli` and warns (annotation + job summary, never fails CI) if the barrel API it consumes broke. |

Package-level `pana` scoring only runs for packages published to pub.dev (`patrol`, `patrol_cli`, `patrol_finders`, `patrol_log`, `adb`, `patrol_mcp`) — `patrol_devtools_extension` and `patrol_gen` set `publish_to: none` and are skipped. Each of those prepare workflows has a dedicated `pana-score` job that runs the [pana-score][pana-score-action] composite action from `leancodepl/mobile-tools`, which scores the package the same way pub.dev would, publishes a `pana (<package>)` commit status, and writes a Markdown breakdown to the job summary. The step uses `continue-on-error: true` so a low score is informational and never blocks the PR.

## Publishing Workflows

| Workflow name | Triggered | Description |
|--------------|---------|-------------|
| [patrol publish][patrol-publish] | Tag push (`patrol-v*`) | Publishes `patrol` package to pub.dev. Builds DevTools extension before publishing. Sends Slack notification for releases. |
| [patrol_cli publish][patrol_cli-publish] | Tag push (`patrol_cli-v*`) | Publishes `patrol_cli` package to pub.dev. Verifies version consistency. Sends Slack notification for releases. |
| [patrol_finders publish][patrol_finders-publish] | Tag push (`patrol_finders-v*`) | Publishes `patrol_finders` package to pub.dev. Sends Slack notification for releases. |
| [patrol_log publish][patrol_log-publish] | Tag push (`patrol_log-v*`) | Publishes `patrol_log` package to pub.dev. Sends Slack notification for releases. |
| [adb publish][adb-publish] | Tag push (`adb-v*`) | Publishes `adb` package to pub.dev. |

### PR-Triggered Workflows with Secrets

These workflows run on `pull_request_target`, which has access to secrets:
- [test android emulator][test-android-emulator]
- [test android emulator webview][test-android-emulator-webview]

Their `access` job runs the emulator job only for PRs whose branch lives in this repository (`head.repo == github.repository`). A fork PR does not fail: its `run_tests` is skipped and the gate passes, so the PR is not blocked. To exercise a fork PR on emulator.wtf, a maintainer runs it from an in-repo branch. Re-running the fork PR does not help, because the trust check is on the head repository, not on the actor who triggered the run.

## Semver Check Workflows

| Workflow name | Runs on | Description |
|--------------|---------|-------------|
| [patrol check semver][patrol-check-semver] | PR (on patrol package changes) | Verifies semantic versioning compliance for `patrol` package changes. |
| [patrol_finders check semver][patrol_finders-check-semver] | PR (on patrol_finders changes) | Verifies semantic versioning compliance for `patrol_finders` package changes. |
| [patrol_log check semver][patrol_log-check-semver] | PR (on patrol_log changes) | Verifies semantic versioning compliance for `patrol_log` package changes. |

## Documentation Workflows

| Workflow name | Runs on | Description |
|--------------|---------|-------------|
| [Vercel Production Deployment][docs-production] | Push to master (on docs changes) | Deploys documentation to Vercel production environment. Uses Node.js 24. Runs Vercel CLI steps from the repository root so the Vercel project root resolves to `docs_app`. |
| [Vercel Preview Deployment][docs-preview] | PR (on docs changes) | Deploys documentation preview to Vercel with stable PR-specific alias. Comments preview URL on PR. Uses Node.js 24. Runs Vercel CLI steps from the repository root so the Vercel project root resolves to `docs_app`. |

## Utility Workflows

| Workflow name | Triggered | Description |
|--------------|---------|-------------|
| [Verify Version Compatibility][verify_compatibility] | PR/push (on compatibility checker changes) | Runs compatibility tests and verifies compatibility tables are up-to-date. |
| [check skills][check-skills] | PR (on `skills/`, `.agents/skills/`, `.claude/skills`, or script changes), manual | Validates the agent-skills setup via `tool/check_skills.sh`: the `.claude/skills` symlink resolves to `.agents/skills`, and every `SKILL.md` has valid frontmatter (`name` matches its folder and is kebab-case, plus a non-empty `description`). |
| [send slack message][send-slack-message] | Reusable workflow | Reusable workflow for sending test results notifications to Slack. Invoked by test workflows; the Slack step runs only when `github.event_name == 'schedule'` in the **caller** workflow (so scheduled cron runs notify; PR, push, `workflow_dispatch`, and other triggers do not). |
| [_relevant][_relevant] | Reusable workflow | Reusable `changes` job. Takes a dorny/paths-filter `filters` block and outputs `relevant` ('true' when a PR touches those paths, or on any non-PR event). Used by every mandatory workflow's `changes` job so the paths-filter logic is defined once. The two emulator.wtf workflows keep an inline `access` job instead (it also enforces the fork trust boundary, running the emulator job only for in-repo branches so secrets never reach fork code). |
| [label pull request][label_pull_request] | All PRs | Automatically labels PRs based on changed files. |
| [Add prioritized issues to project][add-to-project] | Issue labeled (P0, P1, P2) | Automatically adds prioritized issues to GitHub project board. |
| [Potential Duplicates][potential-duplicates] | Issue opened/edited | Automatically detects and labels potential duplicate issues using similarity threshold. |
| [close inactive issues][close-inactive-issues] | Schedule (hourly), issue comment | Closes issues labeled "waiting for response" after 7 days of inactivity. |
| [lock closed issues][lock-closed-issues] | Schedule (hourly) | Locks closed issues after 7 days of inactivity. |

## Schedule Summary

- **Every 12 hours**: [test android emulator][test-android-emulator], [test locales on android device][test-android-locales]
- **Weekly (Monday 06:00 UTC)**: [test android device][test-android-device], [test ios device][test-ios-device]
- **Daily at 00:00 UTC**: [test macos][test-macos]
- **Daily at 23:00 UTC**: [test android emulator webview][test-android-emulator-webview]
- **Weekly (Tuesday 04:00 UTC)**: [test flutter main channel][test-flutter-main]
- **Daily at 10:00 UTC**: [test flutter beta channel][test-flutter-beta]
- **Monthly (1st day)**: [test ios simulator webview][test-ios-simulator-webview]
- **Hourly**: [close inactive issues][close-inactive-issues], [lock closed issues][lock-closed-issues]

## Notes

- Most test workflows run on Flutter 3.38.x from the stable channel
- Test workflows use various testing services:
  - Firebase Test Lab (FTL) for Android/iOS physical devices
  - emulator.wtf for Android emulators
  - Local simulators/emulators for iOS/Android simulator tests
- Test workflows that call the reusable [send slack message][send-slack-message] workflow only post to Slack when the **caller** was started by a `schedule` event (see workflow `if` on the Slack step)
- All publish workflows require tag pushes with specific prefixes and send Slack notifications for non-prerelease versions
- Documentation deployments use Vercel with Node.js 24. The docs workflows copy `docs/` into `docs_app/docs`, then run Vercel CLI commands from the repository root so Vercel's configured `docs_app` root is not applied twice.
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
- Physical device workflows ([test android device][test-android-device], [test ios device][test-ios-device]) exclude the entire `patrol_test/native_tests/` directory to reduce test duration on expensive cloud testing infrastructure
- This is configured using the `--exclude` flag: `--exclude=patrol_test/web/,patrol_test/native_tests/,patrol_test/volume_test.dart`

<!-- Link definitions -->
[test-android-device]: workflows/test-android-device.yaml
[test-android-emulator]: workflows/test-android-emulator.yaml
[test-android-emulator-webview]: workflows/test-android-emulator-webview.yaml
[test-android-locales]: workflows/test-android-locales.yaml
[test-flutter-beta]: workflows/test-flutter-beta.yaml
[test-flutter-main]: workflows/test-flutter-main.yaml
[test-ios-device]: workflows/test-ios-device.yaml
[test-ios-simulator]: workflows/test-ios-simulator.yaml
[test-ios-simulator-webview]: workflows/test-ios-simulator-webview.yaml
[test-ios-locales]: workflows/test-ios-locales.yaml
[test-web]: workflows/test-web.yaml
[test-macos]: workflows/test-macos.yaml
[test-patrol-develop]: workflows/test-patrol-develop.yaml
[patrol-prepare]: workflows/patrol-prepare.yaml
[patrol_cli-prepare]: workflows/patrol_cli-prepare.yaml
[patrol_finders-prepare]: workflows/patrol_finders-prepare.yaml
[patrol_log-prepare]: workflows/patrol_log-prepare.yaml
[patrol_devtools_extension-prepare]: workflows/patrol_devtools_extension-prepare.yaml
[adb-prepare]: workflows/adb-prepare.yaml
[prepare-e2e_app]: workflows/prepare-e2e_app.yaml
[patrol_gen-prepare]: workflows/patrol_gen-prepare.yaml
[patrol_mcp-prepare]: workflows/patrol_mcp-prepare.yaml
[patrol_mcp-cli-compat]: workflows/patrol_mcp-cli-compat.yaml
[patrol-publish]: workflows/patrol-publish.yaml
[patrol_cli-publish]: workflows/patrol_cli-publish.yaml
[patrol_finders-publish]: workflows/patrol_finders-publish.yaml
[patrol_log-publish]: workflows/patrol_log-publish.yaml
[adb-publish]: workflows/adb-publish.yaml
[patrol-check-semver]: workflows/patrol-check-semver.yaml
[patrol_finders-check-semver]: workflows/patrol_finders-check-semver.yaml
[patrol_log-check-semver]: workflows/patrol_log-check-semver.yaml
[docs-production]: workflows/docs-production.yaml
[docs-preview]: workflows/docs-preview.yaml
[verify_compatibility]: workflows/verify_compatibility.yml
[send-slack-message]: workflows/send-slack-message.yaml
[_relevant]: workflows/_relevant.yaml
[label_pull_request]: workflows/label_pull_request.yaml
[add-to-project]: workflows/add-to-project.yaml
[potential-duplicates]: workflows/potential-duplicates.yaml
[close-inactive-issues]: workflows/close-inactive-issues.yaml
[lock-closed-issues]: workflows/lock-closed-issues.yaml
[check-skills]: workflows/check-skills.yaml
[pana-score-action]: https://github.com/leancodepl/mobile-tools/tree/master/.github/actions/pana-score
