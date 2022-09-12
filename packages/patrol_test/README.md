# patrol_test

[![patrol_test on pub.dev][pub_badge]][pub_link]
[![codestyle][pub_badge_style]][pub_badge_link]

`patrol_test` package builds on top of `flutter_driver` to make it easy to
control the native device from Dart. It does this by using Android's
[UIAutomator][ui_automator] library.

It also provides a new custom finder system to make Flutter widget tests more
concise and understandable, and writing them – faster and more fun.

### Installation

```bash
$ dart pub add patrol_test
```

### Accessing native platform features

```dart
// example/integration_test/example_test.dart
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_test/patrol_test.dart';

void main() {
  final patrol = Patrol.forTest();

  patrolTest(
    'counter state is the same after going to Home and going back',
    ($) async {
      await tester.pumpWidgetAndSettle(const MyApp());

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await patrol.pressHome();
      await patrol.pressDoubleRecentApps();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');

      await patrol.openNotifications();
      await patrol.pressBack();
    },
  );
}
```

### Custom finders

```dart
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_test/patrol_test.dart';

void main() {
  patrolTest(
    'logs in successfully',
    ($) async {
      await $.pumpWidgetAndSettle(const MyApp());

      await $(#emailInput).enterText('user@leancode.co');
      await $(#passwordInput).enterText('ny4ncat');

      // Find widget with text 'Log in' which is a descendant of widget with key
      // box1 which is a descendant of a Scaffold widget and tap on it.
      await $(Scaffold).$(#box1).$('Log in').tap();

      // Selects all Scrollables which have Text descendant
      $(Scrollable).containing(Text);

      // Selects all Scrollables which have a Button descendant which has a Text descendant
      $(Scrollable).containing($(Button).containing(Text));

      // Selects all Scrollables which have a Button descendant and a Text descendant
      $(Scrollable).containing(Button).containing(Text);
    },
  );
}
```

[pub_badge]: https://img.shields.io/pub/v/patrol_test.svg
[pub_link]: https://pub.dartlang.org/packages/patrol_test
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[ui_automator]: https://developer.android.com/training/testing/other-components/ui-automator
