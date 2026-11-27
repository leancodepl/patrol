## Unreleased

- Add `PatrolTesterConfig.dragWithoutFling`. When true, scrolling methods such as `scrollTo()`
  end each drag without a fling and cover 3 steps per drag, so they no longer wait for the scroll
  to coast to a stop between drags. Off by default; `scrollTo()`, `scrollUntilVisible()`,
  `scrollUntilExists()`, `dragUntilVisible()` and `dragUntilExists()` also take a
  `dragWithoutFling` argument for a single call. (#3421)
- **Breaking:** `PatrolTester.pumpAndSettle()` returns `Future<int>`, the number of pumped frames,
  like `WidgetTester.pumpAndSettle()`. Overrides, implementations and mocks of it must return
  `Future<int>`. (#3414)
- Fix `PatrolFinder.matches()` throwing a `TypeError` on chained finders (`$(#a).$(#b)`) and on
  `first`, `last` and `at()`. They now skip offstage widgets, like the finder itself; simple
  finders behave as before and also match offstage widgets. (#3433)
- **Breaking:** `PatrolTester.pumpWidget()` takes `duration` and `phase` as named parameters, like
  `pumpWidgetAndSettle()`, and gets `wrapWithView` from `WidgetTester.pumpWidget()`. Callers,
  overrides and mocks must pass them by name; overrides must also take `wrapWithView`. (#3433)
- **Breaking:** `PatrolTester.pumpWidgetAndSettle()` returns `Future<int>`, the number of frames
  pumped while settling, and gets `wrapWithView`. Overrides, implementations and mocks of it must
  return `Future<int>`, and overrides must take `wrapWithView`. (#3433)

## 3.7.1

- Fix the duration in the timeout exception that `dragUntilExists()` and `dragUntilVisible()` throw after running out of iterations: it now reports the time spent dragging instead of `settleBetweenScrollsTimeout`. (#3300)
- Drop an unneeded `package:flutter/material.dart` import, which Flutter 3.47+ deprecates in favour
  of `package:material_ui`. (#3399)

## 3.7.0

- Add optional `description` parameter to Flutter actions (`tap`, `enterText`, `scrollTo`, etc.). When set, it replaces the auto-generated patrol log step text and wraps failures as `failed on: <description>`. (#3242)
- Add a regression test for finding widgets by keys containing special characters (diacritics, symbols, emoji). (#3169)
- Fix doc comments that did not match the code in `waitUntilExists()`, `scrollUntilVisible()`, `dragUntilExists()`, `dragUntilVisible()` and `WaitUntilVisibleTimeoutException`, doc code samples that did not compile, and typos. (#3302)

## 3.6.0

- Bump `patrol_log` to `^0.10.0`.

## 3.5.0

- Fix issues with `enterText()`. (#2202, #2111)
- Add `hideKeyboard` optional argument to `enterText()` method.

## 3.4.0

- Fix `at()`, `first` and `last` to wait for widget to become visible.
- Add `isAndroid`, `isIOS`, `isWeb` and `isMacOS` getters.
- Remove `dart:io`.

## 3.3.0

- Bump `patrol_log` to `^0.9.0`.

## 3.2.0

- Bump `patrol_log` to `^0.8.0`.

## 3.1.0

- Bump `patrol_log` to `0.7.0`.

## 3.0.0

- Bump `patrol_log` to `0.6.0`.

## 2.9.0

- Bump `leancode_lint` to `17.0.0`. (#2681)
- Bump minimum Dart SDK to version 3.8.0 (#2681)

## 2.8.2

- Add `alignment` argument to `tap()`, `longPress()`, `enterText()`, `scrollTo()`, `dragUntilVisible()` and `scrollUntilVisible()` methods. (#2584)

## 2.7.2

- Remove `PatrolWidgetTester` class. (#2570)

## 2.7.1

- Bump Gradle version in the example app so it's possible to build them on the
  latest JDK 23 (#2503)
- Bump `custom_lint` to `0.7.0` and `leancode_lint` to `14.3.0`. (#2574)
- Fix `$.enterText()` issues (#2570)

## 2.7.0

- Add `alignment` parameter to `waitUntilVisible` in order to improve visibility check on Row and Column widgets. (#2464)
- Add `isVisibleAt` method to check if a widget is visible at a given alignment in case `visible` fails. (#2464)
- Remove `exception` from `StepEntry`. When it was too long, it caused crash because of badly formed JSON. (#2481)
- Bump `patrol_log` version.

## 2.6.0

- Patch `enterText` into same field twice. (#2461)
- Bump `patrol_log` version.

## 2.5.1

- Disable printing logs in nested `waitUntilVisible` and `waitUntilExists` calls.

## 2.5.0

- Update `patrol_log`.

## 2.4.0

- Wrap actions on finders with patrol logs.

## 2.3.0

- Add option to disable printing patrol logs. Default value is disabled.

## 2.2.0+1

- Bump `patrol_log` version.

## 2.2.0

- Use `patrol_log` in `PatrolTester` methods.

## 2.1.3

- Bump min Flutter SDK to 3.24.0 and Dart SDK to 3.5.0 (#2371)

## 2.1.2

- Adjust `pumpWidget` to new `flutter_test` API. 
- Bump min Flutter SDK to 3.22

## 2.1.1

- Revert: Adjust `pumpWidget` to new `flutter_test` API. 

## 2.1.0

- Adjust `pumpWidget` to new `flutter_test` API. 

## 2.0.2

- Add registering text input. (#2111)

## 2.0.1+1

- Add screenshots to `pubspec.yaml` (#1917)

## 2.0.1

- Bump dependencies for Flutter 3.16 and Dart 3.2
- Populate `topics` in pubspec

## 2.0.0

- Bump minimum supported Flutter version to 3.16 to be compatible with breaking
  changes in `flutter_test`
- **BREAKING**:
  - Remove deprecated `andSettle` from all `PatrolTester` and `PatrolFinder`
    methods. Use `settlePolicy` instead (#1892)
  - The deprecated `andSettle` method has been removed from all `PatrolTester`
  and `PatrolFinder` methods like `tap()`, `enterText()`, and so on. Developers
  should now use `settlePolicy` as a replacement, which has been available since
  June (#1892)
  - The default `settlePolicy` has been changed to `trySettle` (#1892)

## 1.0.0

- Initial release as a standalone package (#1606)
