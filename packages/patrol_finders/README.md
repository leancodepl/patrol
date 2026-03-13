# Patrol

[![patrol on pub.dev][patrol_badge]][patrol_link]
[![patrol_cli on pub.dev][patrol_cli_badge]][patrol_cli_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![patrol_discord]][patrol_discord_link]
[![code style][leancode_lint_badge]][leancode_lint_link]
[![patrol_github_stars]][patrol_github_link]
[![patrol_x]][patrol_x_link]

A powerful, multiplatform E2E UI testing framework for Flutter apps that
overcomes the limitations of integration_test by handling native interactions.
Developed by [LeanCode](https://leancode.co) since 2022, battle-tested and
shaped by production-grade experience.

![Patrol promotial graphics][promo_graphics]

Learn more about Patrol:

- [Our extensive documentation][docs]
- [How Patrol 4.0 Makes Cross-Platform Flutter Testing Possible][article_4x]
- [Simplifying Flutter Web Testing: Patrol Web][article_web]
- [Patrol VS Code Extension - A Better Way to Run and Debug Flutter UI Tests][article_vscode]

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

## 🛠️ Maintained by LeanCode

<div align="center">
  <a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme">
    <img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />
  </a>
</div>

This package is built with 💙 by **[LeanCode](https://leancode.co?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol](https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)** – the next-gen testing framework for Flutter.

- **Production-Ready** – We use this package in apps with millions of users.
- **Full-Cycle Product Development** – We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**](https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages](https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads)

</div>

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
[docs]: https://patrol.leancode.co
[docs_finders]: https://patrol.leancode.co/finders/overview
[promo_graphics]: ../../assets/promo_banner.png
[article_web]: https://leancode.co/blog/patrol-web-support
[article_4x]: https://leancode.co/blog/patrol-4-0-release
[article_vscode]: https://leancode.co/blog/patrol-vs-code-extension
[integration_test]: https://github.com/flutter/flutter/tree/master/packages/integration_test
