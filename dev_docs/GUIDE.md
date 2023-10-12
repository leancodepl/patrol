# Working on the test bundling feature

`adb logcat` is your friend. Spice it up with `-v color`. If you need something
more powerful, check out [`purr`](https://github.com/google/purr).

### Find out when a test starts

Search for `TestRunner: started`.

```
09-21 12:24:09.223 23387 23406 I TestRunner: started: runDartTest[callbacks_test testA](pl.leancode.patrol.example.MainActivityTest)

```

### Find out when a test ends

Search for `TestRunner: finished`.

### I made some changes to test bundling code that result in a deadlock

This is normal when editing this code. It's a mine field of shared global
mutable state and things happening in parallel.

Look for `await`s in custom functions provided by Patrol (e.g. `patrolTest()`
and `patrolSetUpAll()`) and global lifecycle callbacks registered by the
generated Dart test bundle or PatrolBinding (e.g. `tearDown()`s). Use `print`s
amply to pinpint where the code is stuck.
