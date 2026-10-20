---
name: patrol-migrate-from-maestro
description: Migrate a Flutter app's Maestro UI flows (`.yaml`) to Patrol end-to-end tests — inventory the flows, translate each command to Patrol, replace text and relative selectors with widget keys, move JS scripts and hooks to Dart, and prove every migrated test green before the next one. Use when a project has a `maestro/` (or `.maestro/`) directory and the user wants those flows in Patrol.
---

# Migrate Maestro flows to Patrol

A migration is done when every Maestro flow has a Patrol test that **proves the same
behavior** and **passes on a device**. A line-by-line translation of the YAML is not
the goal: Maestro drives an installed app from outside, through the accessibility
tree; Patrol runs inside the app and finds Flutter widgets. Selectors, waits and
platform workarounds written for Maestro mostly disappear.

Companion skills — load them if installed, they own their topics:

- `patrol-setup` — first-time Patrol setup, when the project has none.
- `patrol-write-test` — Patrol API, assertion, native-dialog and test-key rules. They
  apply here, except for the points listed in *Rules that change for a migration*.
- `patrol-test-architecture` — add-on to `patrol-write-test` for the modular layout
  (`Modules`, `System`, `ApiClients`).

The command-by-command mapping is in [references/command-mapping.md](references/command-mapping.md).
Read it before translating the first flow.

## Hard rules

- **Never modify app behavior.** In app code, the only change allowed is adding a
  `key:` to an existing widget, plus the keys files. No new widgets, no refactors, no
  new `Semantics`, no deleting `Semantics` or labels that Maestro needed. Build
  configuration Patrol needs is allowed: the pubspec, the native test runner wiring,
  and the Kotlin / Android Gradle plugin / Gradle versions Patrol requires. A key that
  is not `const` forces dropping `const` from the widget that takes it — that edit is
  part of adding the key.
- **Format only the files you created.** Running the formatter over `lib/` rewrites
  files you never touched when the project uses an older formatter style.
- **Never delete or edit the Maestro flows.** They are the specification. Removing
  them is the user's call once the Patrol suite is green.
- **Never drop an assertion or a step silently.** Every `assert*` becomes an
  assertion. A step with no Patrol equivalent gets a `// TODO(maestro: <command>)`
  marker and goes in the final report. A flow that ends without an assertion gets one
  that proves its effect, listed in the report as added.
- **One flow at a time.** Translate, run, get it green, then start the next flow.
- **Never weaken a test to make it pass** — no deleted assertions, no `try`/`catch`
  around a failing step, no `skip`. If it fails, find out why (see Debugging).

## Rules that change for a migration

The Maestro flow is the specification, so where `patrol-write-test` or
`patrol-test-architecture` say otherwise, these win:

- `onFlowComplete` becomes a `patrolTearDown`, even though those skills say not to
  write teardowns on your own. The teardown is registered in `main()`, outside
  `testApp`, so it builds its own clients (`BackendClient()`,
  `PlatformAutomator(config: ...)`) and the test file imports `package:patrol`.
- A mid-flow `assertVisible` stays in the middle of the test, where the flow has it.
- `assertNotVisible` needs `expect` and `findsNothing`, which `package:patrol` does not
  export: `import 'package:flutter_test/flutter_test.dart' show expect, findsNothing;`.
- Text finders are allowed for two things: asserting content the flow asserts by text
  (an item name the test created, a message), and tapping widgets the app does not
  build itself, which cannot take a key without changing the app — the buttons of
  `showDatePicker` and `showTimePicker`, and the items of an open dropdown menu.
  Scope them when the text is ambiguous: `$(DatePickerDialog).$('OK')` (the widget
  types come from `package:flutter/material.dart`).

## 1. Inventory

Read everything before writing code:

1. Every flow file and `config.yaml` in the Maestro directory, including nested
   directories and subflows referenced by `runFlow: file:`.
2. Every `runScript` / `evalScript` JS file — these are backend setup and teardown.
3. How flows are run: CI config, shell scripts, the README. Note `--include-tags`,
   `--exclude-tags`, `-e` env vars and per-platform install scripts — they decide
   which flows run on which platform.
4. `lib/main.dart` — everything `main()` does before `runApp` (Firebase init, DI,
   env loading) is what the Patrol test must do before pumping the app.
5. Existing Patrol or `integration_test` code, and any existing keys files. If a test
   structure already exists, follow it.

Write a migration table and show it to the user before step 2. When nobody is there
to answer, put it in the report and continue.

| Maestro flow | Patrol test | Platforms | Setup / teardown | Native interactions | Keys to add |
|---|---|---|---|---|---|

The Platforms column comes from tags plus how CI runs the flows, not from the flow
alone. Comments in flows (`# not available on iOS`, `# index was not needed on
Android`) explain workarounds — keep them in mind when translating.

## 2. Set up Patrol

If the project has no Patrol setup, run the `patrol-setup` skill first. The `example/`
directory of the `patrol` package in the pub cache has a working native setup for the
installed version. Take the `patrol:` block values from the flows: `appId` is the
Android `package_name` and the iOS `bundle_id` (check `applicationId` and the bundle id
in the native projects — a flow's `appId` can be a flavor's id).

Maestro-only projects often have an Android toolchain older than Patrol supports. The
Gradle error names what is missing: `Could not find method compilerOptions()` means the
Kotlin Gradle plugin (`org.jetbrains.kotlin.android` in `android/settings.gradle(.kts)`)
is too old; AGP and Gradle errors state the minimum version. Expect a chain — each fixed
version lets the build reach the next error, often Kotlin, then AGP, then the Gradle
wrapper. Raise only what each error asks for, and list every version change in the
report. A cold first build takes minutes; run it in the background.

Values the flows read from `env:` blocks or `-e`, and credentials or account names
written into the flows, go to `.patrol.env` and are read with `String.fromEnvironment`.
Gitignore `.patrol.env` and the generated `patrol_test/test_bundle.dart`.

## 3. App start helper

Write one helper that starts the app the way `main()` does: the same initialization,
then `await $.pumpWidgetAndSettle(const MyApp())`. Every test calls it first. This is
the Patrol `launchApp`. Initialization that may run only once per process needs a
guard (`if (Firebase.apps.isEmpty)`): on iOS all tests run in one app process.

Setup that runs before the app starts often needs the same initialization (a backend
call through the app's Firebase repository). Split the helper: one guarded `init` that
setup and teardown can call, and one that runs it and pumps the app.

With no existing Patrol code and `patrol-test-architecture` installed, use its layout:
create `Module`, `Modules`, `System` and `ApiClients` from that skill's examples before
the first test, and this wrapper next to the start helper:

```dart
void testApp(
  String description,
  Future<void> Function(
    PatrolIntegrationTester $,
    Modules modules,
    System system,
    ApiClients apiClients,
  ) callback,
) {
  patrolTest(description, ($) async {
    final system = System(config: PlatformAutomatorConfig.defaultConfig());
    await callback($, Modules($), system, ApiClients());
  });
}
```

State does not carry over between tests: on Android, `clearPackageData` wipes app data
before every test. Each test sets up its own state, so a flow that relied on state
left by an earlier flow needs that state created in its own setup.

## 4. Migrate one flow

1. Walk the flow and, for every element it touches inside the app, find the widget
   in the code. Add a key to it (key rules: `patrol-write-test` /
   `patrol-test-architecture`). Text taps, `id:`, `index:`, `rightOf:`, `below:`,
   `childOf:` and `point:` on in-app UI all become keys. A widget whose label changes
   with state ("Login" / "Logout") gets one key per state, chosen by the same
   condition.
2. Translate the commands with [references/command-mapping.md](references/command-mapping.md).
   `tapOn` a field followed by `inputText` is one `enterText`.
3. A flow that runs on one platform only gets a guard in `main()`:
   `if (Platform.isAndroid) { testApp(...); }`.
4. Move `onFlowStart` / `runScript` setup into the test body, before the app starts,
   and `onFlowComplete` into a `patrolTearDown` registered in `main()`. Write the
   JS HTTP calls in Dart, reusing the app's own repositories or API clients when
   they already do the call. Cleanup must succeed when there is nothing to delete,
   and must wait for data the app wrote through its own SDK: the test can see it in
   the app before the backend has it. `patrolTearDown` has no `$`: for native calls
   there, use `PlatformAutomator(config: PlatformAutomatorConfig.defaultConfig())` —
   `PlatformAutomator()` without a config throws `UnimplementedError` on every call.
5. Put assertions where the flow has them; the final `assertVisible` becomes a
   `waitUntilVisible()` at the end.
6. Run the test until it is green (see *Running tests*).
7. If the project uses modules, move the new code into them and rerun.

### What disappears in translation

- **Platform branches that exist because of selectors.** `runFlow: when: platform:`
  blocks with different selectors for Android and iOS (an `index:` on one platform,
  `rightOf:` on the other) collapse into one key. Keep a `Platform.isIOS` branch only
  for behavior that really differs.
- **Waits.** `waitForAnimationToEnd`, `extendedWaitUntil` before a tap, and
  `hideKeyboard` before a tap are not needed: Patrol waits for the widget before
  acting.
- **`optional: true`.** Decide whether the element appears in the test environment.
  An optional permission dialog becomes
  `if (await $.platform.mobile.isPermissionDialogVisible()) { ... }`. Any other
  optional step that depends on device state is the user's call; when nobody is there
  to answer, make it mandatory and say so in the report.

### What needs native automation

Patrol finders see only Flutter widgets. These go through `$.platform`, using the
Patrol MCP `native-tree` tool to read the native UI and pick selectors:

- Permission dialogs — `grantPermissionWhenInUse()`, `grantPermissionOnlyThisTime()`,
  `denyPermission()`. Maestro's `launchApp` grants all permissions by default and
  Patrol does not, so a dialog can appear in Patrol where the flow had no step for it.
  These calls throw when no dialog is shown.
- Notifications, quick settings, Wi-Fi / cellular / airplane mode, mock location.
- WebView content and other apps (Google sign-in, browser, share sheet) —
  `$.platform.mobile.tap(MobileSelector(...))`, `$.platform.mobile.waitUntilVisible(...)`.

A tap that opens a native dialog, a WebView, a map, a camera preview or anything that
keeps animating needs `tap(settlePolicy: SettlePolicy.noSettle)`, otherwise the tap
waits for a frame that never settles.

## Running tests

- **One test while developing:** Patrol MCP `run` if it is configured, otherwise
  `patrol test -t <file>`. With more than one device attached, pass `device` (the MCP
  `devices` tool lists them).
- **Patrol MCP `run` is `patrol develop`.** It hot-restarts the app: app data and
  granted permissions stay from the previous run, and `patrolTearDown` may not run.
  `quit` before running a different file — `run` with a new file can rerun the old
  one and report success. Before rerunning a test that needs a fresh install state
  (a permission dialog, a first-launch screen), `quit` and
  `adb shell pm clear <package>`.
- **Proof of a green test is a `patrol test` run**, which installs fresh and clears
  data before every test. Finish with the full suite, twice.
- **On a shared machine**, check that no other test run is using the device before a
  suite run. Another app's instrumentation on the same device kills yours midway and
  the summary silently lists fewer tests.

## 5. Report

When all flows are done, give the user:

- The migration table with a status per flow: green on which platforms, how many
  clean suite runs, and every flow that could not run on the available device (and
  why).
- Every change of meaning: regex asserts that became exact text, `point:` taps that
  became a native API call, `travel` timing, optional steps made mandatory,
  assertions added.
- Every `TODO(maestro: …)` left, every app file changed, every build version raised.
- That the Maestro flows are still in place and can be removed once the user has
  reviewed the suite.

## Debugging

- **Patrol MCP `run` shows no output for minutes.** The build is likely failing.
  Build the test bundle directly to see the error:
  `flutter build apk --debug --target patrol_test/test_bundle.dart`.
- **Finder found nothing.** Take a screenshot (Patrol MCP `screenshot`). If the
  element is off-screen, add `.scrollTo()`. If it is native UI, use `$.platform`.
- **A key matches a widget that cannot be tapped.** A `DropdownButton` builds its
  items both in the button and in the open menu, and a key on `DropdownMenuItem` can
  match the copy that is not hit-testable. Tap the item by its text and remove the
  unused key.
- **Text matches nothing but Maestro found it.** Maestro matches accessibility labels,
  which merge text of a whole subtree (`"Event Type\nConference"`) and include
  `Semantics` labels and tooltips. Find the widget and key it.
- **Test hangs after a tap.** The next screen never settles — use
  `SettlePolicy.noSettle` on that tap.
- **Network errors from the app (`network-request-failed`) only in tests.** Check DNS
  on the device; an emulator started with `-dns-server 8.8.8.8` fixes a stale one.
- **Passes alone, fails in the suite.** State leaked from another test or the backend;
  check the teardown.
- **Only fails on one platform.** Check whether the Maestro flow had a platform branch
  there — it often documents the same platform difference.
