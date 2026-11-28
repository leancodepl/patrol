# Windows demos

Example app and tests for experimental Patrol Windows support
(`$.platform.windows` + the C++ `windows_runner` sidecar).

## Prerequisites

- Flutter with Windows desktop enabled
- Visual Studio 2022 or 2026 **Desktop development with C++** (or Build Tools
  with `VCTools`). Patrol uses the CMake that ships with it.
- Interactive desktop session (not a locked screen)

.NET is only needed for the optional native-dialog fixture, not for the runner.

## Setup

```powershell
cd dev/windows_poc/app
flutter pub get
```

## Explorer demo (smoke test)

Opens File Explorer via UI Automation. No fixture EXE.

```powershell
cd dev/windows_poc/app
dart run ../../../packages/patrol_cli/bin/main.dart test -d windows -t patrol_test/explorer_demo_test.dart
```

## Native dialog demo

Builds a small WinForms “security prompt” fixture, then drives Flutter UI and
the native dialog in one test:

```powershell
# From repo root
dotnet build dev/windows_poc/fixture -c Release
$env:PATROL_WINDOWS_FIXTURE_EXE = (
  Resolve-Path dev/windows_poc/fixture/bin/Release/net8.0-windows/patrol_windows_fixture.exe
).Path

cd dev/windows_poc/app
dart run ../../../packages/patrol_cli/bin/main.dart test -d windows -t patrol_test/demo_test.dart
```

## Notes

- Pass targets with `-t`. A bare path is ignored and the whole suite runs.
- First run builds the Flutter Windows app and compiles `windows_runner`
  (subsequent runs are much faster).
- `patrol develop` and `--coverage` are not supported on Windows yet.

See `packages/patrol/windows_runner/PROTOCOL.md` for the automator wire contract.
