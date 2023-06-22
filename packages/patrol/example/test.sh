#!/usr/bin/env bash
set -euo pipefail

patrol develop --target integration_test/example_test.dart &

pid=$!

sleep 30

pgid=$(ps -o pgid= $pid | grep -o '[0-9]*')

kill -SIGINT $pid
kill -SIGINT -$pgid
