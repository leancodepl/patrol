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
dart run skills@ get --agent claude -p patrol --all

# Cursor (.cursor/skills/)
dart run skills@ get --agent cursor -p patrol --all

# Antigravity, Gemini CLI and others (.agents/skills/)
dart run skills@ get --agent generic -p patrol --all
```

Drop `-p patrol` to also pick up skills from your other dependencies, and `--all` to pick skills
interactively. The installed skills match the `patrol` version you depend on — rerun the same
command after upgrading `patrol` to update them, and `dart run skills@ prune` removes them once
`patrol` is gone.

On a Dart SDK without the `dart run <package>@` syntax, activate the CLI globally instead:

```bash
dart pub global activate skills
dart pub global run skills get --agent claude -p patrol --all
```

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
| [patrol-test-architecture](patrol-test-architecture/SKILL.md) | Write Patrol E2E tests using LeanCode's recommended architecture (Modules, System, ApiClients) with shared test keys. | Add a checkout test following our modular Patrol architecture |
