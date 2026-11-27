# Windows runner: native stack

Decision record for the out-of-process automator (`windows_runner`).

## Decision

**Use C++ + raw UI Automation (UIA3 COM)** — not C# / FlaUI.

Reasons:

- Same toolchain as Flutter Windows (MSVC / CMake / Windows SDK)
- Small native EXE (no ~80 MB self-contained .NET runtime)
- No .NET SDK/runtime required for users or for `patrol test`
- Sidecar architecture stays the same; Dart + `PROTOCOL.md` unchanged

Tradeoff: more COM boilerplate and slower feature velocity than FlaUI. The
trimmed v1 surface (tap / find / enterText / pressKey / launchApp /
activateApp) is still realistic to maintain in C++.

## Distribution

Current PoC: `patrol_cli` runs `cmake` + `cmake --build` against
`packages/patrol/windows_runner` (build-from-source). Future options:

| Option | Notes |
|--------|--------|
| Build from source (now) | Needs VS Desktop C++ workload — already required for Flutter Windows |
| CI-published EXE | Optional cache/download of a few-MB Release binary keyed to Patrol version |
| Embed in pub package | Feasible for a small C++ binary; was rejected for ~80 MB .NET |

## History

An earlier PoC used C# + FlaUI.UIA3 for speed of exploration. It was rewritten
to C++ after choosing toolchain/size over FlaUI ergonomics. The wire protocol
in `PROTOCOL.md` was kept stable across that rewrite.
