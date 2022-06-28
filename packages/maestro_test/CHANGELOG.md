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
- Fix many smaller issues.

## 0.1.4

- Allow for running on many devices simultaneously.
- Rename class `Automator` to `Maestro`.
- Simpified test-side initialization. Now all you need is `Maestro.forTest()`.
- Simpified driver-side initialization. Now all you need is
  `Maestro.forDriver()`.

## 0.1.3

- Add support for enabling/disabling Bluetooth.

## 0.1.2

- Be more noisy when an error occurs.

## 0.1.1

- Fix minor logging bug.

## 0.1.0

- Add basic means of controlling platform-native Widgets (`TextView`,
  `EditText`, and `Button` on Android). This also applies to WebView.
- Add enabling and disabling of Wi-Fi, Celluar, and Night Mode.
- Improve stability.

## 0.0.6

- Set minimum Dart version to 2.16.
- Fix links to `package:leancode_lint` in README.

## 0.0.5

- Update broken link in README.

## 0.0.4

- Update README.

## 0.0.3

- Rename from `maestro` to `maestro_test`.

## 0.0.2

- Split `maestro` and `maestro_cli` into separate packages.

## 0.0.1

- Initial version.
