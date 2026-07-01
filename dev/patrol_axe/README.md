# patrol_axe (POC)
Core gets a **one-time generic hook**; each extension owns its schema, Dart API, native routes, and SDK deps.

## How it works

### Native (`:8081` PatrolServer)

1. At server startup, Patrol discovers optional extensions:
   - **Android:** `ServiceLoader` + SPI file (`META-INF/services/pl.leancode.patrol.PatrolServerExtension`)
   - **iOS:** ObjC runtime scan for `PatrolServerExtension` conformers
2. Extension packages register their own POST routes (`axePing`, `axeScan`, …) on the **same** server that powers `$.platform.mobile.*`
3. Route handlers (Kotlin/Swift) call the third-party SDK (Deque axe in this POC — stubs for now)

### Dart

1. Extension adds `$.axe` via a Dart `extension on PatrolIntegrationTester` (no core change)
2. `AxeAutomator` → `AxeAutomatorClient` → `POST localhost:8081/<route>`
3. Uses `patrolNativeServerUri` from core (same host/port as `$.platform.mobile.*`)
4. Types come from the package's own `schema/axe.dart` + `patrol_gen` (client is hand-written in the POC)

## Core Patrol changes (generic only)

| Platform | Change |
|----------|--------|
| Android | `PatrolServerExtension` interface + `ServiceLoader` discovery + route merge in `PatrolServer.start()` |
| iOS | `PatrolServerExtension` protocol + `PatrolRouteRegistrar` facade + runtime discovery + merge in `PatrolServer.start()` |
| Dart | `patrolNativeServerUri` getter (exported from `patrol.dart`) |

## What lives in this package

```
schema/axe.dart                              # package-owned schema (own patrol_gen run)
lib/
  patrol_axe.dart                             # exports
  src/patrol_axe_extension.dart               # extension → $.axe
  src/axe_automator.dart                      # user-facing API + logging
  src/contracts/axe_automator_client.dart     # HTTP client (represents generated client)
android/
  build.gradle
  src/main/kotlin/.../AxeServerExtension.kt   # implements PatrolServerExtension
  src/main/kotlin/.../AxeAutomator.kt         # calls Deque SDK (stub)
  src/main/resources/META-INF/services/pl.leancode.patrol.PatrolServerExtension
darwin/patrol_axe/Sources/PatrolAxe/AxeServerExtension.swift
```

## Runtime flow

```
$.axe.scan()                         (patrol_axe Dart)
  → POST localhost:8081/axeScan      (AxeAutomatorClient → patrolNativeServerUri)
    → route registered by AxeServerExtension   (discovered by core hook)
      → AxeAutomator → Deque axe DevTools SDK
```

`$.platform.mobile.pressHome()` still goes to core routes on the same server.

Route names are agreed **inside the extension package** (schema method name = HTTP path). Core does not validate or register them.

## How a user adds it

### Dart

```yaml
dev_dependencies:
  patrol_axe:
    path: ../patrol_axe  # or pub version when published
```

```dart
import 'package:patrol_axe/patrol_axe.dart';

await $.axe.ping();
```

### Android

The extension must be on the **instrumentation** classpath (`PatrolServer` runs there, not in the main app):

```kotlin
// app/build.gradle.kts
androidTestImplementation(project(":patrol_axe"))
```

### iOS

Mostly automatic if standard Patrol iOS setup is done (`RunnerUITests` links `FlutterGeneratedPluginSwiftPackage`). The extension plugin is picked up via Flutter's generated SPM package / CocoaPods `inherit! :complete`. Full iOS plugin packaging for `patrol_axe` is still TODO in this POC.

## Mental model (TL;DR)

1. Extension adds native routes + handlers → merged onto core `:8081` server (SPI / ObjC discovery)
2. Handlers call the third-party SDK in Kotlin/Swift
3. Core only adds generic route mounting + `patrolNativeServerUri`
4. App: `dev_dependency` + `androidTestImplementation` on Android; iOS follows existing Patrol plugin setup once `patrol_axe` is a proper Flutter plugin
5. Dart: typed HTTP client (generated from package schema or hand-written); `$.axe` via extension
