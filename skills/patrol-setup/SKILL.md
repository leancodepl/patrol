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

Follow the **Setup** steps, deep-linking to the relevant point:

- Add the `patrol` dev dependency and the `patrol:` block in `pubspec.yaml` — https://patrol.leancode.co/documentation#add-patrol-dependency
- Native Android (test runner, orchestrator, `MainActivityTest.java`) — https://patrol.leancode.co/documentation#android-setup
  (Groovy build files: https://patrol.leancode.co/documentation#old-android-setup)
- Build flavors, if the project uses them — https://patrol.leancode.co/documentation#flavors

## 2. Write a first minimal test

Follow **write your first test** for the current API:
https://patrol.leancode.co/documentation/write-your-first-test

Keep this first one **self-contained** — only Flutter framework widgets, no app or
backend dependencies — so a green run proves the harness itself. Place it in
`patrol_test/` (or the configured `test_directory`).

## 3. Ignore the generated files

Gitignore Patrol's generated files (`test_bundle.dart`, `.patrol.env`) per the
**Setup** section: https://patrol.leancode.co/documentation#setup

## 4. Run on an emulator

Boot an Android emulator, wait for boot to complete, then run the one test:

```bash
emulator -list-avds
emulator -avd <avd_name> -no-boot-anim &
adb wait-for-device
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 1; done

patrol test -t patrol_test/example_test.dart -d emulator-5554
```

A green single test confirms the setup.

## Gotchas

- **The whole test bundle must compile** — one broken file in the test directory
  blocks *all* tests ("No tests were found"). Run `flutter analyze <test_directory>`
  before running.
- **`MainActivity` cannot be resolved (Java)** — set the `MainActivityTest.java`
  `package` to the app's `applicationId`.
- **Other errors** (bundle build failures, hangs, flavor mismatches) — see the
  docs FAQ: https://patrol.leancode.co/documentation#faq

## Next: Patrol MCP (optional)

Once the setup is green, mention to the user that **Patrol MCP** exists and can be
set up on request — it lets an AI agent run tests, capture screenshots, read the
native UI tree, and drive an interactive session. Let the user decide; if they
want it, follow the README: https://pub.dev/packages/patrol_mcp
