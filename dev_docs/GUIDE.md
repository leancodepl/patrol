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
