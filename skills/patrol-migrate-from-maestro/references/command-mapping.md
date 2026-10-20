# Maestro → Patrol command mapping

`$` is the `PatrolIntegrationTester`. `keys.x.y` is a key added to the app widget. In
a project with `patrol-test-architecture`, native calls go through `system`, backend
calls through `apiClients`. Check every `$.platform` method against the Patrol version
in the project before using it — the API changes between major versions.

## Flow header

| Maestro | Patrol |
|---|---|
| `appId:` | `patrol:` block in `pubspec.yaml` (`android.package_name`, `ios.bundle_id`) |
| `name:` | the `patrolTest` description |
| `tags:` | the platforms the test runs on — a `Platform.isAndroid` / `Platform.isIOS` guard around the test in `main()`, or `patrolTest(tags: [...])` with `patrol test --tags` when CI selects flows by tag for other reasons |
| `env:` / `-e KEY=value` / `${KEY}` | a line in `.patrol.env`, read with `const String.fromEnvironment('KEY')` |
| `onFlowStart:` | setup at the start of the test body, before the app starts |
| `onFlowComplete:` | `patrolTearDown(() async { ... })` registered in `main()` — it runs even when the test fails |
| `config.yaml` `flows:` / `executionOrder:` | nothing — Patrol runs every test file in the test directory; each test is independent |

## App lifecycle

| Maestro | Patrol |
|---|---|
| `launchApp` | the app start helper: the init `main()` does, then `$.pumpWidgetAndSettle(const MyApp())` |
| `launchApp: clearState: true` | default on Android (`clearPackageData`); nothing to write |
| `launchApp: permissions: { all: allow }` (the Maestro default) | grant each dialog when it appears: `$.platform.mobile.grantPermissionWhenInUse()` |
| `launchApp: permissions: { all: deny / unset }` | default — dialogs appear on first request |
| `launchApp: arguments:` | dart-defines in `.patrol.env`, or the value passed to the app widget in the start helper |
| `stopApp` / `killApp` / relaunch mid-flow | no equivalent inside one test — split the flow into two tests, or set the state through the backend |
| `clearKeychain` | no `$.platform` call — ask the user how the iOS keychain state should be reset |
| `openLink: <url>` | `$.platform.mobile.openUrl('<url>')` |

## Selecting in-app elements

Every in-app selector becomes a widget key.

| Maestro | Patrol |
|---|---|
| `tapOn: "Text"` | `$(keys.feature.widget).tap()` |
| `tapOn: { id: "x" }` | the widget that has `x` as `Semantics(identifier:)` or key — key it and use `$(keys.feature.widget)` |
| `tapOn: { text: "x", index: n }` | key the n-th widget, or use a parameterized key when it comes from a list |
| `tapOn: { rightOf / leftOf / above / below: ... }` | key the target widget |
| `tapOn: { childOf: ... }` / list item containing text | `$(ListTile).containing('item').$(keys.feature.menuButton).tap()`, or a parameterized key built from the item's model |
| `tapOn: { point: "x%, y%" }` on in-app UI | key the widget at that point |
| `tapOn: { point: "x%, y%" }` on native UI | the matching native call (notification, dialog); last resort `$.platform.mobile.tapAt(Offset(x, y))` with 0–1 coordinates |
| `tapOn` + `optional: true` | on a permission dialog: `if (await $.platform.mobile.isPermissionDialogVisible()) { ... }`; otherwise decide whether the element appears in the test environment — mandatory if it does |
| `longPressOn:` | `$(key).longPress()` |
| `doubleTapOn:` | `$.tester.tap(...)` twice, or `$.platform.mobile.doubleTap(selector)` for native UI |
| `tapOn:` with `repeat:` | a Dart `for` loop |

## Text input

| Maestro | Patrol |
|---|---|
| `tapOn: <field>` then `inputText: "x"` | `$(keys.feature.field).enterText('x')` — one call |
| `eraseText` | nothing — `enterText` replaces the field content |
| `inputRandomText` / `inputRandomEmail` / `inputRandomNumber` | generate the value in Dart |
| `copyTextFrom:` + `pasteText` | `final value = $(key).text;` then `enterText(value!)` |
| `hideKeyboard` | nothing, unless the keyboard covers the next widget — then `$.platform.mobile.sendKeyboardEnter()` or tap outside the field |
| `pressKey: Enter` | `$.platform.mobile.sendKeyboardEnter()` |

## Scrolling and gestures

| Maestro | Patrol |
|---|---|
| `scrollUntilVisible: { element: ... }` | `$(key).scrollTo()` (chains: `$(key).scrollTo().tap()`) |
| `scroll` | `$(key).scrollTo()` on the element the flow wanted to reach |
| `swipe:` on in-app UI | `$.tester.drag($(key), const Offset(dx, dy))` and `await $.pumpAndSettle()` |
| `swipe:` on native UI | `$.platform.mobile.swipe(from: Offset(...), to: Offset(...))` |
| pull to refresh | `$.platform.mobile.pullToRefresh()` |

## Assertions and waits

| Maestro | Patrol |
|---|---|
| `assertVisible: "Text"` | `await $('Text').waitUntilVisible()` for content the test checks; `$(keys.x.y).waitUntilVisible()` for UI elements |
| `assertVisible: ".*part.*"` (regex) | `$(RegExp('part')).waitUntilVisible()`, or scope it: `$(ListTile).$(RegExp('part'))` |
| `assertNotVisible:` | `await $.pumpAndSettle();` then `expect($(key), findsNothing);` — import `expect` and `findsNothing` from `package:flutter_test/flutter_test.dart` |
| `assertTrue:` | `expect(...)` on the value |
| `extendedWaitUntil: { visible: ..., timeout: n }` | `$(key).waitUntilVisible(timeout: Duration(milliseconds: n))` |
| `waitForAnimationToEnd` | nothing — Patrol settles after every action |
| `assertWithAI` / `assertNoDefectsWithAI` | a concrete assertion on the widget the prompt describes; ask the user what it should check |
| `takeScreenshot` | nothing — failures are captured by the runner |

## Device and native UI

| Maestro | Patrol |
|---|---|
| `back` / `pressKey: back` | `$.platform.android.pressBack()` (Android only); on both platforms tap the app's back button key |
| `pressKey: home` | `$.platform.mobile.pressHome()` |
| `pressKey: volume up / down` | `$.platform.mobile.pressVolumeUp()` / `pressVolumeDown()` |
| `tapOn: "Allow"` / `"While using the app"` | `$.platform.mobile.grantPermissionWhenInUse()` — throws when no dialog is shown |
| `tapOn: "Only this time"` / `"Allow once"` | `$.platform.mobile.grantPermissionOnlyThisTime()` |
| `tapOn: "Don't allow"` / `"Deny"` | `$.platform.mobile.denyPermission()` |
| tapping a notification | `$.platform.mobile.openNotifications()`, then `$.platform.mobile.tapOnNotificationBySelector(MobileSelector(android: AndroidSelector(textContains: 'Title'), ios: IOSSelector(titleContains: 'Title')))`; on iOS a heads-up banner may need `$.platform.ios.closeHeadsUpNotification()` first |
| `setAirplaneMode: enabled / disabled` | `$.platform.mobile.enableAirplaneMode()` / `disableAirplaneMode()`, or `disableWifi()` + `disableCellular()`; restore in `patrolTearDown` |
| `toggleAirplaneMode` | the explicit enable / disable call |
| `setLocation: { latitude, longitude }` | `$.platform.mobile.setMockLocation(lat, lon)` |
| `travel: { points: [...], speed: }` | `setMockLocation` for each point, with a `Future.delayed` between them long enough for the app to react (seconds, not milliseconds); `$.platform.mobile.stopMockLocation()` in `patrolTearDown` |
| `setOrientation` | no `$.platform` call — check the Patrol docs for the current version |
| `addMedia` + picking from gallery | `$.platform.mobile.pickImageFromGallery(...)` |
| taking a photo | `$.platform.mobile.takeCameraPhoto(...)` |
| WebView content (`tapOn: "Text"` inside a WebView) | `$.platform.mobile.tap(MobileSelector(android: AndroidSelector(text: 'Text'), ios: IOSSelector(label: 'Text')))` |
| `assertVisible` inside a WebView or another app | `$.platform.mobile.waitUntilVisible(MobileSelector(...))` |
| other apps (Google sign-in, browser, share sheet) | `$.platform.android.tap(AndroidSelector(...))` / `$.platform.ios.tap(IOSSelector(...))`, selectors from the Patrol MCP `native-tree` tool |

## Control flow and scripts

| Maestro | Patrol |
|---|---|
| `runFlow: file: sub.yaml` | a helper function, or a module method in the modular architecture |
| `runFlow: when: platform: Android / iOS` | collapse into one path when the branch only worked around a selector; otherwise `if (Platform.isAndroid)` |
| `runFlow: when: visible / notVisible` | decide whether the condition is deterministic in the test; if not, ask the user |
| `repeat: { times / while }` | a Dart loop |
| `retry:` | nothing — fix the flakiness; a retry hides it |
| `runScript: x.js` / `evalScript:` | Dart: the app's repository or API client, or the `http` package, in a backend client class |
| `output.x` shared between script and flow | a local variable in the test (`final id = await backend.createX();`) |
| `startRecording` / `stopRecording` | nothing in the test — video is a runner or device-farm setting |
