## 0.2.1

- Populate missing fields in `pubspec.yaml`, improve README (#254)

## 0.2.0

- `Adb.instrument` now returns a `Process`

## 0.1.6

- Return a cancel function from `Adb.forwardPorts` method

## 0.1.5

- Remove `Adb.forceInstallApk` because it was too high level and flaky

## 0.1.4

- Fix `AdbInstallFailedUpdateIncompatible.fromStdErr` not parsing the error
  message correctly

## 0.1.3

- Always ensure that `adb` dameon is running

## 0.1.2

- Move `adb start-server` to `Adb.init` method

## 0.1.1

- Ensure that `adbd` is running in `Adb` constructor

## 0.1.0

- Make API a bit more object-oriented to enable testing
- Add support for `adb devices`

## 0.0.4

- Fix wrong order of arguments for `instrument()`

## 0.0.3

- Make it possible to pass arguments to `instrument()` method

## 0.0.2

- Fix bugs that arose during migration

## 0.0.2

- Initial release. Move code from `package:maestro_cli`
