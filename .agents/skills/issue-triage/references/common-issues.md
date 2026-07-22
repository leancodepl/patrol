# Patrol issue catalog — recurring problems and how to triage them

A shortlist of the issues that **actually recur**, mined from a year+ of resolved reports.
Match a new issue here first; a hit usually gives you the verdict, the one confirmation step,
and a canned reply. This is deliberately *not* a 1:1 archive — only frequent patterns. Keep it
that way.

Doc anchors used in replies (paste the exact one — the team does this):
- Setup overview — https://patrol.leancode.co/documentation
- Add dependency — https://patrol.leancode.co/documentation#add-patrol-dependency
- Android setup — https://patrol.leancode.co/documentation#android-setup
- Android setup (Groovy) — https://patrol.leancode.co/documentation#old-android-setup
- Flavors — https://patrol.leancode.co/documentation#flavors
- FAQ — https://patrol.leancode.co/documentation#faq
- **Compatibility table** — https://patrol.leancode.co/documentation/compatibility-table

---

## Quick symptom → likely verdict

| Symptom in the report | Start from | Card |
|---|---|---|
| `NativeAutomatorClientException`, "Connection refused … /initialize", native not working | User issue | A1 |
| `:app:connectedDebugAndroidTest FAILED`, "Starting 0 tests", "Process crashed", code 1 | User issue (env) | A2 |
| iOS `xcodebuild exited with code 65` (or 70) | User issue (env) | A3 |
| App/data not removed between runs (esp. iOS) | User issue / by-design | A4 |
| Ran `flutter test …` (not `patrol test`) | User issue | A5 |
| Fails only on one physical device / OEM skin; green elsewhere | User issue | A6 |
| Stack trace points into app packages (`get_it`, DI, their `main()`) | User issue | A7 |
| CI OOM `Java heap space`; CLI never terminates on Firebase Test Lab | User issue (CI) | A8 |
| Invalid import inside generated `test_bundle.dart` | **Patrol bug** | B1 |
| `enterText()` works in first field, fails in focused/autofocus field | **Patrol bug** | B2 |
| iOS "Could not launch RunnerUITests", `OSStatus -10661`, runs on macOS | **Patrol bug**/Xcode | B3 |
| Permission dialog not detected (non-English locale) | **Patrol bug**/gap | B4 |
| Useless failure message ("Multiple exceptions", "Bad state") | **Patrol bug** | B5 |
| `/` or odd char in test name → instrumentation crash | Duplicate → #1839 | D1 |
| `patrol develop` "Bad state: Stream has already been listened to" | Duplicate → #1748 | D2 |
| Native tap on web/webview submit button doesn't click | Duplicate → #244 | D3 |
| `at(0)`/`first`/`last` picks invisible widget / doesn't wait | Duplicate → #1938 | D4 |
| `scrollTo` throws "no visible (hit-testable) widgets" | By-design (not a bug) | C1 |
| "add native X()", "support for X", `### Use case`/`### Proposal` | Feature | — |
| Thin report: no versions/logs/repro, placeholder blocks, screenshots-of-text | Information needed | see below |

---

## Required-info checklist (drives the "Information needed" verdict)

Maintainers can't act without these; their absence is the finding. Ask only for what's missing:

1. **Version triple** — `patrol`, `patrol_cli`, `flutter` — checked against the compatibility table.
2. **`patrol doctor`** output.
3. **A minimal, reproducible public repo** (or a repro against `dev/e2e_app`). The single most-requested item.
4. **`--verbose` run logs** (as text, not screenshots).
5. **`adb logcat`** for Android: `adb logcat -T 1 > adblog.txt` in one terminal, `patrol test …` in another, stop after failure, attach the file.
6. **Device vs emulator + OS/API level** — the answer often *is* the bug (Android API 35/36).
7. **Native config** for Android build failures: `android/app/build.gradle`, `MainActivityTest.java`.
8. **"Does plain `flutter run` build/launch?"** — isolates Patrol from a broken app/toolchain.
9. **CI workflow file** for CI-only failures.

**Under-specified tells:** placeholder template blocks left in (`<!-- Replace this line … -->`);
"Steps to reproduce: none"; logs only as screenshot/pastebin; private/commercial app "can't
share"; feature body that just restates the title; env fingerprints (Windows paths, "Apple
Silicon", CI-only) with no local repro; "it used to work" with no diff of what changed.

---

## A — User-issue signature cards (setup / environment / app-side)

### A1 — patrol ↔ patrol_cli version mismatch  ·  *#1 user-error cause*
- **Symptom:** `NativeAutomatorClientException`, "Connection refused … /initialize", native automator never initializes.
- **Confirm:** the pubspec `patrol` + installed `patrol_cli` pair violates the compatibility table.
- **Verdict:** User issue.
- **Reply:** "Looks like a version mismatch. Please check your versions against the [compatibility table](https://patrol.leancode.co/documentation/compatibility-table) and share `patrol doctor` output."

### A2 — `:app:connectedDebugAndroidTest` fails / "0 tests" / "Process crashed"  ·  *most frequent Android*
- **Symptom:** APK builds, then `Task :app:connectedDebugAndroidTest FAILED`, "Starting 0 tests", or "Instrumentation run failed due to Process crashed."
- **Usual causes (all env):** emulator **API 35/36** incompatibility (works on API 34/31); wrong `MainActivityTest.java` package or `instrumentation.setUp` activity class; stale Gradle state; physical-device quirk.
- **Confirm:** ask API level + physical/emulator; ask for `adb logcat`; try on API 34.
- **Verdict:** User issue (env). If it also fails in `dev/e2e_app` on a normal emulator → escalate to possible Patrol bug.
- **Reply (clean-build incantation):** `cd android && ./gradlew :clean && ./gradlew --stop && cd .. && rm -rf build ~/.gradle/caches && flutter clean && flutter build apk`, then retry; if only API 35/36 fails, note it and drop to API 34.

### A3 — iOS `xcodebuild exited with code 65` (or 70)
- **Symptom:** `Failed to build app with entrypoint test_bundle.dart for iOS simulator (xcodebuild exited with code 65)`.
- **Usual causes (env):** code-signing (65/70 are signing-related); stale caches; **manual setup mistake** — command line pasted into the wrong field of the Xcode `Run Script` build phase.
- **Confirm:** does plain `flutter run` build? Check the Runner UITest build-phase script field.
- **Verdict:** User issue (env). (Contrast B3, which is a Patrol/Xcode launch bug, not a build failure.)
- **Reply:** "Remove `flutter/bin/cache`, run `flutter doctor`, then `flutter build ios --config-only <target>` + `pod install --repo-update`, and run with `-d 'iPhone 16 Pro'`. Codes 65/70 are usually code-signing."

### A4 — App/data not removed between test runs (esp. iOS)
- **Symptom:** login/permissions persist across runs; app not uninstalled.
- **Verdict:** User issue / by-design. iOS has no API to auto-delete the app between runs. When uninstall genuinely fails, it's a **wrong/missing `bundle_id`/`package_name`** in the pubspec `patrol:` section.
- **Reply:** Android — add `testInstrumentationRunnerArguments clearPackageData: 'true'`. iOS — expected; verify `bundle_id` matches the Runner target.

### A5 — Used `flutter test` instead of `patrol test`
- **Symptom:** hangs/errors at load, native never initializes; the pasted command is `flutter test …`.
- **Verdict:** User issue.
- **Reply / triage question:** "Is this successful using the `patrol test` command? Native automation only runs under `patrol test`/`patrol develop`."

### A6 — Physical-device / OEM-skin-only failure
- **Symptom:** reporter's own matrix is green on emulator/simulator/Firebase Test Lab and other phones, red only on one device (Samsung One UI, etc.).
- **Verdict:** User issue (device-specific). Ask them to retry on newest patrol/cli; if unreproducible, "looks like a config/device issue."

### A7 — App-side / third-party exception surfaced through Patrol
- **Symptom:** test crashes on an exception that isn't Patrol's (e.g. `Type X is already registered inside GetIt` on the 2nd test); "first test passes, the rest fail".
- **Confirm:** stack trace lands in app packages or the reporter's `main()`. "First passes, rest fail" == app state/singletons not reset between relaunches.
- **Verdict:** User issue (app bug).

### A8 — CI-environment failures (Codemagic / Firebase Test Lab / GitLab)
- **Symptoms:** OOM `Java heap space` during `patrol build android`; Android tests won't run; **CLI never terminates → Firebase Test Lab times out**; farm plumbing errors (DDMLIB, `AndroidDevicePlugin`).
- **Usual causes (env):** machine memory; a **race** where a slow box starts building before `gradlew` is generated; farm config.
- **Reply:** set `org.gradle.jvmargs=-Xmx8G` (or `JAVA_TOOL_OPTIONS: -Xmx5g` on Codemagic); run `flutter build apk --config-only` before the patrol step; update to latest patrol/cli. "Running Patrol on raw CI machines is hard — we recommend device farms."
- **Note:** the CLI-not-terminating case was a genuine bug fixed in a later release — check versions before deflecting.

---

## B — Patrol-bug signature cards (real framework defects)

### B1 — Malformed generated `test_bundle.dart` import
- **Symptom:** build fails at `compileFlutterBuildDebug`/`kernel_snapshot`; generated `test_bundle.dart` has an invalid import, e.g. `import 'C:/…/foo_test.dart' as C:__…;` → "Expected ';' after this" / "StandardFileSystem only supports file:* and data:* URIs".
- **Confirm:** open the generated `test_bundle.dart` — the import path/alias is literally broken. Triggered by Windows drive letters, custom `test_directory` under `test/`, or absolute `-t` paths.
- **Package:** `patrol_cli` (`test_bundler.dart`). **Verdict:** Patrol bug. (Precedent #1814, #2835, #3021; Windows fix #3117.)

### B2 — `enterText()` regression on focused / autofocus field
- **Symptom:** text enters the first field only; a focused/autofocus/second field silently gets nothing; on Android the autofocus keyboard won't dismiss and covers widgets.
- **Confirm:** two fields or an `autofocus: true` field; first works, focused one fails.
- **Package:** `patrol_finders`/`patrol`. **Verdict:** Patrol bug (regression). Precedent #2395, #1868, #2502, #2202 — fixed in patrol_finders 2.7.2 / 3.5.0, so **check the reporter's version first** (may already be fixed → "please upgrade").

### B3 — iOS "Could not launch RunnerUITests" / `OSStatus -10661` / runs on macOS
- **Symptom:** "Failed to install or launch the test runner … LaunchServices error -10661"; "Using the first of multiple matching destinations"; test runs on macOS instead of the chosen simulator.
- **Confirm:** non-latest iOS simulator, or Xcode 15; duplicate destinations in the log.
- **Package:** `patrol_cli` (`app_options.dart` `-destination`) + Xcode interaction. **Verdict:** Patrol bug / Xcode regression. Workaround: pin OS via `--ios <version>`. (Distinguish A3, a *build* failure.)

### B4 — Permission dialog not detected in non-English locale
- **Symptom:** `isPermissionDialogVisible()` false though the dialog shows; grant/deny never taps.
- **Verdict:** Patrol gap — iOS matches English-only labels in `Automator.swift`. Configurable non-English texts were accepted as a valid ask. Precedent #1465, #1052.

### B5 — Useless test-failure error messages
- **Symptom:** report shows only "Multiple exceptions were thrown" / "Bad state: No element", no real detail; `print`/exception text not surfaced.
- **Verdict:** Patrol bug (logging). Root cause partly in `flutter_test`, but Patrol worked around it (improved in patrol 3.16). Precedent #951, #1044.

---

## C — Behaviour-by-design (report frames it as a bug; it isn't)

### C1 — `scrollTo` "did not find any visible (hit-testable) widgets"
- Patrol treats **hit-testable == visible**; there's no better signal. Reply: use `$.scrollUntilExists` instead of `scrollTo`, or skip the hit-testable check for non-hit-testable widgets. Precedent #2700, #1043.
- **Other by-design asks (→ feature/wontfix, not bug):** app relaunches between tests (isolation is intentional; before-all/after-all declined — #2601); running tests without installing the app (the app must open once for the Discovery Phase — #2188); `flutter_driver` support (against the architecture — #2548).

---

## D — Duplicate magnets (recommend "Duplicate of #X")

| Card | Canonical | Symptom | Notes |
|---|---|---|---|
| D1 | **#1839** | forbidden character (esp. `/`) in test name → instrumentation crash | highest-recurrence dup; dupes #2285, #2879 |
| D2 | **#1748** | `patrol develop` "Bad state: Stream has already been listened to" | dup #2469 (thread mixes unrelated causes — verify the symptom string) |
| D3 | **#244** | native tap on web-form/webview submit button doesn't click (test still passes) | dup #1159 |
| D4 | **#1938** | `at(0)`/`first`/`last` applies index before `hitTestable()` → picks invisible / doesn't wait | dup #602 |

Always run a search before concluding original: `gh issue list --repo leancodepl/patrol --state all --search "<key error phrase>"`.

---

## E — Out-of-scope / wontfix (team has repeatedly declined)

- Transport-layer rewrite / move to WebSockets / remove `PatrolAppService` — #1664.
- Run UI tests without installing/launching the app — #2188 (Discovery Phase needs one launch).
- Custom/own visibility hit-testing — #1043.
- Native test-suite hierarchy (group → JUnit/XCTest nesting) — #1501 (XCTest/JUnit nesting limits).
- `flutter_driver` support — #2548 (against native-automation architecture).

Common thread: blocked by native-platform limits, or a big risky refactor with no safety net.

---

## F — OS / tool-version regression watchlist (recurs every year)

When a report coincides with a new OS/tool release, suspect a framework-side migration break
rather than user error — and check whether a fix already shipped.

| Trigger | What broke | Ref |
|---|---|---|
| **iOS 18** | Settings-app navigation for `enableDarkMode`/`disableDarkMode` (Developer row moved) | #2393 |
| **Xcode 15** | `-10661` launch failures, wrong destination (runs on macOS) | #2003, #1441 |
| **Android 14 (API 34) physical** | e2e tests fail to execute on some physical devices | #2369 |
| **Android 16 (API 36)** | split-APK / orchestrator install failures | #2891 |
| **Flutter 3.22** | build break via `flutter_gen`/`AppLocalizations` (upstream flutter/flutter#148333) | #1814 |
| **Flutter 3.32** | `FLUTTER_APP_FLAVOR is used by the framework and cannot be set…` — breaks every flavored app | #2614 |

Rule of thumb: iOS-Settings-driven `$.native.*` helpers and `-destination` handling are the
first things to break on a new iOS/Xcode major.
