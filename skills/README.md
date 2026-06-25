# Patrol Agent Skills

Agent skills for writing [Patrol](https://patrol.leancode.co/) end-to-end tests, maintained by the
Patrol team. A skill is a folder of focused instructions in the open
[Agent Skills](https://agentskills.io/) format (`SKILL.md`) that teaches an AI coding agent *how* to
perform a specific task following best practices — reducing mistakes and making the agent reliably
complete the work.

These skills are for **users of Patrol** writing tests in their own projects.

## Installation

Install the skills into your project with the [`skills`](https://github.com/vercel-labs/skills) CLI,
targeting the agent(s) you use. Claude Code reads `.claude/skills/`, while Cursor, Codex, GitHub
Copilot, Antigravity, Gemini CLI and most others share `.agents/skills/` (the `universal` target):

```bash
# Claude Code
npx skills add leancodepl/patrol -s '*' -a claude-code -y

# Cursor, Codex, GitHub Copilot, Antigravity, Gemini CLI, … (the "universal" location)
npx skills add leancodepl/patrol -s '*' -a universal -y

# …or cover both at once
npx skills add leancodepl/patrol -s '*' -a claude-code universal -y
```

To update later:

```bash
npx skills update
```

> **Claude Code:** `npx skills update` can write to `.agents/skills` instead of `.claude/skills`
> (where Claude Code reads them), due to
> [vercel-labs/skills#744](https://github.com/vercel-labs/skills/issues/744). If your skills stop
> being picked up, regenerate them with
> `npx skills add leancodepl/patrol -s '*' -a claude-code -y`.

## Available skills

| Skill | Description | Example prompt |
|---|---|---|
| [patrol-write-test](patrol-write-test/SKILL.md) | Write Patrol E2E tests — order of actions, Patrol API and assertion rules, native dialog handling, and test-key conventions. | Write a Patrol test that logs in and verifies the home screen |
| [patrol-test-architecture](patrol-test-architecture/SKILL.md) | Write Patrol E2E tests using LeanCode's recommended architecture (Modules, System, ApiClients) with shared test keys. | Add a checkout test following our modular Patrol architecture |
