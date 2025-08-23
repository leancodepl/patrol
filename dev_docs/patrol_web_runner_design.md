## Patrol Web Runner Design (Playwright)

### Scope
- **Goal**: Run Patrol Flutter integration tests on the web (real browser) and report results in a native-like report.
- **Non-goals**: Native automation (notifications, permissions, etc.). Only run Flutter tests and surface their results.

### Current Architecture (relevant pieces)
- **Test bundling (Dart)**: `packages/patrol_cli/lib/src/test_bundler.dart` generates a bundled entrypoint that:
  - Builds the test tree via a special `patrol_test_explorer` test, then
  - Starts a Dart HTTP server: `PatrolAppService` in `packages/patrol/lib/src/native/patrol_app_service.dart` (Shelf on port `PATROL_APP_SERVER_PORT`, default 8082), then
  - Notifies native side that the service is ready via `NativeAutomator.markPatrolAppServiceReady()`.
- **Request/Response model** (native ↔ Dart):
  - Native runner calls `listDartTests()` and `runDartTest(name)` over HTTP to the Dart-side `PatrolAppService`.
  - Dart `patrolTest()` awaits `waitForExecutionRequest(currentTest)` and executes only when the requested test name matches.
  - Dart signals completion via `markDartTestAsCompleted()`; server returns success/failure and optional details.
- **Ports and defines**: CLI passes `PATROL_TEST_SERVER_PORT` (native control server) and `PATROL_APP_SERVER_PORT` (Dart app service) via `--dart-define` and env. On iOS/macos, Xcode env vars `TEST_RUNNER_PATROL_*` are used to inject ports; on Android, Gradle/JUnit runner reads defines.
- **CLI orchestration**: `packages/patrol_cli/lib/src/commands/test.dart` resolves targets, builds, sets defines, and executes via per-platform backends (`android_test_backend.dart`, `ios_test_backend.dart`, `macos_test_backend.dart`). Execution streams logs and collects outcomes into a native report.

### Desired Web Flow (high level)
- **Runner**: Playwright launches a real browser and navigates to the Flutter web app served locally.
- **App service**: The Flutter web app runs the same bundled entrypoint and hosts `PatrolAppService` over HTTP (reachable from Playwright host environment).
- **Control**: A Node.js-side controller (CLI backend) mimics the native runner behavior:
  - Wait for app service ready (poll or a small `/healthz`).
  - Call `listDartTests()` to get the suite.
  - Iterate tests; for each test call `runDartTest(name)` and wait until it completes.
  - Aggregate results and output a Patrol-style report.

### Web-Specific Considerations
- **Serving the app**: Use `flutter run -d web-server` or `flutter build web && simple static server`. Prefer dev-server for faster cycles. The CLI should spawn the server, capture the base URL, and pass it to Playwright.
- **Networking**: The `PatrolAppService` must bind to an address accessible from the Playwright context (e.g., `0.0.0.0` with known port). For Chrome with strict loopback, keep HTTP on host and call from Node controller, not from browser context.
- **No native automator**: Skip `NativeAutomator` interactions. The existing bundle still initializes it; ensure it no-ops on web or gate with platform checks. If needed, add a web guard so `NativeAutomator.configure()` is skipped.
- **Stability**: Add a readiness endpoint to `PatrolAppService` or wait for console log: "PatrolAppService started...". Alternatively, Playwright can poll `listDartTests()` until 200.

### Proposed Components
- **WebTestBackend (CLI)**: New backend analogous to iOS/macOS/Android backends.
  - Responsibilities:
    - Build or run the Flutter web app with `PATROL_APP_SERVER_PORT` define.
    - Spawn Playwright with a test harness script.
    - Pass ports and base URL via env.
    - Collect structured results and map to `RunResults` like other backends.
- **Node Controller Script**: A small JS/TS program executed by Playwright test runner or standalone Node process that:
  - Launches browser, opens the app URL, and keeps the page alive.
  - Calls Dart `PatrolAppService` endpoints from Node (not the page) to drive execution: `listDartTests()` and `runDartTest(name)`.
  - Logs per-step output and writes a report (JUnit XML or HTML) mirroring existing native report mapping.
- **CLI integration**:
  - Extend `patrol test` to accept `--device web` or detect `web-server` device and route to WebTestBackend.
  - Add `usesWebOptions()` if needed (browser type: chromium/firefox/webkit; headless; viewport).

### Execution Sequence
1. CLI resolves targets and generates the bundle (unchanged).
2. CLI starts `flutter run -d web-server --dart-define PATROL_APP_SERVER_PORT=...` (or `flutter build web` + static server).
3. Wait until the app service responds to `listDartTests()`.
4. Start Playwright and open app URL (ensures app fully booted and events/frames progress).
5. Controller fetches tests via `listDartTests()`.
6. For each test:
   - POST `runDartTest(name)` to app service.
   - Wait for response; record pass/fail and details.
7. Aggregate results and print native-like summary; optionally emit JUnit XML.
8. Shutdown browser and server.

### Data Contracts (reuse existing)
- `ListDartTestsResponse` and `RunDartTestResponse` from `packages/patrol/lib/src/native/contracts/` remain unchanged.
- The web runner must only be able to reach the app service HTTP endpoint.

### Reporting
- Reuse `PatrolLogReader`-like aggregation logic on CLI side for a consistent console output and index.html generation.
- For CI: emit JUnit XML compatible with current Android/iOS pipelines.

### Flags and Environment
- **Dart defines**:
  - `PATROL_APP_SERVER_PORT`: app service port (e.g., 8082)
  - `PATROL_TEST_SERVER_PORT`: not used on web; pass but ignored.
- **CLI options**:
  - `--browser=[chromium|firefox|webkit]` (default chromium)
  - `--headless` (default true in CI)
  - `--app-base-url` (optional override)

### Minimal Changes in Dart
- Ensure `PatrolBinding.ensureInitialized()` and `patrolTest()` flow works on web without native automator:
  - If necessary, guard `NativeAutomator` usage by platform; no-ops on web.
  - Confirm `shelf_io.serve` works on web target; for Flutter web, the Dart code runs in browser—cannot bind sockets. Therefore, keep server on host (Node), not in browser.
  - Adjustment: For web, host `PatrolAppService` in the CLI (Dart VM) and have the bundled app communicate back? That reverses direction and is more invasive.
  - Preferred approach: Serve the app, but the app cannot expose an HTTP server from the browser. So expose `PatrolAppService` over `postMessage`/WebSocket on the page instead.

### Web Transport Decision
- Browsers cannot open listening TCP sockets. Options:
  1) Implement `PatrolAppService` over WebSocket inside the web app and have the Node controller connect to it.
  2) Implement a page-exposed JS bridge and use `page.exposeFunction` / `page.evaluate` in Playwright to call into Dart `PatrolAppService` methods compiled to JS.

- **Chosen**: Option 2 (simpler to implement quickly):
  - Compile `PatrolAppService` logic for listing and running tests into the web app bundle as today, but instead of hosting Shelf server, expose two global JS-callable hooks:
    - `window.__patrol_listDartTests()` → returns JSON of `ListDartTestsResponse`.
    - `window.__patrol_runDartTest(name)` → returns `RunDartTestResponse` when the test completes.
  - Provide a tiny JS interop layer in the Flutter web app to bind Dart functions to these globals.
  - The Playwright controller uses `page.evaluate` to call these functions.

### Required Changes
- Dart (web build only):
  - Add conditional export/impl to bypass `shelf_io.serve` on web and instead register JS interop functions.
  - Example: in `patrol_app_service.dart`, behind `kIsWeb`, use `package:js` to expose `listDartTests` and `runDartTest` instead of starting HTTP server.
- CLI:
  - New `WebTestBackend` to orchestrate `flutter run -d chrome` or `-d web-server` and Playwright process.
  - Playwright harness script to call `page.evaluate('__patrol_listDartTests')`/`('__patrol_runDartTest', name)` sequentially and collect results.

### Risks
- Browser sandbox prevents hosting an HTTP server in-page; interop is required.
- Synchronization between Playwright and test lifecycle; ensure the `patrol_test_explorer` and binding complete before listing tests.
- Flaky timing on first load; add robust retries.

### Milestones
- M1: JS interop for `PatrolAppService` on web; manual `page.evaluate` sanity test.
- M2: Playwright harness + CLI `web` backend; run a single test file end-to-end locally.
- M3: Results aggregation and JUnit output; CI job template.
- M4: Browser selection, headless mode, and documentation.

### Open Questions
- Do we want to support multiple browser tabs/devices concurrently? Initially, no.
- Should we align the report format exactly with iOS/macOS? Aim for JUnit parity first, HTML later.
