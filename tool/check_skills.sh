#!/usr/bin/env bash
#
# Validates the Patrol agent-skills setup. Run locally with: tool/check_skills.sh
#
# Checks:
#   1. `.claude/skills` is a symlink resolving to `.agents/skills`, so Claude Code and
#      Cursor read the same source as the tools that read `.agents/skills` natively
#      (Codex, GitHub Copilot, Antigravity, …). This is the only per-tool wiring in the
#      repo; every skill flows through `.agents/skills`, so there is nothing per-tool to
#      forget when adding one.
#   2. Every `SKILL.md` under `skills/` (the published user catalog) and `.agents/skills/`
#      (contributor skills) has valid frontmatter: a `name` that matches its folder and is
#      kebab-case, plus a non-empty `description` — the two fields the open Agent Skills
#      standard (agentskills.io) requires.
#
set -euo pipefail

cd "$(dirname "$0")/.."

fail=0
err() { echo "❌ $1"; fail=1; }

# 1. .claude/skills symlink -> .agents/skills
link=".claude/skills"
expected="../.agents/skills"
if [ ! -L "$link" ]; then
  err "$link must be a symlink to '$expected' (so Claude Code/Cursor read .agents/skills)"
elif [ "$(readlink "$link")" != "$expected" ]; then
  err "$link points to '$(readlink "$link")', expected '$expected'"
elif [ ! -d "$link" ]; then
  err "$link is a broken symlink (does not resolve to a directory)"
else
  echo "✓ $link -> $expected"
fi

# 2. SKILL.md frontmatter validity
shopt -s nullglob
count=0
for skill in skills/*/SKILL.md .agents/skills/*/SKILL.md; do
  count=$((count + 1))
  folder=$(basename "$(dirname "$skill")")
  ok=1

  if [ "$(head -n1 "$skill" | tr -d '\r')" != "---" ]; then
    err "$skill: must start with '---' (YAML frontmatter)"
    continue
  fi

  fm=$(awk 'NR>1 && /^---[[:space:]]*\r?$/{exit} NR>1{print}' "$skill" | tr -d '\r')
  name=$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -n1 | sed 's/[[:space:]]*$//')
  desc=$(printf '%s\n' "$fm" | sed -n 's/^description:[[:space:]]*//p' | head -n1)

  [ -n "$name" ] || { err "$skill: frontmatter missing 'name:'"; ok=0; }
  [ -n "$desc" ] || { err "$skill: frontmatter missing 'description:'"; ok=0; }
  if [ -n "$name" ] && [ "$name" != "$folder" ]; then
    err "$skill: name '$name' must match its folder '$folder'"; ok=0
  fi
  if [ -n "$name" ] && ! printf '%s' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    err "$skill: name '$name' must be kebab-case"; ok=0
  fi

  if [ "$ok" -eq 1 ]; then echo "✓ $skill"; fi
done

if [ "$count" -eq 0 ]; then
  err "no SKILL.md found under skills/ or .agents/skills/"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "Agent-skills check FAILED."
  exit 1
fi
echo "Agent-skills check passed (${count} skill(s) validated)."
