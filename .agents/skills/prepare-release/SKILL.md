---
name: prepare-release
description: Plan, prepare and publish releases of the Patrol packages (patrol, patrol_cli, patrol_finders, patrol_log, patrol_mcp, adb). Use when asked what is unreleased or ready to release, which PRs are close to merging before a release, to prepare a release ("prepare patrol 4.11.0", "release patrol_log"), or to tag and publish a merged release PR. Status is read-only; preparing ends at open release PRs, one per package; a tag is pushed only after its PR merges and the user says so.
---

# Releasing Patrol packages

This skill is **orchestration + the release knowledge that isn't written down
anywhere else**. It has three modes, each ending at a hard stop. Run only the
mode you were asked for: "what's unreleased?" or "which PRs are close?" is
Status, even when a release is obviously next.

| Mode | Asked as | Ends with |
|---|---|---|
| [1. Status](#1-status) | "what's unreleased", "what can we release", "which PRs are close to merging" | a report; nothing changed |
| [2. Prepare](#2-prepare) | "prepare the release", "release patrol X.Y.Z" | open release PRs, one per package |
| [3. Publish](#3-publish) | "tag it", "publish", once a release PR is merged | tags pushed, versions on pub.dev |

Read every run:
- [`references/packages.md`](references/packages.md) — version files, dependency
  graph and release order, tags, workflows.
- [`references/ci-noise.md`](references/ci-noise.md) — failing checks that don't
  mean anything, and how to tell when they do.

## Hard rules

- **Work from `origin/master`** after `git fetch origin --tags`; the local
  `master` is often behind. Edit in a new worktree on a new branch and leave
  the user's current checkout and branch alone.
- **Don't act on other people's PRs** — no merging, approving, commenting,
  labelling or re-running CI without the user's go-ahead. Draft the text instead.
- **Never push a tag before its release PR is merged**, and never without an
  explicit "yes" for that push. Print the commands first.
- **English** for commits, PR titles and bodies, even when the conversation isn't.
- **Verify on the Flutter version CI pins** (`flutter-version:` in
  `.github/workflows/patrol-prepare.yaml`, via fvm: `~/fvm/versions/<ver>/bin`).
  A newer local Flutter prints different pub warnings and rewrites lockfiles.
- **Go easy on the GitHub API.** The scripts cost under ~100 GraphQL points;
  don't loop `gh pr checks` over dozens of PRs. On a rate-limit error, check
  `gh api rate_limit` and wait for the reset.

## 1. Status

### What's unreleased

1. `git fetch origin --tags`, then run
   [`scripts/unreleased.sh`](scripts/unreleased.sh) (all publishable packages, or
   name some). Per package it prints the versions (pubspec, last stable tag,
   pub.dev), stray prerelease tags, workspace dependencies with pending changes,
   `## Unreleased` entries without a PR number, and PRs merged since the last
   tag that the section doesn't cite.
2. Read it:
   - **Nothing to release** — no Unreleased entries and only CI/test/docs PRs
     since the tag (those are exempt from `tool/check_changelog.sh`).
   - **Missing or wrong entries** — a merged PR that changed package source but
     isn't cited: check `gh pr view <n> --json title,files`. User-facing → it
     needs an entry. An entry citing the issue instead of the PR (e.g. `(#3296)`
     for PR #3298) or no number at all → fix it in that package's release PR.
   - **Next version** — breaking → major (minor while 0.x); new API, option or
     behaviour (`Add …`) → minor; only fixes or a widened dependency constraint →
     patch. For patrol, patrol_finders and patrol_log, cross-check with
     dart-apitool — locally, since its CI check only runs on PRs (command in
     `packages.md`).
   - **Cascade** — when a dependency has unreleased changes its dependents need,
     it is released first, and each dependent's constraint is bumped in that
     dependent's own release PR once the dependency is on pub.dev. Two ways this
     happens: a
     dependent uses the new API (grep it for the new symbols), or a third-party
     constraint was widened in both and is useless until the dependency ships.
     Example: patrol allowed `equatable` 3.x, but patrol_log 0.10.1 on pub.dev
     still pinned `equatable: ^2.1.0`, so patrol_log 0.10.2 had to go out first
     and patrol, patrol_finders and patrol_cli needed `patrol_log: ^0.10.2`.
   - **Paired features** — patrol + patrol_cli changes that only work together
     are released back to back (two PRs, merged and tagged together), and an
     opt-in one gets a row in the compatibility table's opt-in section (see
     [Prepare](#2-prepare), step 4).
   - **Stray prerelease tags** (e.g. `patrol-v4.11.0-dev.1` from a web branch that
     never reached master) — not a blocker, but pub.dev shows them as the newest
     upload and the stable version must be above them. Mention them.
3. Report with the [template](#report-template).

### PRs close to merging

1. Run [`scripts/pr-status.sh`](scripts/pr-status.sh). It buckets every open PR:
   - **ready** — approved, no open threads, no real CI failures;
   - **near** — approved with open threads, or ≤ 400 changed lines with no
     review yet and no real failures;
   - **work** — conflicts, changes requested, waiting on the author (a reviewer
     commented after the last push), or real failures;
   - **far** — drafts and large unreviewed PRs.

   Failing checks listed in `ci-noise.md` are split out as `noise`.
2. Refine before reporting — the buckets are a first pass:
   - For ready/near PRs, read the open threads
     (`gh api repos/leancodepl/patrol/pulls/<n>/comments`). Bot threads (Copilot)
     are sometimes real bugs — say which.
   - A "real" failure can still be a known flake that only shows at step level
     (e.g. Linux `patrol develop` dying in `melos bootstrap`). For a PR that is
     otherwise ready, check the failed step: `gh run view <run-id> --log-failed | tail -50`.
   - An approval older than the last push, or followed by new threads from the
     same reviewer, is stale even though GitHub still says `APPROVED`.
   - Conflicts are mostly `CHANGELOG.md` and trivial; name the file when you can.
3. Tie it to the release: flag PRs touching a package that's about to be
   released (the `packages` column) — they land first or wait for the next one.
   Ask the user which PRs must land; don't guess. Flag PRs that raise the
   minimum Dart or Flutter version: they change the compatibility table.
4. Report with the [template](#report-template).

## 2. Prepare

Before editing, confirm in one message: packages and versions, PRs to wait for,
and whether anything raises the minimum Flutter or Dart version.

**One release PR per package**, in the release order from `packages.md`. A
package that needs a sibling's new version (see "When to bump a sibling
constraint" in `packages.md`) gets its PR only once that sibling is on pub.dev:
branch it from `origin/master` after the sibling's PR is merged and tagged. That
way every PR resolves against published versions, and CI's pub.dev jobs pass.
Packages that don't need a new sibling version can have their PRs open at the
same time. Prepare what can be opened now, list the ones that wait (and on
what), and stop; preparing those is a later run, after [Publish](#3-publish).

For each PR:

1. **Branch** from `origin/master` in a new worktree: `release/<pkg>-X.Y.Z`
   (precedent `release/patrol_mcp-0.2.1`). The `release/` prefix makes the
   semver check fail when a pubspec version is below dart-apitool's
   recommendation.
2. **Versions** — bump every version file of the package (`packages.md` lists
   the extra ones: `constants.dart` for patrol_cli, `bin/patrol_mcp.dart` for
   patrol_mcp).
3. **Changelogs** — rename `## Unreleased` to `## X.Y.Z` (don't add a new empty
   `## Unreleased`). Then edit the entries:
   - every entry ends with the PR number, `(#1234)`;
   - add the missing entries Status found;
   - trim long entries to what a user needs; link docs instead of explaining;
   - order: additions and widened constraints first, fixes after.
4. **Constraints and compatibility**:
   - In this package's PR, bump its constraint on a sibling (`patrol_log:
     ^0.10.2`) when it needs the sibling's new version, which must already be on
     pub.dev. "When to bump a sibling constraint" in `packages.md` lists the
     cases; don't bump it otherwise. The pubspec change needs a changelog entry
     (`tool/check_changelog.sh`), e.g. "Require patrol_log ^0.10.2, which allows
     equatable 3.x".
   - The compatibility table lives in patrol_cli, so its changes go in
     **patrol_cli's** PR. If only patrol is released and the table must change,
     patrol_cli needs a release too.
   - **Stable patrol / patrol_cli releases only** (skip for `-dev.N`): review
     `versionCompatibilityList` in
     `packages/patrol_cli/lib/src/compatibility_checker/version_compatibility.dart`.
     Normally the open `X+` row already covers the new pair. **Split it** — close
     the open row at the last released versions and open a new `<cli>+` /
     `<patrol>+` row — when patrol_log gets a 0.x minor bump (`^0.10.0` and
     `^0.9.0` don't overlap; precedents 731e1d4a0, b00954520), when the
     patrol ↔ patrol_cli contract changes incompatibly, or when the minimum Flutter
     rises.
   - A new paired opt-in feature gets a row in `_optInFeaturesSection` in
     `generate_compatibility_table.dart` (edited by hand).
   - Regenerate the docs page and test:
     `cd packages/patrol_cli && dart run lib/src/compatibility_checker/generate_compatibility_table.dart && dart test test/compatibility_checker/`
     (writes `docs/documentation/compatibility-table.mdx`).
5. **Commit** — on CI's Flutter (prepend `~/fvm/versions/<ver>/bin` to `PATH`),
   run `melos bootstrap` from the repo root. Commit the edits above together
   with the lockfile changes it makes (e.g. `dev/e2e_app/pubspec.lock`), and
   only those: `Prepare patrol_log 0.10.2 release`. The checks in the next step
   read the commit, not the working tree. Release PRs open at the same time can
   conflict in the lockfiles; after one merges, merge `origin/master` into the
   others and re-run `melos bootstrap`.
6. **Verify the commit**, still on CI's Flutter; amend it with any fixes:
   - the publish dry-run the package's prepare workflow uses
     (`flutter pub publish --dry-run` or `dart pub publish --dry-run`, see
     `packages.md`). For patrol, the file list must include
     `skills/patrol-*/SKILL.md`. The dry-run resolves through melos' path
     overrides, so it can't catch a too-low sibling floor;
   - `scripts/check-floors.sh <pkg>`, which analyzes the package against its
     sibling floors from pub.dev. A "not on pub.dev yet" line means a sibling
     this PR needs isn't published, so the PR is early;
   - `tool/check_changelog.sh`, then `scripts/unreleased.sh <pkg>` again with
     `BASE=HEAD`: the package shows its new version and no Unreleased section.
7. **Open the PR** against `master`. Body: the version, two or three
   highlights, the tag to push after merging, the other release PRs of this
   round (links, and which wait for this one), and what you verified.
8. **Expect on CI** — the semver check is enforced on this branch, so a red one
   is real; `pana` is noise as usual. If `Resolve against published
   dependencies` or `Smoke (… patrol_cli)` fails in pub get with "doesn't match
   any versions", a sibling this PR needs isn't on pub.dev yet. **Stop here.**
   Tagging is a separate run.

## 3. Publish

Only after a release PR is merged and the user says go.

1. `git fetch origin --tags`. Each tag goes on its own release PR's merge
   commit on master: `gh pr view <n> --json mergeCommit --jq .mergeCommit.oid`.
   Tags are lightweight.
2. Print the plan — one tag per merged release PR, in dependency order from
   `packages.md` — and ask for a yes.
3. For each tag:
   ```bash
   git tag <pkg>-vX.Y.Z <merge-sha>
   git push origin <pkg>-vX.Y.Z
   gh run list --repo leancodepl/patrol --workflow <pkg>-publish.yaml --limit 1   # then: gh run watch <id>
   curl -s https://pub.dev/api/packages/<pkg> | jq -r .latest.version
   ```
   A publish takes about 3 minutes. **Push a dependent's tag only once pub.dev
   serves its dependencies' new versions** — its publish resolves them from
   pub.dev and fails otherwise. Unrelated packages can go in parallel.
4. Afterwards: each publish workflow creates a GitHub release
   (`gh release list --repo leancodepl/patrol --limit 8`) and posts to Slack for
   non-prereleases. The Latest/Pre-release flags have been odd before
   (`patrol_cli-v4.9.0-dev.2` marked Latest, `patrol_mcp-v0.2.1` Pre-release) —
   report them, don't change them unasked. Compare the pub.dev score with the
   previous version a while later:
   `curl -s https://pub.dev/api/packages/<pkg>/score | jq '{grantedPoints, maxPoints}'`.
   Then say which waiting release PRs can now be prepared; preparing them is a
   new Prepare run.
5. If a publish fails, don't delete or move the tag. Read the log
   (`gh run view <id> --log-failed`), report it, and re-run only with the user's
   OK (`gh run rerun <id> --failed`).

## Report template

Keep it scannable: tables and one line per PR, no restating of changelogs.

```
**To release** (origin/master <short-sha>)

| Package | pub.dev | Next | Why | Blocked by |
|---|---|---|---|---|
| patrol_log | 0.10.1 | 0.10.2 | equatable 3.x, @override fix | — |
| patrol | 4.10.0 | 4.11.0 | macOS automation, skills, BS coverage | patrol_log 0.10.2 |
| adb | 0.6.1 | — | nothing new | |

Order (one PR each): patrol_log → patrol_finders → patrol → patrol_cli
Open now: patrol_log; patrol waits for patrol_log 0.10.2 on pub.dev
Fix in the release PRs: entries without PR numbers (#3251, #3242), #3298 cites the issue
Stray prerelease tags: patrol-v4.11.0-dev.1 (web branch)

**PRs**
Ready: #3298 patrol_mcp shell fix — approved, green
Near: #3333 hot-restart guard — no review; Copilot's `_testState` thread looks real
Needs work: #3287 — 9 threads, waiting on author since 10-27
Touches a released package: #3326 (patrol_log) — land before 0.10.2 or wait
Far: #3280, #3282, drafts
```

## Keeping this skill current

When a new failing check turns out to be noise, add it to `ci-noise.md` and to
the `noise` function in `scripts/pr-status.sh`. When a package or a version file
is added, update `packages.md` and `extra_version_file` in
`scripts/unreleased.sh`.
