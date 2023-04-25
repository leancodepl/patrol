#!/usr/bin/env bash
set -euo pipefail

# run emulator
emulator @MyAVD -no-snapshot-save -no-window -noaudio -no-boot-anim &
emulatorpid="$!"

# wait for emulator to boot up
while [ "`adb shell getprop sys.boot_completed | tr -d '\r' `" != "1" ] ; do sleep 1; done

# if we screenrecord too quickly, we get: "Unable to open '/sdcard/patrol.mp4': Operation not permitted"
sleep 60

record() {
    adb root
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

# adb shell ps | grep apps | awk '{print $9}'

# echo "disable googlequicksearchbox"

# adb shell "su root pm disable com.google.android.googlequicksearchbox"
# adb shell "su root pm disable com.google.android.apps.messaging"

adb install ~/test-butler-2.2.1.apk
adb shell am startservice com.linkedin.android.testbutler/com.linkedin.android.testbutler.ButlerService
while ! adb shell ps | grep butler > /dev/null; do
    sleep 1
    echo "Waiting for test butler to start..."
done
echo "Started Test Butler"

# record in background
record &
recordpid="$!"

# print and write logs to a file
flutter logs | tee ./flutter-logs &
flutterlogspid="$!"

EXIT_CODE=0

# run tests 3 times and save tests' summary
patrol test \
  -t integration_test/webview_leancode_test.dart \
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

kill $emulatorpid
exit $EXIT_CODE
