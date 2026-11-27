# Migrating to Patrol 5.0

Working notes for the Patrol 5.0 migration guide. Every change on `release/5.0`
that needs action from users adds a section here, or a line to the Inbox at the
end. Before the release, this file becomes the migration guide in the docs.

Each section says which packages it affects, what changed and what to do.

## Package versions

Update `patrol` and `patrol_cli` together: Patrol 5.0 is `patrol` 5.x with
`patrol_cli` 5.x. Prereleases are published as `5.0.0-dev.N`.

| Package | 5.0 | Notes |
|---|---|---|
| `patrol` | 5.x | |
| `patrol_cli` | 5.x | |
| `patrol_mcp` | not released yet | needs a release that depends on `patrol_cli` 5.x; until then it resolves `patrol_cli` 4.x |
| `patrol_finders` | TODO | `pumpAndSettle()` return type changed, see Inbox |
| `patrol_log` | 0.10.x, no change so far | |

To try a prerelease, pin it explicitly, since pub doesn't pick prereleases on
its own:

```yaml
dev_dependencies:
  patrol: 5.0.0-dev.1
```

```bash
dart pub global activate patrol_cli 5.0.0-dev.1
```

## Flutter 3.44 and Dart 3.12 are required

**Packages:** `patrol`, `patrol_cli`

| Package | Before | 5.0 |
|---|---|---|
| `patrol` | Flutter 3.32, Dart 3.8 | Flutter 3.44, Dart 3.12 |
| `patrol_cli` | Dart 3.8 | Dart 3.12 (Flutter 3.44) |

`patrol_cli` moved to `platform` 3.2.0, which needs `meta` 1.18. Flutter pins
`meta` 1.18 only from 3.44 on, so `patrol_cli` can't resolve on older Flutter
versions. `patrol` follows, so both packages have the same minimum.

**What to do:**

1. Upgrade Flutter to 3.44 or newer (`flutter upgrade`, or bump the version in
   your FVM config or CI).
2. Update `patrol` in your `pubspec.yaml` and reactivate `patrol_cli`:

   ```bash
   dart pub global activate patrol_cli
   ```

If you can't upgrade Flutter yet, stay on Patrol 4.x: keep `patrol: ^4.11.0` in
your `pubspec.yaml`. `dart pub global activate patrol_cli` on an older Flutter
picks the newest `patrol_cli` 4.x on its own.

## Android API 24 and macOS 10.15 are the minimum platform versions

**Packages:** `patrol`

| Platform | Before | 5.0 |
|---|---|---|
| Android | API 21 (Android 5.0) | API 24 (Android 7.0) |
| iOS | 13.0 | 13.0 (no change) |
| macOS | 10.14 | 10.15 |

These are the minimums of Flutter 3.44, so an app that builds with Flutter 3.44
already meets them, unless it sets lower values explicitly.

**What to do:**

- **Android:** in `android/app/build.gradle(.kts)`, set `minSdk` to 24 or
  higher, or use `flutter.minSdkVersion`. A lower value fails the build with
  `uses-sdk:minSdkVersion 21 cannot be smaller than version 24 declared in library [:patrol]`.
- **macOS:** set the deployment target to 10.15 or higher: `platform :osx,
  '10.15'` in `macos/Podfile`, and **macOS Deployment Target** of both `Runner`
  and `RunnerUITests` in Xcode.

## Inbox

Short notes on changes that don't have a section yet, one line each: the PR or
branch, the packages, what changed and what users have to do (`TODO` when that
isn't known yet). A line leaves the Inbox when it becomes a section above. Empty
the Inbox before 5.0.0 is released.

- #3382, `patrol_cli`: `patrol develop` no longer accepts `--tags`, which it never applied. Remove
  `--tags` from `patrol develop` commands and scripts; `patrol test` keeps it.
- #3040, `patrol_cli`: `patrol develop` on web requires Flutter 3.47.0 or newer, since hot restart
  needs flutter/flutter#183838; every other platform and `patrol test` on web keep the 3.44 floor.
  Upgrade Flutter, or point patrol at a newer SDK with `--flutter-command`, to keep using
  `patrol develop -d chrome`.
- `feat/pump-and-settle-return-int`, `patrol_finders` (and `patrol` through `$`):
  `pumpAndSettle()` returns `Future<int>` (number of pumped frames) instead of `Future<void>`.
  Callers need no change; classes that override `pumpAndSettle()` must return `Future<int>`.
