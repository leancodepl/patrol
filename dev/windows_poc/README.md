# Patrol Windows — capability demo

Tests that show **Flutter automation + native desktop automation** in a
single `patrol test -d windows` run.

## What you will see

1. Flutter window — Patrol taps in-app buttons (same model as Android/iOS)
2. A separate **Win32 “Windows Security Prompt”** appears (not Flutter)
3. Patrol finds it with UI Automation, types an identity, presses keys, clicks **Allow access**
4. Test asserts both worlds succeeded

## Run Flutter + native dialog demo

```powershell
# From repo root
dotnet build dev/windows_poc/fixture -c Release
$env:PATROL_WINDOWS_FIXTURE_EXE = (
  Resolve-Path dev/windows_poc/fixture/bin/Release/net8.0-windows/patrol_windows_fixture.exe
).Path

cd dev/windows_poc/app
dart run ../../../packages/patrol_cli/bin/main.dart test -d windows patrol_test/demo_test.dart
```

## Run Explorer demo (`launchApp` / `activateApp`)

No fixture EXE required — opens real File Explorer:

```powershell
cd dev/windows_poc/app
dart run ../../../packages/patrol_cli/bin/main.dart test -d windows patrol_test/explorer_demo_test.dart
```

Tip: run on a visible desktop session (not a locked RDP screen) so windows
are easy to watch.
