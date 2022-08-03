## 0.4.3

- Add `MaestroFinder.dragTo`
- Remove unused `MaestroTester.drag` and `MaestroTester.dragFrom`

## 0.4.2

- Convert `MaestroFinder.visible` getter to a method, which now also takes a
  timeout
- Rename `MAESTRO_ARTIFACT_PATH` environment variable to `MAESTRO_CACHE
- Fix `MaestroTester.dragUntilVisible` not waiting for the scrollable to appear
- Fix `MaestroFinder.allCandidates` returning incorrect results

## 0.4.1

- Throw `MaestroFinderFoundNothingException` when [MaestroFinder.visible]
  doesn't find any widget during [MaestroTester.findTimeout]

## 0.4.0

`MaestroFinder`:

- Now `tap()` and `enterText()` wait for the widget to become visible. The
  timeout can be configured by setting `findTimeout` in `maestroTest()`
- Remove `index` parameter from `tap()` and `enterText()`. The new way to select
  the widget to be tapped is to use `at()` before tapping. Same goes for
  entering text.
- Add `bool andSettle` parameter to `maestroTest` function. This lets you
  globally configure whether to call `pumpAndSettle` after actions such as
  `tap()` or `enterText()`
- Refactor `MaestroTester.dragUntilVisible` to be simpler to use
- Rename `withDescendant()` to `containing()`

Native:

- Make `Maestro.openNotifications()` and `Maestro.openQuickSettings()` more
  robust

## 0.3.3

- Make it possible to pass Flutter's `Finder` to `$`
- Make `MaestroFinder.first`, `MaestroFinder.last`, `MaestroFinder.at()` return
  `MaestroFinder`, not `Finder`

## 0.3.2

- Improve selector engine:

  - Make it possible to pass a `Key` as `matching` to
    `MaestroTester.call(dynamic matching)` and `MaestroFinder.$(dynamic matching)`

- Add `sleep` parameter for `maestroTest` method
- Make `WidgetTester`'s forwarded methods in `MaestroTester` accept less
  arguments
- Add more in-code documentation

## 0.3.1

- Improve selector engine:

  - Make it possible to pass a `MaestroFinder` as `matching` to
    `MaestroTester.call(dynamic matching)` and `MaestroFinder.$(dynamic matching)`
  - Fix a bug which caused chaining `MaestroFinder`s (e.g
    `$(Scaffold).$(Container).$(#someText)`) to not work.

- Add more in-code documentation and improve README

## 0.3.0

- Add selector engine

## 0.2.0

- Introduce `Selector` class, which can be passed into `Maestro.tap(selector)`.
- Add more platform functionality:

  - `Maestro.enableWifi()` and `Maestro.disableWifi()`
  - `Maestro.enableCellular()` and `Maestro.disableCellular()`
  - `Maestro.enableDarkMode()` and `Maestro.disableDarkMode()`
  - `Maestro.getNotifications()`, `Maestro.getFirstNotification()`, and
    `Maestro.tapOnNotification(int index)`

- Make `Maestro.forTest()` automatically call
  `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
- Fix many smaller issues

## 0.1.4

- Allow for running on many devices simultaneously
- Rename class `Automator` to `Maestro`
- Simpified test-side initialization. Now all you need is `Maestro.forTest()`
- Simpified driver-side initialization. Now all you need is
  `Maestro.forDriver()`

## 0.1.3

- Add support for enabling/disabling Bluetooth

## 0.1.2

- Be more noisy when an error occurs

## 0.1.1

- Fix minor logging bug

## 0.1.0

- Add basic means of controlling platform-native Widgets (`TextView`,
  `EditText`, and `Button` on Android). This also applies to WebView.
- Add enabling and disabling of Wi-Fi, Celluar, and Night Mode
- Improve stability

## 0.0.6

- Set minimum Dart version to 2.16
- Fix links to `package:leancode_lint` in README

## 0.0.5

- Update broken link in README.

## 0.0.4

- Update README

## 0.0.3

- Rename from `maestro` to `maestro_test`

## 0.0.2

- Split `maestro` and `maestro_cli` into separate packages

## 0.0.1

- Initial version
