# maestro_test

[![maestro_test on pub.dev][pub_badge]][pub_link]
[![codestyle][pub_badge_style]][pub_badge_link]

`maestro_test` package builds on top of `flutter_driver` to make it easy to
control the native device from Dart. It does this by using Android's
[UIAutomator][ui_automator] library.

It also provides a new custom selector system to make writing Flutter widget
tests more concisce, and writing them faster & more fun.

### Installation

Add `maestro_test` as a dev dependency in `pubspec.yaml`:

```
dev_dependencies:
  maestro_test: ^0.3.3
```

### Accessing native platform features

```dart
// example/integration_test/example_test.dart
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'counter state is the same after going to Home and going back',
    ($) async {
      await tester.pumpWidgetAndSettle(const MyApp());

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await maestro.pressHome();
      await maestro.pressDoubleRecentApps();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');

      await maestro.openNotifications();
      await maestro.pressBack();
    },
  );
}
```

### Custom selectors

```dart
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  maestroTest(
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

[pub_badge]: https://img.shields.io/pub/v/maestro_test.svg
[pub_link]: https://pub.dartlang.org/packages/maestro_test
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[ui_automator]: https://developer.android.com/training/testing/other-components/ui-automator
