# Patrol Agent Skills

Agent skills for writing [Patrol](https://patrol.leancode.co/) end-to-end tests, maintained by the
Patrol team. A skill is a folder of focused instructions in the open
[Agent Skills](https://agentskills.io/) format (`SKILL.md`) that teaches an AI coding agent *how* to
perform a specific task following best practices — reducing mistakes and making the agent reliably
complete the work.

These skills are for **users of Patrol** writing tests in their own projects.

## Installation

### From your `patrol` dependency (recommended)

The skills ship inside the [`patrol`](https://pub.dev/packages/patrol) package, so the Dart
[`skills`](https://pub.dev/packages/skills) CLI finds them in your dependency tree. Run it in your
project root:

```bash
# Claude Code (.claude/skills/)
dart run skills@ get --agent claude -p patrol -s patrol-setup -s patrol-write-test

# Cursor (.cursor/skills/)
dart run skills@ get --agent cursor -p patrol -s patrol-setup -s patrol-write-test

# Antigravity, Gemini CLI and others (.agents/skills/)
dart run skills@ get --agent generic -p patrol -s patrol-setup -s patrol-write-test
```

If your Patrol tests follow LeanCode's modular architecture (Modules, System, ApiClients), or you
want to introduce it, add `-s patrol-test-architecture` — it builds on `patrol-write-test`. To
install every skill, pass `--all` instead of the `-s` options. With neither, the CLI opens an
interactive picker — in a terminal only; without one, it just lists the available skills. Without
`-p patrol`, `--all` and the picker also cover skills from your other dependencies.

The installed skills match the `patrol` version you depend on — rerun the same command after
upgrading `patrol` to update them, and `dart run skills@ prune` removes them once `patrol` is gone.

**Dart SDK requirements.** `dart run skills@` needs Dart 3.12 or newer. The `skills` CLI itself
supports Dart 3.10 and 3.11 too — activate it globally there:

```bash
dart pub global activate skills
dart pub global run skills get --agent claude -p patrol -s patrol-setup -s patrol-write-test
```

On older SDKs, install the skills [from GitHub](#from-github) instead.

### From GitHub

Alternatively, install the skills straight from this repository with the
[`skills`](https://github.com/vercel-labs/skills) CLI (npm), targeting the agent(s) you use. Claude
Code reads `.claude/skills/`, while Cursor, Codex, GitHub Copilot, Antigravity, Gemini CLI and most
others share `.agents/skills/` (the `universal` target):

```bash
# Claude Code
npx skills add leancodepl/patrol/skills -s '*' -a claude-code -y

# Cursor, Codex, GitHub Copilot, Antigravity, Gemini CLI, … (the "universal" location)
npx skills add leancodepl/patrol/skills -s '*' -a universal -y

# …or cover both at once
npx skills add leancodepl/patrol/skills -s '*' -a claude-code universal -y
```

These track `master` rather than your `patrol` version. To update later:

```bash
npx skills update
```

> **Claude Code:** `npx skills update` can write to `.agents/skills` instead of `.claude/skills`
> (where Claude Code reads them), due to
> [vercel-labs/skills#744](https://github.com/vercel-labs/skills/issues/744). If your skills stop
> being picked up, regenerate them with
> `npx skills add leancodepl/patrol/skills -s '*' -a claude-code -y`.

## Available skills

| Skill | Description | Example prompt |
|---|---|---|
| [patrol-setup](patrol-setup/SKILL.md) | Set up Patrol E2E testing in a Flutter project for the first time (Android only) — pubspec `patrol` block, native Android wiring, and a first passing test on an Android emulator. | Set up Patrol in this project and get a first test passing |
| [patrol-write-test](patrol-write-test/SKILL.md) | Write Patrol E2E tests — order of actions, Patrol API and assertion rules, native dialog handling, and test-key conventions. | Write a Patrol test that logs in and verifies the home screen |
| [patrol-test-architecture](patrol-test-architecture/SKILL.md) | Add-on to patrol-write-test: LeanCode's recommended test architecture (Modules, System, ApiClients) with per-feature keys.dart files. Install it together with patrol-write-test. | Add a checkout test following our modular Patrol architecture |
| [patrol-migrate-from-maestro](patrol-migrate-from-maestro/SKILL.md) | Migrate Maestro UI flows to Patrol tests — inventory, command mapping, widget keys in place of text selectors, JS hooks moved to Dart, and every migrated test proven green. Uses patrol-setup and patrol-write-test. | Migrate our Maestro flows in `maestro/` to Patrol |
