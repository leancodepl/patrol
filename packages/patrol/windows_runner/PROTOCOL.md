# Windows automator sidecar HTTP protocol

Language-neutral contract between the Dart `WindowsAutomator` client and the
out-of-process Windows runner (C# today; a C++ port must speak the same).

## Transport

- Base URL: `http://127.0.0.1:{testPort}/` (default test port `8081`)
- Method: `POST` to `/{action}`
- Request: `Content-Type: application/json` body (object; `{}` when empty)
- Success: HTTP `200`
  - Void actions may return an empty body or `{}`
  - Otherwise a JSON object

## Errors

Non-200 responses **must** be a JSON object with a string `error` field:

```json
{ "error": "human-readable message" }
```

| Status | Meaning |
|--------|---------|
| `400` | Invalid request (missing/invalid fields, bad selector) |
| `404` | Target not found (UI element, window, app) within the find timeout |
| `500` | Unexpected runner failure |

Clients should prefer the `error` string for user-facing messages.

## Selector body

Used by find-based actions. Fields are AND-ed; at least one of `name`,
`automationId`, or `className` is required.

| Field | Type | Notes |
|-------|------|--------|
| `name` | string | UIA Name |
| `automationId` | string | UIA AutomationId |
| `className` | string | UIA ClassName |
| `index` | int ≥ 0 | Optional 0-based match index |
| `timeoutMillis` | int > 0 | Optional find timeout; runner default if omitted |
| `within` | object | Optional search root (see below) |

### `within` (search scope)

The Dart client **defaults** to the Flutter app under test: when the test
omits `within`, it sends `{ "processId": <dart:io pid> }`.

| Wire shape | Meaning |
|------------|---------|
| omitted / absent | Full desktop (only if the client sends no `within`; Dart uses this for `WindowsScope.desktop`) |
| `{ "processId" }` / `{ "processName" }` / `{ "windowName" }` | Root finds at that top-level window (at least one field required) |

| Field | Type | Notes |
|-------|------|--------|
| `processId` | int > 0 | OS process id |
| `processName` | string | e.g. `notepad` or `explorer.exe` |
| `windowName` | string | Window title (exact or substring, case-insensitive) |

Override in Dart with `WindowsSelector(within: WindowsScope(...))` for
another window, or `within: WindowsScope.desktop` for an unscoped search.

## Actions

| Path | Body | Success body |
|------|------|----------------|
| `markPatrolAppServiceReady` | `{}` | empty / `{}` |
| `tapAt` | `{ x, y }` normalized `[0,1]` | empty |
| `tap` | selector (+ timeout) | empty |
| `waitUntilVisible` | selector (+ timeout) | empty |
| `isElementVisible` | selector (+ optional timeout) | `{ "visible": bool }` |
| `findElement` | selector (+ timeout) | `{ "element": object \| null }` |
| `enterText` | `{ "text": string, ...selector }` | empty |
| `pressKey` | `{ keyCode, shift?, ctrl?, alt? }` | empty |
| `launchApp` | `{ appPath, arguments?, activate? }` | `{ "processId": int }` |
| `activateApp` | at least one of `processName`, `windowName`, `processId` | empty |

Element snapshots use: `name`, `className`, `automationId`, `x`, `y`, `width`,
`height` (screen pixels).
