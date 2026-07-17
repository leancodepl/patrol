---
name: patrol-setup
description: Set up Patrol end-to-end (E2E) testing in a Flutter project for the first time — configure the pubspec `patrol` block, wire native Android, and get a first minimal test passing on an emulator. Use when adding Patrol to a project that does not have it yet.
---

# Patrol setup

Get a first Patrol test passing on an Android emulator. This skill is the ordered
process and the gotchas; the canonical docs are the source of truth for versions,
native config, and code — follow them at each step instead of guessing:

- **Install + native setup** (dependencies, the `patrol:` block, Android, iOS,
  flavors) — https://patrol.leancode.co/documentation
- **Write your first test** — https://patrol.leancode.co/documentation/write-your-first-test

## 1. Configure Patrol

Follow the Install doc, deep-linking to each section:

- `patrol:` block in `pubspec.yaml` — https://patrol.leancode.co/documentation#configure-pubspec
- Native Android (test runner, orchestrator, `MainActivityTest.java`) — https://patrol.leancode.co/documentation#android-setup
  (Groovy build files: https://patrol.leancode.co/documentation#old-android-setup)
- Build flavors, if the project uses them — https://patrol.leancode.co/documentation#flavors

## 2. Write a first minimal test

Add one **self-contained** test (only Flutter framework widgets) so a green run
proves the harness itself, before any app or backend dependencies. Place it in
`patrol_test/` (or the configured `test_directory`):

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

## 3. Ignore the generated bundle

Patrol generates `test_bundle.dart` when it runs. Ignore it by name so it's
covered wherever it lands:

```
# .gitignore
**/test_bundle.dart
.patrol.env
```

## 4. Run on an emulator

Boot an Android emulator, wait for boot to complete, then run the one test:

```bash
emulator -list-avds
emulator -avd <avd_name> -no-boot-anim &
adb wait-for-device
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 1; done

patrol test -t patrol_test/example_test.dart -d emulator-5554
```

The first build is slow (compiles the app + instrumentation APK). A green single
test confirms the setup.

## Gotchas

- **"No tests were found" / bundle won't build** — every file in the test
  directory must compile; run `flutter analyze <test_directory>` (a broken sibling
  test blocks all tests). https://patrol.leancode.co/documentation#faq-test-bundle-error
- **`MainActivity` cannot be resolved (Java)** — set the `MainActivityTest.java`
  `package` to the app's `applicationId`. https://patrol.leancode.co/documentation#android-setup
- **Build hangs during `patrol build` / `patrol test`** —
  https://patrol.leancode.co/documentation#faq-build-stuck
- **Flavor mismatch** — keep `package_name`/`bundle_id` and `flavor` in the
  `patrol:` block aligned with the flavor you launch. https://patrol.leancode.co/documentation#flavors

## Next: Patrol MCP (optional)

Once the setup is green, mention to the user that **Patrol MCP** exists and can be
set up on request — it lets an AI agent run tests, capture screenshots, read the
native UI tree, and drive an interactive session. Let the user decide; if they
want it, follow the README: https://pub.dev/packages/patrol_mcp
