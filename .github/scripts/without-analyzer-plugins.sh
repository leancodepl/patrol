#!/usr/bin/env bash
# Runs the given command with the `plugins:` list removed from
# ./analysis_options.yaml, then restores the file.
#
# custom_lint is a legacy analyzer plugin and cannot start inside the AOT
# analysis server that `dart analyze` uses. When it reports that failure,
# `dart analyze` exits non-zero with the error on stderr only, and
# `pub publish --dry-run` turns that into a warning with an empty issue list.
# custom_lint rules are checked by `dart run custom_lint`, which needs the
# plugin entry, so the entry stays in the committed file.
#
# skip-worktree keeps the edit out of `git status`, which pub's validator
# reports as a warning for files in the archive.

set -euo pipefail

options=analysis_options.yaml
backup="$(mktemp)"
cp "$options" "$backup"

restore() {
  git update-index --no-skip-worktree "$options"
  cp "$backup" "$options"
  rm -f "$backup"
}

git update-index --skip-worktree "$options"
trap restore EXIT

# An `analyzer:` key left empty would override the included options.
perl -0pi -e 's/\n  plugins:\n(?:    - .*\n)+/\n/; s/^analyzer:\n(?!  )//m' "$options"
if cmp -s "$options" "$backup"; then
  echo "::error::no analyzer plugins block in $PWD/$options"
  exit 1
fi

"$@"
