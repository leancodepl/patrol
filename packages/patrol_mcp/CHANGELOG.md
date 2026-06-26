## Unreleased

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
