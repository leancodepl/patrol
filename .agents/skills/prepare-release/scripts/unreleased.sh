#!/usr/bin/env bash
# What each publishable package would ship in its next release: versions
# (pubspec, tags, pub.dev), the `## Unreleased` changelog section, merged PRs
# the section doesn't mention, and workspace dependencies with pending changes.
#
# Read-only. Reads packages from $BASE (default origin/master), not the working
# tree, so run `git fetch origin --tags` first. Needs git, jq and curl.
#
# Usage: unreleased.sh [package...]   (default: every package without
#                                      `publish_to: none`)
set -euo pipefail

base="${BASE:-origin/master}"
cd "$(git rev-parse --show-toplevel)"

show() { git show "$base:$1" 2>/dev/null; }

all=()
for dir in $(git ls-tree --name-only "$base" packages/); do
  show "$dir/pubspec.yaml" | grep -q '^publish_to: *none' && continue
  show "$dir/pubspec.yaml" >/dev/null || continue
  all+=("${dir#packages/}")
done

packages=("$@")
[ ${#packages[@]} -eq 0 ] && packages=("${all[@]}")

pubspec_version() { show "packages/$1/pubspec.yaml" | awk '/^version:/ { print $2; exit }'; }

# The `## Unreleased` section, if the changelog starts with one. awk reads to the
# end: exiting early can SIGPIPE `git show`, which pipefail turns into a failure.
unreleased_section() {
  show "packages/$1/CHANGELOG.md" | awk '
    /^## / { n++; if (n == 1) u = ($0 ~ /Unreleased/); next }
    n == 1 && u'
}

# Files besides pubspec.yaml that hold the version and must match it.
extra_version_file() {
  case "$1" in
    patrol_cli) echo packages/patrol_cli/lib/src/base/constants.dart ;;
    patrol_mcp) echo packages/patrol_mcp/bin/patrol_mcp.dart ;;
  esac
}

for p in "${packages[@]}"; do
  echo "== $p"

  version="$(pubspec_version "$p")"
  stable_tag="$(git tag -l "$p-v*" | grep -v -e '-dev\.[0-9]*$' | sort -V | tail -n 1 || true)"
  pub="$(curl -fsS "https://pub.dev/api/packages/$p" 2>/dev/null \
    | jq -r '"\(.latest.version) (newest upload \(.versions | last | .version))"' 2>/dev/null \
    || echo "unavailable")"
  echo "  versions: pubspec $version · last stable tag ${stable_tag:-none} · pub.dev $pub"

  if file="$(extra_version_file "$p")" && [ -n "$file" ]; then
    other="$(show "$file" | sed -n "s/^const version = '\(.*\)';.*/\1/p")"
    [ "$other" != "$version" ] && echo "  !! $file has version '$other', pubspec has $version"
  fi

  # Prerelease tags newer than the last stable release, cut from branches that
  # never reached master (e.g. a web preview): pub still sees them as the newest
  # upload, which local tooling can trip over.
  stray=()
  for tag in $(git tag -l "$p-v*-dev.*"); do
    tag_version="${tag#"$p-v"}"
    if [ -n "$stable_tag" ]; then
      newest="$(printf '%s\n' "${stable_tag#"$p-v"}" "${tag_version%%-*}" | sort -V | tail -n 1)"
      [ "$newest" = "${stable_tag#"$p-v"}" ] && continue
    fi
    git merge-base --is-ancestor "$tag" "$base" 2>/dev/null || stray+=("$tag")
  done
  [ ${#stray[@]} -gt 0 ] && echo "  !! prerelease tags not on $base: ${stray[*]}"

  # Workspace dependencies that have unreleased changes of their own: their
  # release may have to go first, and this package's constraint may need a bump.
  deps="$(show "packages/$p/pubspec.yaml" | awk '
    /^dependencies:/ { f = 1; next }
    /^[^ #]/ { f = 0 }
    f && /^  [a-z_]+: *[^ ]/ { sub(/^  /, ""); print }')"
  dep_notes=()
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    name="${line%%:*}"
    for w in "${all[@]}"; do
      [ "$w" = "$name" ] || continue
      note="$line (workspace $(pubspec_version "$name")"
      [ -n "$(unreleased_section "$name" | grep '^- ' || true)" ] && note="$note, has Unreleased changes"
      dep_notes+=("$note)")
    done
  done <<< "$deps"
  [ ${#dep_notes[@]} -gt 0 ] && printf '  depends on: %s\n' "${dep_notes[@]}"

  section="$(unreleased_section "$p")"
  entries="$(grep -c '^- ' <<< "$section" || true)"
  if [ "$entries" -eq 0 ]; then
    echo "  Unreleased: none"
  else
    echo "  Unreleased: $entries entr$([ "$entries" -eq 1 ] && echo y || echo ies)"
    # Top-level entries (with their continuation lines) that cite no PR.
    awk '
      function flush() {
        if (entry != "" && entry !~ /#[0-9]+/) print "    no PR number: " substr(entry, 3, 100)
        entry = ""
      }
      /^- / { flush(); entry = $0; next }
      /^[[:space:]]/ && entry != "" { line = $0; gsub(/^[[:space:]]+/, " ", line); entry = entry line; next }
      { flush() }
      END { flush() }' <<< "$section"
  fi

  if [ -n "$stable_tag" ]; then
    # First-parent history, so each merged PR shows up as its merge commit.
    missing=()
    while IFS=$'\t' read -r sha subject; do
      [ -z "$sha" ] && continue
      pr="$(sed -n 's/^Merge pull request #\([0-9]*\).*/\1/p; s/.*(#\([0-9]*\))$/\1/p' <<< "$subject" | head -n 1)"
      if [ -z "$pr" ]; then
        missing+=("${sha:0:9} $subject (direct commit)")
        continue
      fi
      grep -qE "#$pr([^0-9]|$)" <<< "$section" && continue
      title="$(git log -1 --format=%b "$sha" | sed -n '/./{p;q;}')"
      missing+=("#$pr ${title:-$subject}")
    done < <(git log --first-parent --format='%H%x09%s' "$stable_tag..$base" -- "packages/$p")
    if [ ${#missing[@]} -gt 0 ]; then
      echo "  merged since $stable_tag, not cited in Unreleased (may be fine for CI/test/docs-only PRs):"
      printf '    %s\n' "${missing[@]}"
    fi
  fi
done
