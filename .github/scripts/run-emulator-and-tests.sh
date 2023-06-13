#!/usr/bin/env bash
set -euo pipefail

# run emulator
emulator @MyAVD -no-snapshot-save -no-window -noaudio -no-boot-anim -gpu auto -accel on &
bash "$GITHUB_WORKSPACE/.github/scripts/boot-completed-check.sh"

adb shell service call alarm 3 s16 America/Las_Angeles

# record in background
record() {
    adb shell mkdir -p /sdcard/screenrecords
    i=0
    while [ ! -f "$HOME/adb_screenrecord.lock" ]; do
        adb shell screenrecord "/sdcard/screenrecords/patrol_$i.mp4" &
        pid="$!"
        echo "$pid" > "$HOME/adb_screenrecord.pid"
        lsof -p "$pid" +r 1 &>/dev/null # wait until screenrecord times out
        i=$((i + 1))
    done
}

record &
recordpid="$!"

# print and write logs to a file
flutter logs | tee ./flutter-logs &
flutterlogspid="$!"

EXIT_CODE=0

# run tests 3 times and save tests' summary
patrol test --verbose \
    --exclude integration_test/permissions_location_test.dart \
    --exclude integration_test/service_airplane_mode_test.dart \
    --exclude integration_test/service_bluetooth_test.dart \
    --exclude integration_test/webview_hackernews_test.dart \
    --exclude integration_test/webview_leancode_test.dart \
    --exclude integration_test/webview_login_test.dart \
    --exclude integration_test/webview_stackoverflow_test.dart \
    | tee ./tests-summary || EXIT_CODE=$?

# write lockfile to prevent next loop iteration
touch "$HOME/adb_screenrecord.lock"

# kill processes
kill $recordpid
kill $flutterlogspid
adb shell pkill -SIGINT screenrecord

# pull screen recordings and merge them
adb pull /sdcard/screenrecords .
cd screenrecords
ls | grep mp4 | sort -V | xargs -I {} echo "file {}" | sponge videos.txt
ffmpeg -f concat -safe 0 -i videos.txt -c copy screenrecord.mp4

# goodbye emulator :(
adb -s emulator-5554 emu kill
exit $EXIT_CODE
