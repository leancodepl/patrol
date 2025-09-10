# Patrol Web MVP Harness

Minimal Playwright harness that:
- Launches Chromium
- Opens the Flutter web app URL
- Calls `window.__patrol_listDartTests()` and `window.__patrol_runDartTest(name)`
- **NEW**: Exposes `patrolNative` binding for Dart→Playwright communication
- Prints results to stdout (MVP)

## Features

### Test Orchestration
- Lists and runs Patrol tests via JS hooks exposed by the Flutter web app
- Handles test lifecycle and result collection

### Native Actions Bridge (POC)
- Exposes `window.patrolNative(requestJson)` for Dart tests to call Playwright APIs
- Currently supports:
  - `grantPermissions`: Grant browser permissions (e.g., geolocation, camera, microphone)
- Easily extensible for more native actions

## Prerequisites
- Node 18+
- `npm i -D playwright`

## Usage

### Basic Test Run
```bash
# 0) Go to `packages/patrol/example` and bundle all the tests. To do so, run `patrol test` command. Bundling tests into `test_bundle.dart` is always a first step so once you'll see that app is being build, stop the execution.
patrol test

# 1) In app repo root, build and serve Flutter web app:
flutter run -d web-server --target integration_test/test_bundle.dart
# Take note of the served URL printed by Flutter (e.g., http://localhost:8080)

# 2) In another terminal, run the harness:
BASE_URL="url returned from flutter run" npx playwright test
```

### Using Native Actions in Tests
In your Dart test files, you can now call:
```dart
import 'package:patrol/src/native/patrol_app_service_web.dart';

// Grant geolocation permissions
final result = await callPlaywright('grantPermissions', {
  'permissions': ['geolocation'],
});
expect(result['ok'], isTrue);
```

## Supported Native Actions
- `grantPermissions`: Grant browser permissions
  - Parameters: `{ "permissions": ["geolocation", "camera", "microphone", ...], "origin"?: "https://..." }`
  - Returns: `{ "ok": true }` or `{ "ok": false, "error": "..." }`
