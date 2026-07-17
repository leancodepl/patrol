# Contributor Agent Skills

Skills for **developing Patrol itself** — the framework, the CLI, native automation, and docs.
They're consumed by contributors working in this repository and are **not** published to Patrol
users. (User-facing skills for *writing tests* live in [`../../skills/`](../../skills/) and ship via
`npx skills add leancodepl/patrol/skills` — scoped to that subdirectory, so the contributor skills
here are never pulled into a consumer's project.)

This directory (`.agents/skills/`) is the canonical location, read by Codex, GitHub Copilot, and
Antigravity. `.claude/skills` is a symlink to it, so Claude Code and Cursor read the same source —
one source of truth, no duplication. Skills follow the open
[Agent Skills](https://agentskills.io/specification) standard (a folder with a `SKILL.md` entrypoint,
plus an optional `scripts/` directory for executable helpers).

## Available skills

| Skill | Description | Example prompt |
|---|---|---|
| [fix-issue](fix-issue/SKILL.md) | Turn a reported Patrol bug into a verified PR — reproduce, locate the right package, fix without regressions, verify, and open the PR. | Fix issue #3101 |
