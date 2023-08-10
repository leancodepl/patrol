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

[pub_badge]: https://img.shields.io/pub/v/patrol_finders.svg
[pub_link]: https://pub.dartlang.org/packages/patrol_finders
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[custom finders]: https://patrol.leancode.co/finders/overview
