# Known CI noise

Failing checks that usually say nothing about the PR. `scripts/pr-status.sh`
filters the first group automatically (its `noise` function); the rest only show
at step level, so check the log before calling a PR blocked.

## Filtered by `pr-status.sh`

| Check | Why it fails | When it is real |
|---|---|---|
| `pana (<pkg>)` | fails on most PRs: patrol scores 150/160 on every PR (Linux/Windows unsupported), and patrol_cli, patrol_mcp and patrol_finders often lose points too | the score is lower than on other recent PRs for the same package |
| `Check semver (…)` on non-`release/*` branches | runs from before 2026-10-20 failed until the version was bumped; newer runs only report the recommended version as the `semver (<pkg>)` status | on a `release/*` branch it enforces the version: red there means the pubspec version is too low |
| `Flutter <ver> on API <n>`, `Flutter <ver> webview on emulator.wtf` on **fork** PRs | the emulator workflows fail for contributors without write access (CONTRIBUTING); a maintainer has to re-run them | same jobs on a leancodepl branch |

## Check the failed step first

| Symptom | Verdict |
|---|---|
| `Test patrol develop on Linux` fails in `melos bootstrap` after ~10 s | infra flake; re-run |
| web job hangs in `flutter pub get` until timeout | flake; re-run |
| Gradle fails transforming a Flutter engine jar | flake; re-run |
| `dart analyze` fails intermittently inside `flutter pub publish --dry-run`, on several unrelated branches at once | flake; re-run |
| docs Deploy Preview fails on a GitHub API rate limit | flake; passes later |
| a PR that changes CI workflows, the Dart SDK floor or the Flutter pin fails its e2e jobs | `pull_request_target` workflows run from master, not the PR (e.g. #3323 on Flutter 3.38 vs its 3.44). Verify after merge or via `workflow_dispatch` on the branch |

## Local-only differences

| Symptom | Cause |
|---|---|
| `flutter pub publish --dry-run` exits 65 locally but passes on CI | newer pub treats "latest published version (a stray `-dev` prerelease) is higher" as a warning; CI's Flutter treats it as a hint. Run on CI's Flutter via fvm |
| lockfiles change after `flutter pub get` | newer local Flutter; don't commit them, regenerate on CI's version |
| `gh pr list --json statusCheckRollup` returns "unexpected end of JSON input" | the query times out on this repo; use `scripts/pr-status.sh` |
