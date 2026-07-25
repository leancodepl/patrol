# Windows runner: C# (.NET) vs C++

Notes from the Patrol Windows POC discussion on which native stack to use
for the out-of-process automator (`windows_runner`), and how to ship it if we
stay on .NET.

---

## Summary

| Concern | C# + FlaUI (current POC) | C++ + UIA COM |
|---------|--------------------------|---------------|
| UIA / feature velocity | **Strong** — FlaUI, less COM boilerplate | Weaker — hand-rolled COM, more code per feature |
| Fit with Flutter Windows toolchain | Weaker — extra .NET story | **Strong** — MSVC / CMake / Windows SDK already required |
| Binary size if self-contained | **~80 MB** (runtime bundled) | Typically **a few MB** |
| End-user .NET dependency | Avoidable with packaging choices | None |
| Long-term feature backlog | Screenshots, window scoping, dialogs, drag-drop, etc. stay cheaper | Same features cost more to write and maintain |


## C# (.NET) + FlaUI

### Pros

- **Best UI Automation ergonomics** on Windows (FlaUI over UIA3).
- Fast to build HTTP/JSON, retries, patterns (`Invoke`, `Value`, `Toggle`, windows).
- Matches how quickly the POC grew (`tap`, finders, `enterText`, `pressKey`, `launchApp` / `activateApp`, Explorer demo).
- Future features (screenshots, scoped finders, Save/Open dialogs, scroll, drag-drop) stay comparatively easy.
- Team can iterate without deep COM expertise.

### Cons

- **Self-contained publish is large** (~80 MB single-file `win-x64` in our measurement) — awkward to embed in the `patrol` pub package (~few MB of tracked sources today).
- Framework-dependent builds are small (~1 MB of app + deps) but need a **.NET runtime** (or SDK to build from source).
- Extra stack beside Flutter’s MSVC/CMake world.
- .NET versioning / antivirus / corporate policy friction possible (usually manageable).

---

## C++ + raw UI Automation

### Pros

- **Same toolchain as Flutter Windows** (VS Desktop C++, CMake, Windows SDK).
- **Small native EXE** — no CLR, no 80 MB runtime bundle.
- No .NET SDK/runtime for users or for “build runner from source” on a normal Flutter Windows machine (if deps stay in-tree / Windows SDK only).
- Can still be a **sidecar** (keep architecture; don’t go back to in-process plugin just to use C++).

### Cons

- **Much more UIA code**: `BSTR`s, `HRESULT`s, `Release`, condition trees, polling loops.
- Harder/slower to add patterns and helpers FlaUI already wraps.
- HTTP needs a small library (e.g. WinHTTP or vendored header-only) — doable, but more glue.
- Higher bug risk (leaks, lifetime) and fewer Dart-only contributors can touch it.
- Porting the current POC surface is realistic; **growing** it is the expensive part.

---

## If we stay on .NET: distribution options

Goal: users should not need `dotnet build` on every `patrol test` (and ideally not embed ~80 MB in pub).

### Option A — Self-contained EXE on GitHub Releases / CDN (recommended if C#)

1. CI runs `dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true …` (and optionally `win-arm64`).
2. Upload `patrol_windows_runner.exe` (~80 MB) as a release asset keyed to Patrol version.
3. `patrol_cli` resolves in order:
   - `PATROL_WINDOWS_RUNNER_EXE` env override  
   - cached download under user/project cache  
   - (dev) `dotnet build` from `windows_runner/` source  

**Pros:** No .NET on the test machine; clear versioning.  
**Cons:** Must host ~80 MB artifacts; download on first use.

### Option B — Framework-dependent runner + documented .NET Desktop runtime

Ship a **small** runner (~1 MB + deps) that requires [.NET 8 Desktop runtime](https://dotnet.microsoft.com/download) installed.

**Pros:** Tiny Patrol-owned artifact; can live closer to the package.  
**Cons:** Extra install step for users (or corporate images); runtime version pinning.

### Option C — Embed self-contained binary in the pub package

**Pros:** Offline, simple resolve.  
**Cons:** Pub package jumps by ~80 MB — generally **rejected** for Patrol (package is ~few MB of sources today).

### Option D — Build from source on the machine

CLI runs `dotnet build` / `publish` against `packages/patrol/windows_runner` (current POC path).

**Pros:** No hosting; always matches source.  
**Cons:** Requires .NET SDK; slower first run; worse for “just run tests.”

### Option E — Hybrid

- **Contributors / monorepo:** Option D.  
- **Published Patrol:** Option A (download) with Option B as a fallback if runtime is present.  
- Never Option C unless product explicitly accepts a fat package.

### Measured sizes (POC machine, approximate)

| Artifact | Size |
|----------|------|
| Self-contained single-file `win-x64` runner | **~79.5 MB** |
| Framework-dependent Release build folder (app + FlaUI, no runtime) | **~1 MB** |
| Git-tracked `packages/patrol` (order of magnitude) | **~ few MB** |

---

## Current POC status

- Implemented in **C# / FlaUI.UIA3** under `packages/patrol/windows_runner/` since C# was easier for POC.
- Demos under `dev/windows_poc/` (`demo_test`, `explorer_demo_test`, fixture).
- No final packaging decision yet; this doc is the reference for that choice.
