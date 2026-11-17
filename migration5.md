# Migrating to Patrol 5.0

Working notes for the Patrol 5.0 migration guide. Every change on `release/5.0`
that needs action from users adds a section here. Before the release, this file
becomes the migration guide in the docs.

Each section says which packages it affects, what changed and what to do.

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
