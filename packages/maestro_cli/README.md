# maestro_cli

[![maestro_cli on pub.dev][pub_badge]][pub_link]
[![codestyle][pub_badge_style]][pub_badge_link]

Command-line tool to make working with [maestro_test][pub_link_test] easier.

## Installation

### From pub.dev

```
$ dart pub global activate maestro_cli
```

### From git

1. Make sure that you have Dart >= 2.16 installed.

   ```
   $ dart --version
   ```

2. Clone the repo.
3. Go to `packages/maestro_cli`.
4. Run `dart pub global activate --source path .`

### Troubleshooting

If you can't run `maestro` from the terminal and the error is something along
the lines of "command not found", make sure that you've added appropriate
directories to PATH:

- on Unix-like systems, add `$HOME/.pub-cache/bin`
- on Windows, add `%USERPROFILE%\AppData\Local\Pub\Cache\bin`

## Usage

### First run

On first run, `maestro` will download artifacts it needs to the _artifact path_.
By default it is `$HOME/.maestro`, but you can change it by setting
`MAESTRO_ARTIFACT_PATH` environment variable.

To learn about commands, run:

```
$ maestro --help

```

### Bootstrap

To use Maestro in your Flutter project, you need 4 things:

1. have `maestro.toml` file in the root of the project (i.e next to
   `pubspec.yaml`)
2. have `maestro_test` added as a `dev_dependency` in `pubspec.yaml`
3. have `integration_test` added as a `dev_dependency` in `pubspec.yaml`
4. have `test_driver/integration_test.dart`
5. have `integration_test/app_test.dart`

Run `maestro bootstrap` to automatically do 1, 2, 3, 4, and most of 5.

[pub_badge]: https://img.shields.io/pub/v/maestro_cli.svg
[pub_link]: https://pub.dartlang.org/packages/maestro_cli
[pub_link_test]: https://pub.dartlang.org/packages/maestro_test
[pub_badge]: https://img.shields.io/pub/v/maestro_cli.svg
[pub_link]: https://pub.dartlang.org/packages/maestro_cli
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
