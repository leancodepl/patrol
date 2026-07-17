---
name: patrol-setup
description: Set up Patrol end-to-end (E2E) testing in a Flutter project for the first time — configure the pubspec `patrol` block, wire native Android (and iOS), get a first minimal test passing on an emulator, and optionally configure the Patrol MCP server. Use when adding Patrol to a project that does not have it yet, or when setting up `patrol_mcp`.
---

# Patrol setup

Get Patrol E2E testing working in a Flutter project — a first test passing on an
Android emulator — then optionally wire the Patrol MCP server. This skill is the
**ordered process, the decisions, and the gotchas**. Dependency versions, native
configuration, and code samples live in the canonical Patrol docs; read them at
each step so nothing here drifts out of date.

Read these as the source of truth (follow them rather than copying their
contents into the project blind):

- **Install + native setup** — dependencies, the top-level `patrol:` block,
  Android (Kotlin DSL & Groovy), iOS, and flavors:
  https://patrol.leancode.co/documentation
- **Write your first test** — https://patrol.leancode.co/documentation/write-your-first-test
- **Physical iOS device setup** (real devices / Firebase Test Lab) — https://patrol.leancode.co/documentation/physical-ios-devices-setup
- **Patrol MCP server** — https://pub.dev/packages/patrol_mcp

Real E2E scenarios come afterwards (see the `patrol-write-test` and
`patrol-test-architecture` skills).

## 0. Check what already exists first

Many project templates ship most of the wiring. Inspect the project and add only
what is missing:

- `pubspec.yaml` — `patrol` in `dev_dependencies`, and a top-level `patrol:` block.
- `android/app/build.gradle[.kts]` —
  `testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"`.
- `android/app/src/androidTest/.../MainActivityTest.java`.
- `patrol_test/` (or the configured `test_directory`) — existing tests.

Run `flutter analyze <test_directory>` before adding tests — the whole test
bundle must compile for any single test to run.

## 1. Configure Patrol in the project

Add whatever Section 0 found missing, deep-linking straight to that step or
section of the Install doc:

- `patrol:` block in `pubspec.yaml` — https://patrol.leancode.co/documentation#configure-pubspec
- Native Android (test runner, orchestrator, `MainActivityTest.java`) — https://patrol.leancode.co/documentation#android-setup
  (Groovy build files: https://patrol.leancode.co/documentation#old-android-setup)
- Native iOS, when you need iOS runs — https://patrol.leancode.co/documentation#ios-setup
- Build flavors — https://patrol.leancode.co/documentation#flavors

## 2. Write a first minimal test

Add one **self-contained** test (only Flutter framework widgets) so a green run
proves the harness itself, before any app or backend dependencies. Follow **write
your first test** for the current API; a minimal starting point:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('minimal Patrol setup renders a widget on device', ($) async {
    await $.pumpWidgetAndSettle(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Patrol works!'))),
      ),
    );
    expect($('Patrol works!'), findsOneWidget);
  });
}
```

Place it in `patrol_test/` (or the configured `test_directory`).

## 3. Ignore the generated bundle

Patrol generates `test_bundle.dart` when it runs — in the Flutter project root on
patrol_cli >= 4.4, in the test directory on older versions. Ignore it by name so
it's covered in either location:

```
# .gitignore
**/test_bundle.dart
.patrol.env
```

## 4. Run the first test on an emulator

Boot an Android emulator, confirm it's visible, then run the one test:

```bash
emulator -list-avds
emulator -avd <avd_name> -no-boot-anim &
adb wait-for-device
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 1; done

patrol test -t patrol_test/example_test.dart -d emulator-5554
```

The first build is slow (compiles the app + instrumentation APK). A green single
test confirms the setup.

## 5. Patrol MCP setup (optional)

`patrol_mcp` lets an AI agent run Patrol tests, capture screenshots, read the
native UI tree, and drive an interactive session. Add it and register the server
**per the patrol_mcp README** — the source of truth for the launcher script and
per-IDE config: https://pub.dev/packages/patrol_mcp

Two things to get right:

- Point the launcher at the Flutter project root — the subfolder (e.g. `./app`)
  when the app lives in one, or `.` at the repo root.
- **Reset the MCP server after setup**: a newly added server loads at startup, so
  restart or reconnect the IDE/agent and approve the `patrol` server to make its
  tools available.

## Troubleshooting

- **"No tests were found" / bundle won't build** — every file in the test
  directory must compile; run `flutter analyze <test_directory>` (a broken
  sibling test blocks all tests). Bundle error details:
  https://patrol.leancode.co/documentation#faq-test-bundle-error
- **`MainActivity` cannot be resolved (Java)** — set the `MainActivityTest.java`
  `package` to the app's `applicationId` and keep `MainActivity` in that package;
  the folder path under `androidTest/java/` can be anything. See
  https://patrol.leancode.co/documentation#android-setup
- **Build hangs during `patrol build` / `patrol test`** —
  https://patrol.leancode.co/documentation#faq-build-stuck
- **Flavor mismatch** — keep the `package_name`/`bundle_id` and `flavor` in the
  `patrol:` block aligned with the flavor you launch with:
  https://patrol.leancode.co/documentation#flavors
- **No device** — confirm `adb devices` lists the emulator as `device`, and wait
  for `sys.boot_completed == 1`.
- **MCP server missing** — make the launcher executable, point its arg at the
  Flutter project root, enable MCP in the IDE, then restart the agent.
