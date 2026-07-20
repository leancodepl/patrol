---
name: fix-issue
description: Workflow for fixing a reported bug in the Patrol monorepo — reproduce, locate the right package, fix without regressions, verify, and open a PR. Use when asked to fix a GitHub issue (e.g. "fix issue #3101"), investigate a reported Patrol bug, or turn a bug report into a tested PR.
---

# Fixing a Patrol issue

A checklist for turning a Patrol bug report into a verified, review-ready PR.
This skill is **orchestration + repo-specific knowledge**. For canonical rules
that may change, read [`CONTRIBUTING.md`](../../../CONTRIBUTING.md) — do not
duplicate it from memory.

Work through the phases in order. Don't skip reproduction: a fix you can't
reproduce failing first is a fix you can't prove works.

## 1. Understand the issue

1. Read the issue (`gh issue view <n> --repo leancodepl/patrol`, including
   comments). Extract: exact command/API, config used, versions, and the
   expected vs actual behaviour.
2. **Don't change the Flutter/Dart SDK version** to reproduce unless the issue
   is specifically about a version. Reproduce on the versions the reporter used.
3. Map the bug to the right package under `packages/` before touching code:

   | Symptom | Package |
   |---|---|
   | `patrol test` / `patrol build` / `patrol develop`, bundle generation, CLI flags, device handling | `patrol_cli` |
   | `PatrolTester`/`$`/finders behaviour | `patrol_finders` |
   | Native automation (permissions, notifications), `PatrolBinding`, platform channels | `patrol` (+ its `android/` Kotlin & `darwin/` Swift) |
   | DevTools extension | `patrol_devtools_extension` |
   | Test run logs / reporting | `patrol_log` |
   | MCP server | `patrol_mcp` |
   | Native method contracts (generated) | edit `schema.dart`, run `./gen_from_schema` — see CONTRIBUTING |

## 2. Reproduce locally

Prefer the repo's existing fixtures over hand-built throwaway projects:

- **`dev/e2e_app`** — a ready-made Flutter app wired for Patrol. Use it as the
  target project when reproducing CLI/runtime bugs (it's the `cwd` in the
  documented VS Code / Android Studio launch configs).
- **`dev/cli_tests`** — Dart-driven CLI integration tests
  (e.g. `patrol_develop_test.dart`). A good place to add an end-to-end repro.

Only scaffold a separate minimal project when the bug needs a layout the
fixtures don't have (e.g. a pub workspace, a custom `test_directory`, paths
containing unusual characters). Keep it minimal and delete it afterwards.

### Running your local patrol_cli (the important gotcha)

Per CONTRIBUTING, two ways to run a local build:

```bash
# A) activate from the working tree as the global `patrol`
dart pub global activate --source path packages/patrol_cli
# B) run directly without activating
dart run packages/patrol_cli <command...>
```

⚠️ **`dart pub global activate --source path` snapshots the code at activation
time.** After every change to `patrol_cli`, re-run it or your `patrol` binary
still runs the old code. `dart run` (B) always uses current sources — prefer it
while iterating.

To let a teammate test a branch without checking it out:

```bash
dart pub global activate --source git https://github.com/leancodepl/patrol.git \
  --git-ref <branch> --git-path packages/patrol_cli
```

## 3. Fix without regressions

1. Read the **whole** target file and its existing tests before editing — the
   tests encode behaviour you must not break (e.g. `test_bundler_test.dart`
   pins relative-path, absolute-path, and web-bundle output).
2. Make the smallest change that fixes the root cause. Match surrounding style.
3. Follow existing conventions in the file/package — e.g. `patrol_cli` resolves
   relative paths against the **project root**, not the process CWD
   (see `TestFinder`).
4. Branch name: `fix/<short-description>` (created off `master`).

## 4. Verify

In order of strength:

1. **Unit tests** for the changed package:
   `cd packages/<pkg> && dart test test/<area>_test.dart` — then the package's
   full suite. Add a test that **fails before** your fix and **passes after**;
   cover the edge case from the issue plus the previously-working cases.
2. `dart analyze` and `dart format` on changed files (CI enforces both).
3. **Exercise the real code path** when behaviour depends on the filesystem or
   environment: a tiny harness that drives the actual classes (e.g.
   `TestFinder` → `TestBundler`) against a real `LocalFileSystem`, optionally
   with `Directory.current` set elsewhere, is stronger than in-memory tests for
   CWD/path bugs.
4. **End-to-end** with `dev/e2e_app` (or your repro) using your local CLI
   (`patrol build <platform>` / `patrol test`) to confirm the user-facing
   symptom is gone and untouched configs still work.

## 5. Changelog + PR

1. **Required:** add an entry to the changed package's `CHANGELOG.md` under
   `## Unreleased` (create that heading if missing). The number in brackets is
   the **PR number**, not the issue: `- Fix ... (#<PR>)`. The issue is linked
   from the PR description instead. Since the PR number isn't known until the
   PR exists, add the entry first, open the PR, then amend the entry with the
   real PR number.
2. Commit (`fix(<package>): <summary>`), then open the PR against `master`:
   `gh pr create --base master`. In the body, link the issue it resolves
   (e.g. `Closes #<issue>`) and summarise the change and how you verified it.
3. Note from CONTRIBUTING: the Android emulator workflows fail for outside
   contributors due to permissions and must be re-run by a maintainer — don't
   panic if those are red.

Opening the PR is the end of this workflow. **Stop here — don't wait on
review.**

## Later (separate run): addressing review

Review is **asynchronous** — an automated **Gemini Code Assist** review lands a
few minutes after the PR opens, and human reviewers later still. Don't poll or
idle waiting for it inside the same run; come back when notified (or when the
user asks to address comments). When you do:

- For each comment, first decide whether it's *correct* (check the code/flow),
  then either fix it and reply pointing at the commit, or reply explaining why
  it doesn't apply. Don't silently apply suggestions you can't justify — the
  bot is sometimes wrong.
- Read comments / reply in-thread:
  - `gh pr view <pr> --json reviews` and
    `gh api repos/leancodepl/patrol/pulls/<pr>/comments`
  - `gh api repos/leancodepl/patrol/pulls/<pr>/comments/<comment_id>/replies -f body="..."`
