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

## Learn more about Patrol:

- [Our extensive documentation][docs]
- [How Patrol 4.0 Makes Cross-Platform Flutter Testing Possible][article_4x]
- [Simplifying Flutter Web Testing: Patrol Web][article_web]
- [Patrol VS Code Extension - A Better Way to Run and Debug Flutter UI Tests][article_vscode]

## How can we help you:

Patrol is an open-source framework created and maintained by LeanCode.
However, if your company wants to scale fast and accelerate Patrol’s
adoption, we offer a set of value-added services on top of the core framework.

You can find out more below:

- 🚀  [Automate Flutter app testing with Patrol][automate_flutter_app_testing_with_patrol]
- 🚀  [Patrol Setup & Patrol Training][patrol_setup_and_training]

## Patrol

`patrol` package builds on top of `flutter_test` and `integration_test` to make
it easy to control the native UI from Dart test code. It must be used together with [`patrol_cli`][patrol_cli_link].

It also provides a new custom finder system to make Flutter widget tests more
concise and understandable, and writing them – faster and more fun. It you want
to only use custom finders, check out
[`patrol_finders`](https://pub.dev/packages/patrol_finders).

## Installation

```console
$ dart pub add patrol --dev
```

## Usage

Patrol has 2 main features – [native automation] and [custom finders].

[Read our docs](https://patrol.leancode.co) to learn more about them!

### Accessing native platform features

```dart
// example/patrol_test/example_test.dart
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'counter state is the same after going to home and going back',
    ($) async {
      await $.pumpWidgetAndSettle(const MyApp());

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $.platform.mobile.pressHome();
      await $.platform.mobile.pressDoubleRecentApps();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');

      await $.platform.mobile.openNotifications();
      await $.platform.mobile.pressBack();
    },
  );
}
```

### Custom finders

```dart
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'logs in successfully',
    ($) async {
      await $.pumpWidgetAndSettle(const MyApp());

      await $(#emailInput).enterText('user@leancode.co');
      await $(#passwordInput).enterText('ny4ncat');

      // Finds all widgets with text 'Log in' which are descendants of widgets with key
      // box1, which are descendants of a Scaffold widget and tap on the first one.
      await $(Scaffold).$(#box1).$('Log in').tap();

      // Finds all Scrollables which have Text descendant
      $(Scrollable).containing(Text);

      // Finds all Scrollables which have a Button descendant which has a Text descendant
      $(Scrollable).containing($(Button).containing(Text));

      // Finds all Scrollables which have a Button descendant and a Text descendant
      $(Scrollable).containing(Button).containing(Text);
    },
  );
}
```

[native automation]: https://patrol.leancode.co/native/overview
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
[docs]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[docs_finders]: https://patrol.leancode.co/finders/overview
[promo_graphics]: ../../assets/promo_banner.png
[article_web]: https://leancode.co/blog/patrol-web-support?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_4x]: https://leancode.co/blog/patrol-4-0-release?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_vscode]: https://leancode.co/blog/patrol-vs-code-extension?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[integration_test]: https://github.com/flutter/flutter/tree/master/packages/integration_test
[automate_flutter_app_testing_with_patrol]: https://leancode.co/products/automated-ui-testing-in-flutter?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[patrol_setup_and_training]: https://leancode.co/products/patrol-setup-training?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme