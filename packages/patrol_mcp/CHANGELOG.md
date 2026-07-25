## Unreleased

- Support web develop sessions: the `devices` tool now lists browsers (e.g. `chrome`) and `run` accepts them as `device`. Web is still never auto-selected, since a browser is rarely what "run the test" means when a phone is attached, so pass it explicitly. `screenshot` already worked on web via CDP; `native-tree` remains Android/iOS only.
- Drop the web-specific session handling that existed only because `patrol develop` on web restarted cold: web sessions now stay alive across hot restarts like mobile ones, so there are no stale completion callbacks to suppress and no orphaned Flutter/Chrome process to force-kill. Requires the first `patrol_cli` release after 4.7.0.

## 0.2.0

- Multi-device support: `run` auto-selects a device (Android before iOS, real before emulator/simulator) or targets one you pass as `device`, and a new `devices` tool lists what's attached. A `--device` in `PATROL_FLAGS` still wins.
- Simplified setup: drop the `run-patrol` wrapper and point your MCP config straight at `dart run patrol_mcp`; FVM-pinned projects use the pinned Flutter automatically. See the README.
- More reliable runs and cleanup:
  - `run` returns a failed run instead of hanging when the app exits before the test finishes (needs `patrol` 4.7.0+); a timed-out run is distinguishable from a still-running one.
  - No orphaned processes — sessions are torn down on cancel, client disconnect, and shutdown; the server force-exits if teardown stalls.
  - `screenshot` and `native-tree` work with multiple devices attached.
  - `quit` isn't misreported as a crash, and errors clearly when there's no active session.
  - Structured output from `run`/`status`/`native-tree`; `run` works from a different working directory (`PROJECT_ROOT`); starts on Windows.


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
