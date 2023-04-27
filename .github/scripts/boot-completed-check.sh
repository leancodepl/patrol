#!/bin/bash

# Set timeout to 5 minutes (in seconds)
timeout=300

# Get current timestamp
start_time=$(date +%s)

# Loop until timeout
while true
do
  # Check value of sys.boot_completed using adb shell
  boot_completed=$(adb shell getprop sys.boot_completed)

  # Check if the value is 1 (boot completed)
  if [[ $boot_completed -eq 1 ]]; then
    echo "Boot completed"
    break
  fi

  # Get current timestamp
  current_time=$(date +%s)

  # Check if timeout has been reached
  if [[ $((current_time - start_time)) -gt $timeout ]]; then
    echo "Timeout reached"
    break
  fi

  # Sleep for 5 seconds before checking again
  sleep 5
done
