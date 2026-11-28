# Patrol Windows runner

Out-of-process C++ sidecar that launches the Flutter Windows app and drives
desktop UI Automation (UIA3). Speaks the HTTP/JSON contract in
[PROTOCOL.md](PROTOCOL.md).

## Stack

- C++17 + UI Automation COM
- CMake + MSVC (same Desktop C++ toolchain as Flutter Windows)
- Vendored [cpp-httplib](https://github.com/yhirose/cpp-httplib) v0.18.3 and
  [nlohmann/json](https://github.com/nlohmann/json) v3.11.3 under `third_party/`

## Build

`patrol test -d windows` configures and builds this tree automatically. Manual
build:

```powershell
cmake -S packages/patrol/windows_runner -B packages/patrol/windows_runner/build `
  -G "Visual Studio 17 2022" -A x64  # or "Visual Studio 18 2026"
cmake --build packages/patrol/windows_runner/build --config Release
# → packages/patrol/windows_runner/build/bin/patrol_windows_runner.exe
```

Distribution of a prebuilt binary (instead of compile-on-first-run) is still
open; self-contained .NET was rejected in favor of this small native EXE.
