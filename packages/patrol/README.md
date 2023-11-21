# patrol

[![patrol on pub.dev][pub_badge]][pub_link]
[![codestyle][pub_badge_style]][pub_badge_link]

`patrol` package builds on top of `flutter_test` and `integration_test` to make
it easy to control the native UI from Dart test code. Created and supported by
[LeanCode](https://leancode.co).

It must be used together with [patrol_cli].

It also provides a new custom finder system to make Flutter widget tests more
concise and understandable, and writing them – faster and more fun. It you want
to only use custom finders, check out
[patrol_finders](https://pub.dev/packages/patrol_finders).

## Installation

```console
$ dart pub add patrol --dev
```

## Usage

Patrol has 2 main features – [native automation] and [custom finders].

[Read our docs](https://patrol.leancode.co) to learn more about them!

### Accessing native platform features

```dart
// example/integration_test/example_test.dart
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

      await $.native.pressHome();
      await $.native.pressDoubleRecentApps();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');

      await $.native.openNotifications();
      await $.native.pressBack();
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

[patrol_cli]: https://pub.dev/packages/patrol_cli
[pub_badge]: https://img.shields.io/pub/v/patrol.svg
[pub_link]: https://pub.dartlang.org/packages/patrol
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[native automation]: https://patrol.leancode.co/native/overview
[custom finders]: https://patrol.leancode.co/finders/overview
