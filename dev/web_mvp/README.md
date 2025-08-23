# Patrol Web MVP Harness

Minimal Playwright harness that:
- Launches Chromium
- Opens the Flutter web app URL
- Calls `window.__patrol_listDartTests()` and `window.__patrol_runDartTest(name)`
- Prints results to stdout (MVP)

Prerequisites:
- Node 18+
- `npm i -D playwright`

Run (example):
```
# 1) In app repo root, build and serve Flutter web app (one simple way):
flutter run -d web-server --dart-define=PATROL_APP_SERVER_PORT=8082 --target integration_test/<your_test>.dart
# Take note of the served URL printed by Flutter (e.g., http://localhost:8080)

# 2) In another terminal, run the harness:
node dev/web_mvp/run.js http://localhost:8080
```
