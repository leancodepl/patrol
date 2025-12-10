# Patrol

[![patrol on pub.dev][patrol_badge]][patrol_link]
[![patrol_cli on pub.dev][patrol_cli_badge]][patrol_cli_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![patrol_discord]][patrol_discord_link]
[![code style][leancode_lint_badge]][leancode_lint_link]
[![patrol_github_stars]][patrol_github_link]
[![patrol_x]][patrol_x_link]

Simple yet powerful Flutter-first UI testing framework overcoming limitations of
`flutter_test`, `integration_test`, and `flutter_driver`. Created and supported
by [LeanCode](https://leancode.co).

![Patrol promotial graphics][promo_graphics]

Learn more about Patrol:

- [Our extensive documentation][docs]
- [Patrol 4.0 with Web support announcement][article_4x]
- [The article about the test bundling feature in Patrol 2.0][article_2x]
- [The first stable 1.0 release article][article_1x]
- [The article about the first public release][article_0x]

## Patrol finders

`patrol_finders` is a streamlined, high-level API on top of `flutter_test`.

It provides a [new custom finder system][custom finders] to make Flutter widget
tests more concise and understandable, and writing them – faster and more fun.

## Installation

```console
$ dart pub add patrol_finders --dev
```

## Documentation

[Read our docs](https://patrol.leancode.co) to learn more.

### Custom finders

```dart
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:patrol_finders/patrol_finders.dart';

void main() {
  patrolWidgetTest(
    'logs in successfully',
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      /// Finds widget with Key('emailInput') and enters text into it
      ///
      await $(#emailInput).enterText('user@leancode.co');

      /// Finds widget with Key('passwordInput') and enters text into it
      await $(#passwordInput).enterText('ny4ncat');

      // Finds all widgets with text 'Log in' which are descendants of widgets
      // with Key('box1'), which are descendants of a Scaffold widget, and taps
      // on the first 'Log in' text.
      await $(Scaffold).$(#box1).$('Log in').tap();

      // Finds all Scrollables which have Text descendant, and taps on the first
      // Scrollable
      await $(Scrollable).containing(Text).tap();

      // Finds all Scrollables which have ElevatedButton descendant and Text
      // descendant, and taps on the first Scrollable
      await $(Scrollable).containing(ElevatedButton).containing(Text).tap();

      // Finds all Scrollables which have TextButton descendant which has Text
      // descendant, and taps on the first Scrollabke
      await $(Scrollable).containing($(TextButton).$(Text)).tap();
    },
  );
}

```

[custom finders]: https://patrol.leancode.co/finders/overview
[patrol_badge]: https://img.shields.io/pub/v/patrol?label=patrol
[patrol_finders_badge]: https://img.shields.io/pub/v/patrol_finders?label=patrol_finders
[patrol_cli_badge]: https://img.shields.io/pub/v/patrol_cli?label=patrol_cli
[leancode_lint_badge]: https://img.shields.io/badge/code%20style-leancode__lint-blue
[patrol_github_stars]: https://img.shields.io/github/stars/leancodepl/patrol
[patrol_x]: https://img.shields.io/twitter/follow/patrol_leancode
[patrol_discord]: https://img.shields.io/discord/1167030497612922931?color=blue&logo=discord
[patrol_link]: https://pub.dev/packages/patrol
[patrol_finders_link]: https://pub.dev/packages/patrol_finders
[patrol_cli_link]: https://pub.dev/packages/patrol_cli
[leancode_lint_link]: https://pub.dev/packages/leancode_lint
[patrol_x_link]: https://x.com/patrol_leancode
[patrol_github_link]: https://github.com/leancodepl/patrol
[patrol_discord_link]: https://discord.gg/ukBK5t4EZg
[github_patrol]: https://github.com/leancodepl/patrol/tree/master/packages/patrol
[github_patrol_finders]: https://github.com/leancodepl/patrol/tree/master/packages/patrol_finders
[github_patrol_cli]: https://github.com/leancodepl/patrol/tree/master/packages/patrol_cli
[docs]: https://patrol.leancode.co
[docs_finders]: https://patrol.leancode.co/finders/overview
[promo_graphics]: ../../docs/assets/promo.png
[article_0x]: https://leancode.co/blog/patrol-flutter-first-ui-testing-framework
[article_1x]: https://leancode.co/blog/patrol-1-0-powerful-flutter-ui-testing-framework
[article_2x]: https://leancode.co/blog/patrol-2-0-improved-flutter-ui-testing
[article_4x]: https://leancode.co/blog/patrol-4-0-release
[integration_test]: https://github.com/flutter/flutter/tree/master/packages/integration_test
[hot restart]: https://patrol.leancode.co/cli-commands/develop
