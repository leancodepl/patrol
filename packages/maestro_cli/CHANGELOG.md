## 0.2.0

- Add support for new features in [maestro_test
  0.2.0](https://pub.dev/packages/maestro_test/changelog#020)

## 0.1.5

- Allow for running on many devices simultaneously.
- A usual portion of smaller improvements and bug fixes.

## 0.1.4

- Be more noisy when an error occurs.
- Change waiting timeout for native widgets from 10s to 2s.

## 0.1.3

- Fix a bug which made `flavor` option required.
- Add `--debug` flag to `maestro drive`, which allows to use default,
  non-versioned artifacts from `$MAESTRO_ARTIFACT_PATH`.

## 0.1.2

- Fix typo in generated `integration_test/app_test.dart`.
- Depend on [package:adb](https://pub.dev/packages/adb).

## 0.1.1

- Set minimum Dart version to 2.16.
- Fix links to `package:leancode_lint` in README

## 0.1.0

- Add `--template` option for `maestro bootstrap`
- Add `--flavor` options for `maestro drive`
- Rename `maestro config` to `maestro doctor`

## 0.0.9

- Add `--device` option for `maestro drive`, which allows you to specify the
  device to use. Devices can be obtained using `adb devices`.

## 0.0.8

- Fix `maestro drive` on Windows crashing with ProcessException.

## 0.0.7

- Fix a few bugs.

## 0.0.6

- Fix `maestro bootstrap` on Windows crashing with ProcessException.

## 0.0.5

- Make versions match AutomatorServer.

## 0.0.4

- Nothing.

## 0.0.3

- Add support for `maestro.toml` config file.

## 0.0.2

- Split `maestro` and `maestro_cli` into separate packages.
- Add basic, working command line interface with.

## 0.0.1

- Initial version.
