# patrol

[![patrol_finders on pub.dev][pub_badge]][pub_link]
[![codestyle][pub_badge_style]][pub_badge_link]

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

[pub_badge]: https://img.shields.io/pub/v/patrol_finders.svg
[pub_link]: https://pub.dartlang.org/packages/patrol_finders
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[custom finders]: https://patrol.leancode.co/finders/overview
