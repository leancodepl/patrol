#!/usr/bin/env bash
# Analyze a package against the lowest sibling versions its constraints allow,
# resolved from pub.dev: what a user can get, unlike the melos path overrides
# every other local run and CI dry-run uses. Catches a floor that lacks the API
# the package calls (patrol_cli shipped `adb: ^0.6.0` while calling Adb.pull,
# added in 0.6.1).
#
# A floor not on pub.dev yet is fine only if it is the sibling's version in this
# tree, i.e. a branch stacked on the sibling's release, which is tagged first;
# it is then taken from its path.
#
# Run in the release worktree, on CI's Flutter. Changes only gitignored files
# (pubspec_overrides.yaml, pubspec.lock); analysis_options.yaml and the
# overrides are restored on exit. Needs dart, curl and network.
#
# Usage: check-floors.sh [package...]   (default: every package without
#                                        `publish_to: none` that depends on
#                                        another package in packages/)
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

# Sibling packages in the `dependencies:` block of a pubspec.
siblings() {
  awk '/^dependencies:/ { f = 1; next } /^[^ #]/ { f = 0 }
       f && /^  [a-z_0-9]+:/ { sub(":.*", "", $1); print $1 }' "$1" |
    while read -r d; do if [ -f "$root/packages/$d/pubspec.yaml" ]; then echo "$d"; fi; done
}
local_version() { awk '/^version:/ { print $2 }' "$root/packages/$1/pubspec.yaml"; }
# Lower bound of the constraint on $2 in pubspec $1: ^1.2.3 or '>=1.2.3 <2.0.0'.
constraint_floor() {
  awk -v d="$2" '$1 == d ":" { $1 = ""; print; exit }' "$1" |
    sed -E "s/^ *['\"]?(\\^|>=)?//; s/[ <'\"].*//"
}
published() { curl -sf "https://pub.dev/api/packages/$1/versions/$2" > /dev/null; }

# Runs on the left of `||`, where `set -e` is off, so failures return explicitly.
check() {
  local pkg="$1" dir="$root/packages/$1"
  local direct floor=" " override=" " edges=() downgrade=() from d want have t
  direct=" $(siblings "$dir/pubspec.yaml" | tr '\n' ' ')"
  for d in $direct; do edges+=("$dir/pubspec.yaml:$d"); done
  while [ ${#edges[@]} -gt 0 ]; do
    from="${edges[0]%%:*}"
    d="${edges[0]#*:}"
    edges=("${edges[@]:1}")
    want="$(constraint_floor "$from" "$d")"
    have="$(local_version "$d")"
    if published "$d" "$want"; then
      [ "$from" = "$dir/pubspec.yaml" ] && floor="$floor$d "
    elif [ "$want" = "$have" ]; then
      case "$override" in *" $d "*) continue ;; esac
      echo "$d $have is not on pub.dev yet; using its path"
      override="$override$d "
      for t in $(siblings "$root/packages/$d/pubspec.yaml"); do
        edges+=("$root/packages/$d/pubspec.yaml:$t")
      done
    else
      echo "!! ${from#"$root"/} requires $d >=$want: neither on pub.dev nor the local version ($have)"
      return 1
    fi
  done
  # An overridden sibling is at its floor already.
  for d in $floor; do
    case "$override" in *" $d "*) ;; *) downgrade+=("$d") ;; esac
  done

  cd "$dir"
  rm -f pubspec_overrides.yaml
  if [ "$override" != " " ]; then
    {
      echo "dependency_overrides:"
      for d in $override; do printf '  %s:\n    path: ../%s\n' "$d" "$d"; done
    } > pubspec_overrides.yaml
  fi
  # --no-example: example/ has no overrides, so it can't see a sibling that is
  # not on pub.dev yet.
  dart pub get --no-example > /dev/null || return 1
  if [ ${#downgrade[@]} -gt 0 ]; then
    dart pub downgrade --no-example "${downgrade[@]}" > /dev/null || return 1
  fi
  for d in $direct; do
    echo "$d $(awk -v d="$d" '$0 == "  " d ":" { f = 1 }
      f && /^    version:/ { gsub(/"/, "", $2); print $2; exit }' pubspec.lock)"
  done | paste -sd ',' - | sed 's/,/, /g; s/^/resolved: /'
  # custom_lint is a legacy analyzer plugin and crashes the analysis server
  # without the workspace overrides; its rules run in the regular CI jobs.
  if grep -q '^  plugins:' analysis_options.yaml 2>/dev/null; then
    perl -0pi -e 's/\n  plugins:\n(?:    - .*\n)+/\n/' analysis_options.yaml
  fi
  # bin/ ships too, and can call a sibling directly (patrol_mcp's uses patrol_cli).
  if [ -d bin ]; then dart analyze lib bin; else dart analyze lib; fi
}

if [ $# -gt 0 ]; then
  packages=("$@")
else
  packages=()
  for f in packages/*/pubspec.yaml; do
    grep -q '^publish_to: *none' "$f" && continue
    [ -n "$(siblings "$f")" ] && packages+=("$(basename "$(dirname "$f")")")
  done
fi

backup="$(mktemp -d)"
restore() {
  for p in "${packages[@]}"; do
    cd "$root/packages/$p"
    [ -f "$backup/$p.analysis_options.yaml" ] && cp "$backup/$p.analysis_options.yaml" analysis_options.yaml
    rm -f pubspec_overrides.yaml
    [ -f "$backup/$p.pubspec_overrides.yaml" ] && cp "$backup/$p.pubspec_overrides.yaml" pubspec_overrides.yaml
    dart pub get --no-example > /dev/null 2>&1 || echo "restoring $p: dart pub get failed; run melos bootstrap" >&2
  done
  rm -rf "$backup"
}
for p in "${packages[@]}"; do
  [ -f "packages/$p/analysis_options.yaml" ] && cp "packages/$p/analysis_options.yaml" "$backup/$p.analysis_options.yaml"
  [ -f "packages/$p/pubspec_overrides.yaml" ] && cp "packages/$p/pubspec_overrides.yaml" "$backup/$p.pubspec_overrides.yaml"
done
trap restore EXIT

failed=()
for p in "${packages[@]}"; do
  echo "== $p"
  (check "$p") || failed+=("$p")
  echo
done

if [ ${#failed[@]} -gt 0 ]; then
  echo "Too-low or unresolvable floors in: ${failed[*]}"
  exit 1
fi
echo "All floors resolve and analyze: ${packages[*]}"
