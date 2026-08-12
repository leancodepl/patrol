#!/usr/bin/env bash
#
# Generates the SauceLabs XCUITest testListFile (.sauce/ios_testlist.txt) from
# the static XCTest methods emitted by `patrol build ios --emit-test-manifest`.
#
# The generated ios/RunnerUITests/PatrolGeneratedTests.inc holds one Objective-C
# method per Dart test (`- (void)test_<sanitized>_<index> { ... }`). We turn each
# selector into the SauceLabs testListFile format.
#
# IMPORTANT: SauceLabs uses a DIFFERENT separator between the test target and the
# test class depending on the device type (see the docs linked below):
#
#     simulator:    RunnerUITests/RunnerUITests/test_<sanitized>_<index>
#     real device:  RunnerUITests.RunnerUITests/test_<sanitized>_<index>
#                                 ^ dot, not slash
#
# Using the simulator format on a real device (or vice versa) matches no tests,
# so the run installs the UITest runner and then just sits there (blank/gray).
# Select the format with SAUCE_DEVICE (default: simulator):
#
#     SAUCE_DEVICE=real      scripts/generate_ios_testlist.sh
#     SAUCE_DEVICE=simulator scripts/generate_ios_testlist.sh   # default
#
# Docs: https://docs.saucelabs.com/mobile-apps/automated-testing/espresso-xcuitest/xcuitest/
#
# Deriving from the compiled .inc (rather than re-parsing the manifest) keeps us
# byte-identical to what XCTest actually discovers - zero duplicated sanitization
# logic. Run this AFTER `patrol build ios --emit-test-manifest`.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INC_FILE="$ROOT_DIR/ios/RunnerUITests/PatrolGeneratedTests.inc"
OUT_FILE="$ROOT_DIR/.sauce/ios_testlist.txt"

SAUCE_DEVICE="${SAUCE_DEVICE:-simulator}"
case "$SAUCE_DEVICE" in
  simulator) PREFIX='RunnerUITests/RunnerUITests/' ;;
  real)      PREFIX='RunnerUITests.RunnerUITests/' ;;
  *)
    echo "ERROR: SAUCE_DEVICE must be 'simulator' or 'real' (got '$SAUCE_DEVICE')." >&2
    exit 1
    ;;
esac

if [[ ! -f "$INC_FILE" ]]; then
  echo "ERROR: $INC_FILE not found." >&2
  echo "Did 'patrol build ios --emit-test-manifest' run and succeed?" >&2
  exit 1
fi

# Extract each generated selector and prefix it with the target/class in the
# format the selected device type expects.
#
# `|| true` on grep: with `set -euo pipefail` a no-match (exit 1) would abort the
# script here, making the explicit empty-list diagnostic below unreachable.
mkdir -p "$(dirname "$OUT_FILE")"
{ grep -oE '^- \(void\)test_[A-Za-z0-9_]+' "$INC_FILE" || true; } \
  | sed -E "s#^- \(void\)#$PREFIX#" \
  > "$OUT_FILE"

COUNT="$(wc -l < "$OUT_FILE" | tr -d '[:space:]')"
if [[ "$COUNT" -eq 0 ]]; then
  echo "ERROR: no test selectors found in $INC_FILE - empty test list." >&2
  echo "Build-time discovery produced no tests; re-run the build and check its output." >&2
  exit 1
fi

echo "Wrote $COUNT test selector(s) for $SAUCE_DEVICE -> $OUT_FILE"
