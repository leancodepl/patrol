# maestro_cli

## Installation

### From pub.dev

> Not available yet!

```
$ dart pub global activate maestro_cli
```

### From git

1. Make sure that you have Dart >= 2.17 installed (it comes with Flutter 3).
2. Clone the repo.
3. Go to `packages/maestro_cli`.
4. Run `dart pub global activate --source path .`

Now you can should be able to run `maestro` in your terminal. If you can't and
the error is something along the lines of "command not found", make sure that
you've added appropriate directories to PATH:

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
2. have `maestro` added as a `dev_dependency` in `pubspec.yaml`
3. have `test_driver/integration_test.dart`
4. have `integration_test/app_test.dart`

Run `maestro bootstrap` to automatically do 1, 2, 3, and most of 4.
