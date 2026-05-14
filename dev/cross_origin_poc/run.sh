#!/usr/bin/env bash
# Thin wrapper around the Dart orchestrator in cross_origin_lib.
#
# The orchestrator reads `patrol.remote.apps` from apps/controller/pubspec.yaml,
# starts each declared remote app on its port, compiles the controller with
# --dart-define=PATROL_REMOTE_APPS=<json>, runs Playwright, then cleans up.
#
# This shell exists only so `./run.sh` keeps being the user-facing entry
# point; the real logic is in cross_origin_lib/bin/orchestrate.dart.

set -euo pipefail
POC_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$POC_DIR/apps/controller"
exec dart run cross_origin_lib:orchestrate "$@"
