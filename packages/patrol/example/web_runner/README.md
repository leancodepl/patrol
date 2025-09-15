# Patrol Web Runner

Playwright-based harness integrated into patrol_cli that:
- Launches Chromium
- Opens the Flutter web app URL
- Calls `window.__patrol_listDartTests()` and `window.__patrol_runDartTestWithCallback(name, callback)`
- Exposes `patrolNative` binding for Dart→Playwright communication
- Integrates with patrol test command for web platform

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

### Usage with patrol_cli

The web runner is automatically used when running tests on web platform:

```bash
# Run tests on web (automatically detected)
patrol test --device web-server

# Or specify web explicitly
patrol test --device chrome
```

### Manual Usage (for development)
```bash
# 1) Bundle tests and serve Flutter web app:
flutter run -d web-server --target integration_test/test_bundle.dart

# 2) Run all tests:
BASE_URL="http://localhost:8080" npx playwright test

# 3) Run in develop mode (like 'patrol develop'):
BASE_URL="http://localhost:8080" npm run develop
```

### Develop Mode
The develop mode (`npm run develop`) provides an interactive development experience similar to `patrol develop`:
- Runs a single test execution with hot reload capability
- Press 'R' to restart the test execution
- Press 'Ctrl+C' to exit
- Automatically exposes patrolNative bindings
- Uses BASE_URL environment variable (defaults to http://localhost:3000)

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
