# Maestro

Simple, easy-to-learn, Flutter-native UI testing framework eliminating
limitations of `flutter_driver`.

[![maestro_test on pub.dev][pub_badge_test]][pub_link_test]

[![maestro_cli on pub.dev][pub_badge_cli]][pub_link_cli]

## CLI

The Maestro CLI allows you to run the `maestro` command from terminal run your
Maestro-powered tests:

### Installation

```bash
dart pub global activate maestro_cli
```

### Usage

First, initialize Maestro in your project:

```
$ maestro bootstrap
```

Then, to run tests using `maestro_test`::

```
$ maestro drive
```

## Package

The `maestro_test` package builds on top of `flutter_driver` to make it easy to
control the native device. It does this by using Android's
[UIAutomator][ui_automator] library.

### Installation

Add `maestro_test` as a dev dependency in `pubspec.yaml`:

```
dev_dependencies:
  maestro_test: ^1.0.0
```

### Usage

```dart
// integration_test/app_test.dart
import 'package:example/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Automator.init(verbose: true);
  final automator = Automator.instance;

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

      await automator.pressHome();

      await automator.pressDoubleRecentApps();

      expect(findCounterText().data, '1');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText().data, '2');

      await automator.openNotifications();
    },
  );
}

```

## Release process

1. Create a [git annotated tag][annotated_tag]:

```
git tag -a "maestro_cli-v0.0.4" -m "Release notes go here"
```

2. Push it! GitHub Actions will take care of the rest.

[pub_badge_test]: https://img.shields.io/pub/v/maestro_test.svg
[pub_link_test]: https://pub.dartlang.org/packages/maestro_test
[pub_badge_cli]: https://img.shields.io/pub/v/maestro_cli.svg
[pub_link_cli]: https://pub.dartlang.org/packages/maestro_cli
[ui_automator]: https://developer.android.com/training/testing/other-components/ui-automator
[annotated_tag]: https://git-scm.com/book/en/v2/Git-Basics-Tagging#_annotated_tags
