#!/usr/bin/env bash
set -uo pipefail

TESTS_EXIT_CODE=0
# Run your command and store the output in a variable
output=$(gcloud firebase test android run \
	--type instrumentation \
	--app build/app/outputs/apk/debug/app-debug.apk \
	--test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
	--device model="oriole",version="33",locale=en,orientation=portrait \
	--timeout 10m \
	--results-bucket="patrol_runs" \
	--use-orchestrator \
	--environment-variables clearPackageData=true)
TESTS_EXIT_CODE=$?

# Extract the last link using grep, tail, and sed, and store it in a variable
link=$(echo "$output" | grep -o 'https://[^ ]*' | tail -1 | sed 's/\[//;s/\]//')

echo "--------"
echo "$link"

exit $TESTS_EXIT_CODE
