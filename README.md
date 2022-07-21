# Maestro

Simple, easy-to-learn, Flutter-native UI testing framework eliminating
limitations and improving experience of `flutter_driver` and `flutter_test`.

[![maestro_test on pub.dev][pub_badge_test]][pub_link_test] [![maestro_cli on
pub.dev][pub_badge_cli]][pub_link_cli] [![code
style][pub_badge_style]][pub_badge_link]

## CLI

The Maestro CLI allows you to run the `maestro` command from terminal run your
Maestro-powered tests:

### Installation

```bash
dart pub global activate maestro_cli
```

### Usage

First, initialize Maestro in your project:

```
$ maestro bootstrap
```

Then, to run tests using `maestro_test`:

```
$ maestro drive
```

## Package

`maestro_test` package builds on top of `flutter_driver` and `flutter_test`. It
makes it easy to:

- control the native device features, such as switching between apps or enabling
  Wi-Fi

- write widget tests in a new, consice way using powerful [custom
  selectors][custom_selectors]

### Installation

Add `maestro_test` as a dev dependency in `pubspec.yaml`:

```
dev_dependencies:
  maestro_test: ^1.0.0
```

### Usage

See [package:maestro_test][maestro_test]'s README.

## Release process

1. Create a [git annotated tag][annotated_tag]:

```
git tag -a "maestro_cli-v0.3.4" -m "Release notes go here"
```

2. Push it! GitHub Actions will take care of the rest.

[maestro_test]: https://github.com/leancodepl/maestro/tree/master/packages/maestro_test
[pub_badge_test]: https://img.shields.io/pub/v/maestro_test?label=maestro_test
[pub_link_test]: https://pub.dartlang.org/packages/maestro_test
[pub_badge_cli]: https://img.shields.io/pub/v/maestro_cli?label=maestro_cli
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[pub_link_cli]: https://pub.dartlang.org/packages/maestro_cli
[ui_automator]: https://developer.android.com/training/testing/other-components/ui-automator
[annotated_tag]: https://git-scm.com/book/en/v2/Git-Basics-Tagging#_annotated_tags
[custom_selectors]: https://github.com/leancodepl/maestro/tree/feature/custom_selectors/packages/maestro_test#custom-selectors
