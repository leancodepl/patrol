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
