#!/usr/bin/env bash
#
# Ensures that a pull request touching a package's source also updates that
# package's CHANGELOG.md. Run locally with:
#
#   tool/check_changelog.sh [base-ref]
#
# `base-ref` defaults to `origin/master`. The set of changed files is computed
# as the diff between the merge-base of `base-ref` and HEAD.
#
# A package is any `packages/*` directory that has a CHANGELOG.md. A change
# requires a changelog entry unless every changed file in that package is one
# of: the CHANGELOG.md itself, a test, an example, or a Markdown doc.
#
set -euo pipefail

cd "$(dirname "$0")/.."

base_ref="${1:-origin/master}"

changed_files="$(git diff --name-only "$base_ref"...HEAD)"

fail=0
err() { echo "❌ $1"; fail=1; }

# Files that don't warrant a changelog entry on their own.
is_exempt() {
  local file="$1" pkg="$2"
  case "$file" in
    "$pkg/CHANGELOG.md") return 0 ;;
    "$pkg"/test/*) return 0 ;;
    "$pkg"/*/test/*) return 0 ;;
    "$pkg"/example/*) return 0 ;;
    "$pkg"/integration_test/*) return 0 ;;
    *.md) return 0 ;;
  esac
  return 1
}

for changelog in packages/*/CHANGELOG.md; do
  pkg="$(dirname "$changelog")"
  name="$(basename "$pkg")"

  changelog_changed=0
  source_changed=0

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    case "$file" in
      "$pkg"/*) ;;
      *) continue ;;
    esac

    if [ "$file" = "$changelog" ]; then
      changelog_changed=1
    fi
    if ! is_exempt "$file" "$pkg"; then
      source_changed=1
    fi
  done <<< "$changed_files"

  if [ "$source_changed" -eq 1 ] && [ "$changelog_changed" -eq 0 ]; then
    err "$name: source changed but $changelog was not updated. Add an entry under '## Unreleased' (or label the PR 'skip changelog' if this change is not user-facing)."
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "✅ CHANGELOG check passed"
fi

exit "$fail"
