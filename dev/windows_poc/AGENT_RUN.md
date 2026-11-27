# Agent runbook: Patrol Windows PoC

Follow these steps **on a Windows PC** with an interactive desktop session
(not a locked/minimized-only RDP). Goal: prove `patrol test -d windows` works
with the **C++** `windows_runner`.

## Prerequisites (install once)

1. **Git** + clone of this repo on branch `feat/patrol-windows-POC`
   (must include the C++ rewrite commit — `windows_runner/CMakeLists.txt` exists).
2. **Flutter** stable with Windows desktop enabled:
   ```powershell
   flutter config --enable-windows-desktop
   flutter doctor
   ```
3. **Visual Studio 2022** with workload **Desktop development with C++**
   (MSVC + Windows SDK). The CLI invokes:
   `cmake -G "Visual Studio 17 2022" -A x64`.
4. **CMake** on `PATH` (`cmake --version` works in PowerShell).
5. Do **not** need .NET for the runner. .NET 8 SDK is only needed for the
   optional native-dialog fixture demo below.

## One-time setup for the demo app

From the **repo root**:

```powershell
cd dev/windows_poc/app
flutter pub get
```

Confirm the path dependency points at this monorepo’s `packages/patrol`
(see `pubspec.yaml`).

## Smoke test (recommended first) — Explorer demo

No fixture EXE. Opens File Explorer via UI Automation.

From **repo root**:

```powershell
cd dev/windows_poc/app
dart run ../../../packages/patrol_cli/bin/main.dart test -d windows patrol_test/explorer_demo_test.dart
```

What the CLI does automatically (you do not run these yourself):

1. `flutter build windows` for the Patrol entrypoint  
2. `cmake` configure + build of `packages/patrol/windows_runner`  
3. Launch `patrol_windows_runner.exe` against the built app  

**Success:** command exits `0`. You should see Explorer open a temp folder
`PatrolExplorerDemo` and the test tap `patrol_explorer_target.txt`.

**First run** can take several minutes (Flutter Windows build + C++ runner
compile). Later runs reuse `windows_runner/build/`.

## Optional — Flutter + native dialog demo

Needs a .NET fixture EXE (not built by `patrol test`):

```powershell
# From repo root
dotnet build dev/windows_poc/fixture -c Release
$env:PATROL_WINDOWS_FIXTURE_EXE = (
  Resolve-Path dev/windows_poc/fixture/bin/Release/net8.0-windows/patrol_windows_fixture.exe
).Path

cd dev/windows_poc/app
dart run ../../../packages/patrol_cli/bin/main.dart test -d windows patrol_test/demo_test.dart
```

**Success:** exit `0`; a “Windows Security Prompt” Win32 dialog appears and is
driven by UIA (type + Allow).

## If something fails

| Symptom | Check |
|---------|--------|
| `windows_runner not found` / missing `CMakeLists.txt` | Wrong branch or C++ commit not present |
| `cmake` / VS generator errors | Install VS 2022 Desktop C++; `cmake --version` |
| `Timed out waiting for markPatrolAppServiceReady` | App crash; look at console; unlocked desktop |
| Explorer demo flakes | Visible session; don’t run headless/locked |
| Still building with `dotnet` for the runner | Old C# tree — update to C++ commit |

## Out of scope

- `patrol develop` on Windows (rejected by CLI)
- `--coverage` on Windows (rejected by CLI)
- Publishing / downloading a prebuilt runner (PoC builds from source)

## References

- Wire protocol: `packages/patrol/windows_runner/PROTOCOL.md`
- Stack decision: `dev/windows_poc/NATIVE_STACK.md`
- Human-oriented demo notes: `dev/windows_poc/README.md`
