# Patrol Windows runner

Out-of-process native sidecar that launches the Flutter Windows app and drives
OS-level UI Automation. Speaks the HTTP/JSON contract in [PROTOCOL.md](PROTOCOL.md).

## Stack

- **C++17** + Windows UI Automation (UIA3 COM)
- **CMake** + MSVC (same Desktop C++ toolchain Flutter Windows uses)
- Vendored [cpp-httplib](https://github.com/yhirose/cpp-httplib) +
  [nlohmann/json](https://github.com/nlohmann/json) under `third_party/`

## Build (Windows)

```powershell
cmake -S packages/patrol/windows_runner -B packages/patrol/windows_runner/build -A x64
cmake --build packages/patrol/windows_runner/build --config Release
# → packages/patrol/windows_runner/build/bin/patrol_windows_runner.exe
```

`patrol test -d windows` runs the same configure/build via `patrol_cli`.

## Override

Set `PATROL_WINDOWS_RUNNER_EXE` only if you need a prebuilt binary path later;
the CLI currently always builds from this source tree.
