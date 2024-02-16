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
