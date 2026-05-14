# Patrol cross-origin PoC — opener + DUT architecture

This PoC demonstrates that **Patrol can drive a cross-origin user journey from
a single Dart test running in one isolate**, while preserving the foundational
Patrol invariant that test code lives in the same isolate as the app under
test.

## The key insight

`window.open(url, 'patrol_dut')` returns a `Window` reference that **survives
top-level cross-origin navigation in the DUT tab** (because `window.opener` is
a property of the browsing context, not the document). The controller tab
stays loaded the whole time; only the DUT tab navigates through different
origins. A small DUT wrapper in each app re-announces itself via
`window.opener.postMessage(...)` after every page load, so the controller
always knows where the DUT currently is and can issue commands against the
fresh widget tree.

## Architecture

```
                  ┌───────────────────────────────────┐
                  │ Playwright (in CI / local)        │
                  │   open http://localhost:8084      │
                  │   call __patrol__runTest(name)    │
                  └─────────────────┬─────────────────┘
                                    │
                                    ▼
                  ┌───────────────────────────────────┐
                  │ Controller Flutter Web app :8084  │
                  │   patrolTest(...) runs in this    │
                  │   isolate; uses RemoteDut to      │
                  │   drive the DUT tab via          │
                  │   postMessage. Stays alive whole  │
                  │   test.                           │
                  └─────────────────┬─────────────────┘
                                    │ window.open + postMessage
                                    ▼
   ┌──────────────────────────────────────────────────────────┐
   │ DUT tab (single browsing context, navigates between):    │
   │                                                          │
   │   panel.app:8082 ─── tap go_login (real location.href) ─▶│
   │   auth.app:8081  ─── tap sign_in  (real location.href) ─▶│
   │   panel.app:8082 ─── tap go_canvas                     ─▶│
   │   canvas.app:8083 ── tap save_back                     ─▶│
   │   panel.app:8082                                         │
   │                                                          │
   │ Each app on boot calls initPatrolDutWrapper() which      │
   │ registers a postMessage handler and announces            │
   │ 'patrol_ready' to window.opener.                         │
   └──────────────────────────────────────────────────────────┘
```

Every leg in the journey is a **real top-level cross-origin navigation**
initiated by tapping a real button inside the running Flutter Web app. The
controller test code is one continuous Dart function — no leg boundaries, no
multiple test bundles, no test-state-in-URL.

## Layout

```
dev/cross_origin_poc/
├── cross_origin_lib/                shared Dart package
│   ├── bin/
│   │   └── orchestrate.dart           CLI: parses patrol.remote.apps, starts apps, runs Playwright
│   └── lib/
│       ├── cross_origin_lib.dart
│       └── src/
│           ├── serialized_finder.dart        SerializedFinder + PatrolFinder serialization
│           ├── remote_app_wrapper.dart       initPatrolRemoteApp(): postMessage handler on remote side
│           ├── remote_app.dart               RemoteApp: controller-side RPC client
│           ├── remote_apps_lookup.dart       RemoteApps.origin('name'): reads PATROL_REMOTE_APPS env
│           ├── remote_app_tester.dart        RemoteAppTester: the `$` in patrolRemoteTest
│           ├── remote_patrol_finder.dart     RemotePatrolFinder: $(...).tap()/.enterText()/.count
│           └── patrol_remote_test.dart       patrolRemoteTest function
├── apps/
│   ├── auth/      :8081   remote app — login form
│   ├── panel/     :8082   remote app — landing, nav to auth/canvas
│   ├── canvas/    :8083   remote app — counter
│   └── controller/ :8084  controller — hosts patrolRemoteTest, declares patrol.remote.apps
├── run.sh                           wrapper: cd apps/controller && dart run cross_origin_lib:orchestrate
└── README.md
```

Remote apps depend on `cross_origin_lib` and call `initPatrolRemoteApp()`
after `runApp(...)`. The controller depends on both `cross_origin_lib` (for
`patrolRemoteTest`/`RemoteApp`/etc.) and `patrol` (for `patrolTest` under
the hood).

## Declaring remote apps

In the controller's `pubspec.yaml`:

```yaml
patrol:
  remote:
    apps:
      panel:
        path: ../panel
        port: 8082
      auth:
        path: ../auth
        port: 8081
      canvas:
        path: ../canvas
        port: 8083
```

The orchestrator (`cross_origin_lib:orchestrate`) parses this section,
starts each app's web-server on its declared port, compiles the controller
with `--dart-define=PATROL_REMOTE_APPS={"panel":"http://localhost:8082",...}`,
then runs Playwright against the controller.

## The test

```dart
patrolRemoteTest(
  'panel_auth_canvas_roundtrip',
  startsIn: 'panel',
  callback: ($) async {
    expect(await $(#status_anon).count, 1);

    await $(#go_login).tap();
    await $.waitForApp('auth');

    await $(#email).enterText('foo@bar.com');
    await $(#password).enterText('s3cret');
    await $(#sign_in).tap();
    await $.waitForApp('panel');

    expect(await $('Hello foo@bar.com').count, 1);

    await $(#go_canvas).tap();
    await $.waitForApp('canvas');

    await $(#increment).tap();
    await $(#save_back).tap();
    await $.waitForApp('panel');

    expect(await $('Hello foo@bar.com, canvas value: 1').count, 1);
  },
);
```

No hardcoded URLs in the test — `startsIn`/`waitForApp` reference names from
the pubspec config; the lookup table comes through `--dart-define`. Same
test runs unchanged in CI with different port allocations.

The `$` here is **not** the standard `PatrolIntegrationTester` — it's a
[`RemoteAppTester`] whose `call(matching)` returns a [`RemotePatrolFinder`]
that has `.tap()`, `.enterText(text)`, and `.count` (only the operations
expressible as `(serialized_finder, action)` over postMessage). Local-only
operations like `.evaluate()` or `.state<T>()` are intentionally absent so
the compiler stops you from writing tests that can't work cross-origin.

`$(matching)` accepts the same kinds as `PatrolTester.call()`:

| argument                          | behaviour                                  |
|-----------------------------------|--------------------------------------------|
| `PatrolFinder` (e.g. `$(#login)`) | introspect underlying Finder; serialize    |
| `Symbol` (e.g. `#login`)          | byKey with the symbol's name               |
| `String` (e.g. `'Sign in'`)       | byText                                     |
| `ValueKey('login')`               | byKey                                      |
| `Finder` (e.g. `find.byKey(...)`) | introspect; serialize                      |
| `SerializedFinder` (explicit)     | passthrough                                |

Tab-level operations live on the tester itself:
- `$.waitForOrigin(origin)` — wait for the next `patrol_ready` after a nav

For lower-level access there's `$.app` exposing the raw `RemoteApp` (e.g.
`$.app.ping()`).

PatrolFinder serialization works by reading the underlying `Finder`'s runtime
type (`_KeyFinder`, `_TextFinder`, `_DescendantFinder` are flutter_test
private classes with public fields, accessed via `dynamic`). If a finder
shape can't be expressed as a `SerializedFinder` (predicate-based finders,
icon finders, etc.), serialization throws `UnsupportedError`. This is a
deliberate trade-off: only finder kinds that are mechanically describable
cross the postMessage boundary.

Compare to a hypothetical Playwright test of the same flow: this is the same
shape, but selectors are **real Flutter Finders** (byKey/byText/descendant)
materialised against the live widget tree, taps go through real
`PointerEvent` dispatch via `LiveWidgetController`, and the assertion lens is
Dart `expect` over Dart values.

## Running

```
cd dev/cross_origin_poc
./run.sh
```

To see the browser interactively:

```
PATROL_WEB_HEADLESS=false ./run.sh
```

To run an individual DUT app manually (e.g. clicking through by hand):

```
cd apps/panel
flutter run -d chrome --web-port=8082
```

## What this PoC proves

1. **`window.opener` reference survives top-level cross-origin navigation** in
   the DUT tab — verified by `dut.waitForReady(expectedOrigin: <new>)`
   succeeding after each `dut.tap(<button that does location.href = ...>)`.
2. **Real `Finder`-based widget operations work on a live Flutter Web app**
   (not under a test binding) via `LiveWidgetController` against the regular
   `WidgetsBinding`.
3. **A single `patrolTest(...)` can express a multi-origin journey** without
   splitting into multiple entrypoints. The controller's isolate hosts the
   test program for the whole duration; DUT origins come and go.
4. **The Patrol invariant holds**: test code lives in the controller's
   isolate. Inside each DUT, the wrapper has full direct access to that app's
   widget tree (no JSON-RPC there). Serialisation happens only at the
   postMessage boundary between controller and DUT, which is unavoidable.

Empirical end-to-end run: Panel → Auth → Panel → Canvas → Panel via 4 real
top-level cross-origin redirects + 6 widget taps + 2 enterTexts + 3 findCount
assertions, in **~3 seconds** test execution time, all in one continuous
`patrolTest`.

## Two runtime gotchas surfaced during PoC bring-up

1. **`flutter run -d web-server` binds the port BEFORE compilation finishes.**
   `curl http://localhost:8084` returns 200 with the HTML index instantly, but
   `/main.dart.js` returns HTML (the "still compiling" page) until the dart2js
   bundle is actually built. If Playwright connects in that window, it loads
   `flutter_bootstrap.js` which then tries to load `main.dart.js`, browser
   refuses (`Refused to execute script because its MIME type ('text/html') is
   not executable`), Dart never boots, `__patrol__onInitialised` is never set,
   `initialise()` times out. `run.sh` therefore waits on
   `Content-Type: text/javascript` for `main.dart.js`, not on a HEAD against
   `/`.
2. **`controller.tap()` cannot await completion if the tap triggers
   top-level navigation.** The `onPressed` handler sets `window.location.href`,
   the browser starts tearing down the document, and any subsequent Dart code
   (including `_postResult`) may not run. The DUT wrapper therefore handles
   `tap` specially: posts the ack **before** firing the gesture, then
   fire-and-forgets via `LiveWidgetController(...).tap(finder).ignore()`. The
   controller's `await dut.tap(...)` resolves on the ack, then it calls
   `await dut.waitForReady(expectedOrigin: ...)` to await the new document.

## Trade-offs

The controller test sees the DUT through a **serialised lens**: selectors and
actions are JSON-encoded over postMessage. Patrol-style direct widget tree
introspection (`tester.state<MyState>(...).controller.value`) is not available
to the controller; the DUT can do it, but only through explicit "registered
queries" the app exposes for testing.

For ~80% of test code (selector + action + count/text assertion) this is
invisible. For deeper state assertions, the production version of this
architecture would need:

```dart
// In the DUT app:
PatrolDutWrapper.registerQuery('cartItemCount', () => CartState.instance.items.length);

// In the controller test:
expect(await dut.query<int>('cartItemCount'), 3);
```

PoC v1 doesn't implement `registerQuery`/`dut.query` — only the core
`tap`/`enterText`/`findCount` are wired.

Other limits of PoC v1:
- `enterText` writes directly to `TextEditingController.text` (`onChanged` does
  not fire). Production needs proper `TestTextInput` integration.
- Only `byKey`/`byText`/`descendant` finders are serialisable. `byType`
  requires a type-by-name registry on the DUT side (Dart has no runtime
  reflection for type-by-name).
- DUT origins without our wrapper (e.g. external OAuth providers) are blind
  spots — controller can write `dut.location.href` cross-origin but cannot
  read it (same-origin policy on read).
- `flutter_test` is in DUT apps' runtime dependencies (not dev only).
  Production version should slim this down to just the gesture-dispatch
  primitives needed.

## Roadmap to production

1. **`patrol_remote` package** carved out of `cross_origin_lib`, slim runtime
   deps (drop `flutter_test` from DUT-app runtime by reimplementing
   `LiveWidgetController.tap` via direct `GestureBinding` event dispatch).
   Lives under `packages/`.
2. **`registerQuery` / `$.app.query<T>(name)` API** for deep-state assertions
   with typed return values from inside the remote app.
3. **Proper `enterText`** via `TestTextInput` so `onChanged`/validators fire
   through the normal channel (current PoC writes directly to
   `TextEditingController.text`).
4. **Type-name registry** for `byType` finders (Dart has no runtime type
   reflection from name).
5. **`patrol remote` CLI command** in `packages/patrol_cli`: takes over from
   `cross_origin_lib:orchestrate`, integrates with the rest of Patrol's
   `WebTestBackend` flow (reporter, retry, headless flag, BrowserContext
   options), shows up in `patrol --help`. Probably reuses
   `patrol.remote.apps` schema verbatim.
6. **Auto port allocation**: `port:` optional in pubspec config; orchestrator
   uses `--web-port=0` and parses Flutter's stdout for the bound port.
7. **Cookie/storage helpers**: Playwright actions like `clearCookies` need to
   be re-routed for the remote-app tab specifically (today they target the
   controller's browser context broadly — fine for PoC, not for prod).
