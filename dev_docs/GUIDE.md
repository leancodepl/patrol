# Working on the test bundling feature

_Test bundling_, also known as _native automation_, is a core feature of Patrol.
It bridges the native world of tests on Android and iOS with the Flutter/Dart
world of tests.

It lives in the [patrol package](../packages/patrol).

To learn more about test bundling, [read this article][test_bundling_article].

This document is a collection of tips and tricks to make it easier to work on
test bundling-related code.

### Tools

`adb logcat` is your friend. Spice it up with `-v color`. If you need something
more powerful, check out [`purr`](https://github.com/google/purr).

### Show Dart-side logs only

Search for `flutter :`.

### Find out when a test starts

Search for `TestRunner: started`.

```
09-21 12:24:09.223 23387 23406 I TestRunner: started: runDartTest[callbacks_test testA](pl.leancode.patrol.example.MainActivityTest)
```

### Find out when a test ends

Search for `TestRunner: finished`.

### I made some changes to test bundling code that result in a deadlock

This can often happen when editing test bundling code. Because of various
limitations of the `test` package, which Patrol has to base on, test bundling
code is full of shared global mutable state and unobvious things happening in
parallel.

When trying to find the cause of a deadlock:

- search for `await`s in custom functions provided by Patrol (e.g.
  `patrolTest()` and `patrolSetUpAll()`) and global lifecycle callbacks
  registered by the generated Dart test bundle or PatrolBinding (e.g.
  `tearDown()`s)
- Use `print`s amply to pinpint where the code is stuck.

In the future, we should think about how to refactor this code to be more
maintainable and simpler.

[test_bundling_article]: https://leancode.co/blog/patrol-2-0-improved-flutter-ui-testing
