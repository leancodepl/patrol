# maestro_test

[![maestro_test on pub.dev][pub_badge]][pub_link]
[![code style][pub_badge_style]][pub_badge_link]

`maestro_test` package builds on top of `flutter_driver` to make it easy to
control the native device from Dart. It does this by using Android's
[UIAutomator][ui_automator] library.

### Installation

Add `maestro_test` as a dev dependency in `pubspec.yaml`:

```
dev_dependencies:
  maestro_test: ^0.2.0
```

### Usage

```dart
// integration_test/app_test.dart
import 'package:example/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  final maestro = Maestro.forTest();

  testWidgets(
    "counter state is the same after going to Home and switching apps",
    (WidgetTester tester) async {
      Text findCounterText() {
        return tester
            .firstElement(find.byKey(const ValueKey('counterText')))
            .widget as Text;
      }

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText().data, '1');

      await maestro.pressHome();

      await maestro.pressDoubleRecentApps();

      expect(findCounterText().data, '1');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText().data, '2');

      await maestro.openNotifications();
      await maestro.pressBack();
    },
  );
}

```

[pub_badge]: https://img.shields.io/pub/v/maestro_test.svg
[pub_link]: https://pub.dartlang.org/packages/maestro_test
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[ui_automator]: https://developer.android.com/training/testing/other-components/ui-automator
