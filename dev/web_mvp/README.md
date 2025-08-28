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
# 1) In app repo root, build and serve Flutter web app:
flutter run -d web-server --dart-define=PATROL_APP_SERVER_PORT=8082 --target integration_test/<your_test>.dart
# Take note of the served URL printed by Flutter (e.g., http://localhost:8080)

# 2) In another terminal, run the harness:
node dev/web_mvp/run.js http://localhost:8080
```

### Testing Native Actions (POC)
Try the POC test that demonstrates Dart→Playwright communication:
```bash
# Run the POC test that grants geolocation permissions
flutter run -d web-server --dart-define=PATROL_APP_SERVER_PORT=8082 --target integration_test/patrol_native_poc_test.dart
node dev/web_mvp/run.js http://localhost:8080
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
