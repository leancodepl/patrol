# Patrol packages: release facts

## Published packages

| Package | Version files (all must match) | Tag | Publish dry-run (prepare workflow) | Semver check |
|---|---|---|---|---|
| `adb` | `pubspec.yaml` | `adb-vX.Y.Z` | `dart pub publish --dry-run` | — |
| `patrol_log` | `pubspec.yaml` | `patrol_log-vX.Y.Z` | `flutter pub publish --dry-run` | `patrol_log-check-semver` |
| `patrol_finders` | `pubspec.yaml` | `patrol_finders-vX.Y.Z` | `flutter pub publish --dry-run` | `patrol_finders-check-semver` |
| `patrol` | `pubspec.yaml` | `patrol-vX.Y.Z` | `flutter pub publish --dry-run` (must list `skills/`) | `patrol-check-semver` |
| `patrol_cli` | `pubspec.yaml`, `lib/src/base/constants.dart` (`const version`) | `patrol_cli-vX.Y.Z` | `dart pub publish --dry-run` | — |
| `patrol_mcp` | `pubspec.yaml`, `bin/patrol_mcp.dart` (`const version`) | `patrol_mcp-vX.Y.Z` | none in CI — run `dart pub publish --dry-run` yourself | — |

Each tag triggers `.github/workflows/<pkg>-publish.yaml`, which publishes to
pub.dev through `leancodepl/mobile-tools/.github/actions/pub-release`, creates a
GitHub release and, for non-prereleases, posts to Slack. Prereleases use
`X.Y.Z-dev.N`.

The semver checks run on pull requests only and post a `semver (<pkg>)` status
on the PR's head commit — master commits don't get one. To get the
recommendation before a release PR exists, run the same tool locally (version
pinned in `.github/actions/check-semver/action.yaml`):

```bash
dart pub global activate dart_apitool 0.23.0
dart-apitool diff --old pub://patrol/4.10.0 --new packages/patrol
```

Not published (`publish_to: none`): `patrol_gen` (code generator for
`schema.dart` contracts) and `patrol_devtools_extension`. The DevTools extension
still ships: `patrol-publish.yaml` builds it into `packages/patrol/extension/`
before publishing patrol, so its changes go out with a patrol release. Its
`CHANGELOG.md` is not a release on its own.

## Dependency graph

Workspace dependencies (from the `dependencies:` blocks; `scripts/unreleased.sh`
reads them live):

```
patrol_log ──┬──> patrol_finders ──> patrol
             ├──────────────────────> patrol
             └──> patrol_cli ──> patrol_mcp
adb ─────────────> patrol_cli
adb ─────────────────────────────> patrol_mcp
```

patrol_cli does **not** depend on the patrol package (the `patrol: main` line in
its pubspec is under `executables:`). The two only have to agree at runtime,
which the compatibility table covers.

**Release and tag order:** adb and patrol_log first, then patrol_finders, then
patrol, then patrol_cli, then patrol_mcp. Skip the ones not being released, but
keep the order of the rest. Each package has its own release PR and its own
tag on that PR's merge commit. A PR that bumps a sibling constraint is opened
only after that sibling is on pub.dev.

## Local dependency overrides

`melos bootstrap` writes a gitignored `pubspec_overrides.yaml` next to each
package, pointing every sibling dependency at its path. Pub resolves through it
in every command, `pub publish --dry-run` included: the dry-run analyzes against
the local siblings and only prints the hint "Non-dev dependencies are overridden
in pubspec_overrides.yaml", which doesn't fail the step. Users get no overrides;
they resolve siblings from pub.dev, at the constraint's floor if their lockfile
is old. So a green dry-run says nothing about a floor that lacks the API the
package calls. patrol_cli shipped `adb: ^0.6.0` while calling `Adb.pull`, added
in 0.6.1, and patrol_mcp broke for users with an older lockfile (fixed in
9d9bc6958, b8d61350c).

What CI resolves against pub.dev:

| Job | Resolves | Catches a too-low floor |
|---|---|---|
| patrol-prepare `Resolve against published dependencies` | the newest published siblings | no: only API missing from the newest release, or a constraint pub.dev can't satisfy |
| patrol_mcp-prepare `Smoke (floor patrol_cli)` | patrol_cli at its floor | for patrol_cli only |

Nothing covers patrol_finders, patrol_cli, or patrol_mcp's `adb`, so run
`scripts/check-floors.sh <pkg>` before opening a release PR. It removes the
overrides, downgrades every sibling to its floor and analyzes `lib/` and
`bin/`. Since a dependent's release PR waits until the sibling it needs is
published, every floor should be on pub.dev. The script still accepts a floor
equal to the sibling's version in the tree (a branch stacked on the sibling's
release branch), and says so.

Both jobs above fail in pub get with "doesn't match any versions" when a
constraint points at a sibling version that isn't on pub.dev yet: the PR was
opened before that sibling was published.

### When to bump a sibling constraint

Bump the floor in the dependent's own release PR, once the sibling's new
version is on pub.dev (not in a separate commit outside a release), when:

- the dependent calls API added in the new version (otherwise it breaks at the
  floor);
- the new version is a 0.x minor or a major (`^0.10.0` doesn't allow 0.11.0;
  see c900d6460 and c85222d59);
- older versions break the dependent at runtime (033648446: patrol_mcp requires
  patrol_cli ^4.8.0 because 4.6.1–4.7.0 break hot restart);
- a third-party constraint widened in both only works with the new version
  (the equatable 3.x example in `SKILL.md`).

Otherwise leave it: `^0.10.0` already allows 0.10.2, and users get it with
`pub upgrade`. A raised floor narrows what users can mix, and it changes the
dependent's pubspec, so `tool/check_changelog.sh` wants a changelog entry and
the dependent needs a release of its own.

## Compatibility table

- Source of truth: `versionCompatibilityList` in
  `packages/patrol_cli/lib/src/compatibility_checker/version_compatibility.dart`.
  `patrol_cli` checks it before every run.
- Docs page: `docs/documentation/compatibility-table.mdx`, generated by
  `packages/patrol_cli/lib/src/compatibility_checker/generate_compatibility_table.dart`
  (run it from `packages/patrol_cli`). The opt-in features section in that file
  is maintained by hand.
- Tests: `packages/patrol_cli/test/compatibility_checker/`.
- Split precedents: 731e1d4a0 (patrol_log ^0.8.0 vs ^0.7.1), b00954520
  (patrol_log ^0.10.0 vs ^0.9.0).

## Past release PRs to copy from

| PR | Packages | Notes |
|---|---|---|
| #3352, #3353, #3354 | patrol_log 0.10.2, patrol_finders 3.7.0, patrol_mcp 0.2.2 | the first round with one PR per package: opened together, since none needed another's new version; each tag on its own merge commit |
| #3357 | patrol_cli 4.9.0 | opened once patrol_log 0.10.2 was on pub.dev; bumps `patrol_log: ^0.10.2`; two opt-in feature rows in the compatibility table, no `versionCompatibilityList` split |
| #3356 | patrol 4.11.0 | opened with #3357 and tagged right after it (paired features); bumps `patrol_log: ^0.10.2` |
| #3285 | patrol 4.10.0, patrol_cli 4.8.0 | one PR for both (before the one-PR-per-package rule); opt-in features section added; changelog entries trimmed before merge |
| #3293 | patrol_mcp 0.2.1 | three version files, changelog fold |
| #3231 | patrol_log 0.10.1 | squash-merged; the tag points at the squash commit |
