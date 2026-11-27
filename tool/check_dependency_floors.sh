#!/usr/bin/env bash
#
# Analyzes a package against the lowest versions of its sibling dependencies
# (other packages in packages/) that its constraints allow, resolved from
# pub.dev. Run locally with:
#
#   tool/check_dependency_floors.sh <package>
#
# Every other check resolves the siblings through the path overrides that
# `melos bootstrap` writes to pubspec_overrides.yaml, and so does
# `pub publish --dry-run`. Users get no overrides, so a constraint whose floor
# lacks API the package calls goes unnoticed: patrol_cli shipped `adb: ^0.6.0`
# while calling `Adb.pull`, added in adb 0.6.1.
#
# A floor that isn't on pub.dev yet is accepted only if it is the sibling's
# version in this tree, i.e. on a branch stacked on the sibling's release,
# which is published first. It is then resolved from its path, and so are its
# own unpublished siblings.
#
# Rewrites the package's pubspec_overrides.yaml, pubspec.lock and
# analysis_options.yaml. Undo with `melos bootstrap` and
# `git checkout -- packages/<package>/analysis_options.yaml`.
#
set -euo pipefail

cd "$(dirname "$0")/.."

if [ $# -ne 1 ] || [ ! -f "packages/$1/pubspec.yaml" ]; then
  echo "Usage: $0 <package>" >&2
  exit 2
fi
pkg="$1"
pubspec="packages/$pkg/pubspec.yaml"

fail=0
err() { echo "❌ $1"; fail=1; }

# Sibling packages in the `dependencies:` of pubspec $1.
siblings() {
  awk '/^dependencies:/ { f = 1; next }
       /^[^ #]/ { f = 0 }
       f && /^  [a-z0-9_]+:/ { sub(/:.*/, "", $1); print $1 }' "$1" |
    while read -r dep; do
      if [ -f "packages/$dep/pubspec.yaml" ]; then echo "$dep"; fi
    done
}

# Version of sibling $1 in this tree.
local_version() {
  awk '/^version:/ { print $2; exit }' "packages/$1/pubspec.yaml"
}

# Lower bound of the constraint on $2 in the `dependencies:` of pubspec $1:
# 1.2.3 out of ^1.2.3, '>=1.2.3 <2.0.0' or 1.2.3.
constraint_floor() {
  awk -v dep="$2" '/^dependencies:/ { f = 1; next }
       /^[^ #]/ { f = 0 }
       f && $1 == dep ":" { $1 = ""; print; exit }' "$1" |
    sed -E "s/^ *['\"]?(\\^|>=)?//; s/[ <'\"].*//"
}

# Siblings resolved from their path, separated by spaces.
overrides=""

# Whether sibling $1 is resolved from its path.
overridden() {
  case " $overrides " in
    *" $1 "*) return 0 ;;
  esac
  return 1
}

# Whether version $2 of $1 is on pub.dev.
published() {
  local status
  status="$(curl -s -o /dev/null -w '%{http_code}' --retry 3 \
    "https://pub.dev/api/packages/$1/versions/$2")"
  case "$status" in
    200) return 0 ;;
    404) return 1 ;;
  esac
  echo "❌ pub.dev answered HTTP $status for $1 $2"
  exit 1
}

# Follows each sibling constraint: the package's own, then those of the
# siblings resolved from their path. Each edge is "<pubspec>:<sibling>".
direct="$(siblings "$pubspec")"
queue=""
for dep in $direct; do queue="$queue $pubspec:$dep"; done
while [ -n "$queue" ]; do
  set -- $queue
  from="${1%%:*}"
  dep="${1#*:}"
  shift
  queue="$*"

  floor="$(constraint_floor "$from" "$dep")"
  version="$(local_version "$dep")"
  if [ -z "$floor" ]; then
    err "$from: no version constraint on $dep"
  elif published "$dep" "$floor"; then
    :
  elif [ "$floor" != "$version" ]; then
    err "$from requires $dep >=$floor, which is neither on pub.dev nor the version in this tree ($version)"
  elif ! overridden "$dep"; then
    echo "$dep $version is not on pub.dev yet; resolving it from its path"
    overrides="$overrides $dep"
    for next in $(siblings "packages/$dep/pubspec.yaml"); do
      queue="$queue packages/$dep/pubspec.yaml:$next"
    done
  fi
done
[ "$fail" -eq 0 ] || exit 1

# A sibling resolved from its path is at its floor already.
downgrade=""
for dep in $direct; do
  overridden "$dep" || downgrade="$downgrade $dep"
done

cd "packages/$pkg"

rm -f pubspec_overrides.yaml
if [ -n "$overrides" ]; then
  {
    echo "dependency_overrides:"
    for dep in $overrides; do printf '  %s:\n    path: ../%s\n' "$dep" "$dep"; done
  } > pubspec_overrides.yaml
fi

# --no-example: the example app would need the same overrides.
dart pub get --no-example > /dev/null
if [ -n "$downgrade" ]; then
  dart pub downgrade --no-example $downgrade > /dev/null
fi

resolved=""
for dep in $direct; do
  resolved="$resolved, $dep $(awk -v dep="$dep" '$0 == "  " dep ":" { f = 1 }
    f && /^    version:/ { gsub(/"/, "", $2); print $2; exit }' pubspec.lock)"
  if overridden "$dep"; then resolved="$resolved (path)"; fi
done
echo "Resolved ${resolved#, }"

# custom_lint runs as a legacy analyzer plugin, which crashes the analysis
# server without the workspace overrides. Its rules are checked by the jobs
# that run `melos bootstrap`.
perl -0pi -e 's/\n  plugins:\n(?:    - .*\n)+/\n/' analysis_options.yaml

dirs="lib"
if [ -d bin ]; then dirs="$dirs bin"; fi
if ! dart analyze $dirs; then
  err "$pkg doesn't analyze against the versions above. Raise the floor of the constraint on the sibling that lacks the API, to the version that adds it. If that version isn't on pub.dev yet, release the sibling first."
  exit 1
fi

echo "✅ $pkg analyzes against the lowest sibling versions its constraints allow"
