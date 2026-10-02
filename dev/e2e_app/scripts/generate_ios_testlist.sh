#!/usr/bin/env bash
#
# Generates the SauceLabs XCUITest testListFile (.sauce/ios_testlist.txt) from
# the static XCTest methods emitted by `patrol build ios --emit-test-manifest`.
#
# The generated ios/RunnerUITests/PatrolGeneratedTests.inc holds one XCTestCase
# subclass per Dart test file, each with one method per test. We turn every
# class/method pair into the SauceLabs testListFile format.
#
# IMPORTANT: SauceLabs uses a DIFFERENT separator between the test target and the
# test class depending on the device type (see the docs linked below):
#
#     simulator:    RunnerUITests/PatrolGeneratedTests_<file>/test_<name>
#     real device:  RunnerUITests.PatrolGeneratedTests_<file>/test_<name>
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
  simulator) SEPARATOR='/' ;;
  real)      SEPARATOR='.' ;;
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

# Walk the file, remembering the class each method belongs to, and emit the
# target/class/method triple in the format the selected device type expects.
mkdir -p "$(dirname "$OUT_FILE")"
awk -v sep="$SEPARATOR" '
  /^@implementation / { cls = $2; next }
  /^- \(void\)test_/ {
    method = $2
    sub(/^\(void\)/, "", method)
    if (cls != "") print "RunnerUITests" sep cls "/" method
  }
' "$INC_FILE" > "$OUT_FILE"

COUNT="$(wc -l < "$OUT_FILE" | tr -d '[:space:]')"
if [[ "$COUNT" -eq 0 ]]; then
  echo "ERROR: no test selectors found in $INC_FILE - empty test list." >&2
  echo "Build-time discovery produced no tests; re-run the build and check its output." >&2
  exit 1
fi

echo "Wrote $COUNT test selector(s) for $SAUCE_DEVICE -> $OUT_FILE"
