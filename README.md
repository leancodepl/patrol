# Maestro

Simple, easy-to-learn, Flutter-native UI testing framework overcoming
limitations of `flutter_driver` and `flutter_test`.

[![maestro_test on pub.dev][pub_badge_test]][pub_link_test]
[![maestro_cli on pub.dev][pub_badge_cli]][pub_link_cli]
[![code style][pub_badge_style]][pub_badge_link]

## CLI

See [packages/maestro_cli][maestro_cli].

## Package

See [packages/maestro_test][maestro_test].

## Release process

1. Create a [git annotated tag][annotated_tag]:

```
$ git tag -a "maestro_cli-v0.3.4" -m "Release notes go here"
```

2. Push it! GitHub Actions will take care of the rest.

[maestro_cli]: https://github.com/leancodepl/maestro/tree/master/packages/maestro_cli
[maestro_test]: https://github.com/leancodepl/maestro/tree/master/packages/maestro_test
[pub_badge_test]: https://img.shields.io/pub/v/maestro_test?label=maestro_test
[pub_link_test]: https://pub.dartlang.org/packages/maestro_test
[pub_badge_cli]: https://img.shields.io/pub/v/maestro_cli?label=maestro_cli
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[pub_link_cli]: https://pub.dartlang.org/packages/maestro_cli
[annotated_tag]: https://git-scm.com/book/en/v2/Git-Basics-Tagging#_annotated_tags
