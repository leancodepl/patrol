#!/usr/bin/env bash
#
# Generates the SauceLabs XCUITest testListFile (.sauce/ios_testlist.txt) from
# the static XCTest methods emitted by `patrol build ios --emit-test-manifest`.
#
# The generated ios/RunnerUITests/PatrolGeneratedTests.inc holds one Objective-C
# method per Dart test (`- (void)test_<sanitized>_<index> { ... }`). We turn each
# selector into the SauceLabs simulator testListFile format:
#
#     RunnerUITests/RunnerUITests/test_<sanitized>_<index>
#      ^bundle       ^class        ^method
#
# Deriving from the compiled .inc (rather than re-parsing the manifest) keeps us
# byte-identical to what XCTest actually discovers - zero duplicated sanitization
# logic. Run this AFTER `patrol build ios --emit-test-manifest`.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INC_FILE="$ROOT_DIR/ios/RunnerUITests/PatrolGeneratedTests.inc"
OUT_FILE="$ROOT_DIR/.sauce/ios_testlist.txt"

if [[ ! -f "$INC_FILE" ]]; then
  echo "ERROR: $INC_FILE not found." >&2
  echo "Did 'patrol build ios --emit-test-manifest' run and succeed?" >&2
  exit 1
fi

# Extract each generated selector and prefix it with the target/class.
grep -oE '^- \(void\)test_[A-Za-z0-9_]+' "$INC_FILE" \
  | sed -E 's#^- \(void\)#RunnerUITests/RunnerUITests/#' \
  > "$OUT_FILE"

COUNT="$(wc -l < "$OUT_FILE" | tr -d '[:space:]')"
if [[ "$COUNT" -eq 0 ]]; then
  echo "ERROR: no test selectors found in $INC_FILE - empty test list." >&2
  echo "Build-time discovery likely failed (native fell back to runtime)." >&2
  exit 1
fi

echo "Wrote $COUNT test selector(s) -> $OUT_FILE"
