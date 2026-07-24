## Unreleased

- Return a distinct timeout warning from `run` when a run exceeds its `timeoutMinutes` while still executing, so callers can tell a timeout apart from an ordinary in-progress status (the test keeps running in the background — call `status` or `quit`).
- Tear down the active develop session when the client cancels a `run` (MCP cancellation), instead of leaving it orphaned in a perpetual `running` state.
- Fix misleading tool text: `run` only hot-restarts for the *same* test file (a different file is refused, quit first), and blocked-session warnings now refer to the `quit` tool by its correct name.
- Note in the `native-tree` tool description that on iOS a Flutter view may report an empty tree (use native contexts); Android's Flutter view is richer.
- Simplified setup: the `run-patrol` wrapper script is no longer needed — point your MCP config directly at `dart run patrol_mcp`. FVM-pinned projects run develop sessions with the pinned Flutter automatically. See the README for the updated setup.
- Run develop sessions from `PROJECT_ROOT`, so `run` works when the server's working directory differs from the project (e.g. an app in a subdirectory).
- Fix the `run` tool hanging until its timeout when the app shuts down before the test reports completion; it now returns promptly as a failed run with a warning, and a `quit` isn't misreported as a crash. Requires the first `patrol_cli` release after 4.5.1, which reports the backend exit independently of `flutter attach`.
- Multi-device support: `run` auto-selects a device (Android device > Android emulator > iOS device > iOS simulator) or accepts an optional `device` to target one, and a new `devices` tool lists attached Android/iOS devices. `PATROL_FLAGS --device` still takes precedence.
- Fix `screenshot` and `native-tree` MCP tools failing with `error: more than one device/emulator` (Android) or capturing the wrong simulator (iOS) when multiple devices are attached. Both now target the active session's device explicitly.
- Exit on client disconnect (stdin EOF), not just `SIGTERM`/`SIGINT`, and tear down the active develop session on shutdown so it doesn't orphan.
- Return structured output (`structuredContent`) from `run`/`status`/`native-tree`, and reply with a clear error instead of crashing when `quit` has no active session.
- Don't listen for `SIGTERM` on Windows, where it is not supported and throws an unhandled `SignalException` that prevented the MCP server from starting. (#3035)
- Update README: fix and simplify the GitHub Copilot MCP setup (#3089)


## 0.1.4

- Relax `patrol_cli` constraint to `^4.3.0` so `patrol_mcp` resolves
  alongside any `patrol` version from 4.5.0 onward. Fixes the
  version-solving conflict with `patrol ^4.6.0` reported in #3075.

## 0.1.3

- Bump `patrol_cli` to `4.3.1`.

## 0.1.2

- Update README.

## 0.1.1

- Fix dart formatting for full pub.dev score.
- Add example and remove global executable entry.
- Update README setup to use pub.dev dependency.

## 0.1.0

- Initial release.
- MCP server for managing Patrol develop sessions.
- Tools: run tests, take screenshots, get native view tree.
