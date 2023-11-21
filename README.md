# Patrol

[![patrol on pub.dev][patrol_badge]][patrol_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![patrol_cli on pub.dev][patrol_cli_badge]][patrol_cli_link]
[![code style][leancode_lint_badge]][leancode_lint_link]
[![powered by][docs_page_badge]][docs_page_link]

![Patrol promotial graphics][promo_graphics]

Simple yet powerful Flutter-first UI testing framework overcoming limitations of
`flutter_test`, `integration_test`, and `flutter_driver`. Created and supported
by [LeanCode](https://leancode.co).

Learn more about Patrol:

- [Our extensive documentation][docs]
- [The article about the test bundling feature in Patrol 2.0][article_2x]
- [The first stable 1.0 release article][article_1x]
- [The article about the first public release][article_0x]

## Patrol custom finders

Flutter's finders are powerful, but not very intuitive to use.

We took them and made something awesome.

Thanks to Patrol's custom finders, you'll take your tests from this:

```dart
testWidgets('signs up', (WidgetTester tester) async {
  await tester.pumpWidget(AwesomeApp());
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(Key('emailTextField')),
    'charlie@root.me',
  );
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(Key('nameTextField')),
    'Charlie',
  );
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(Key('passwordTextField')),
    'ny4ncat',
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(Key('termsCheckbox')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(Key('signUpButton')));
  await tester.pumpAndSettle();

  expect(find.text('Welcome, Charlie!'), findsOneWidget);
});
```

to this:

```dart
patrolTest('signs up', (PatrolIntegrationTester $) async {
  await $.pumpWidgetAndSettle(AwesomeApp());

  await $(#emailTextField).enterText('charlie@root.me');
  await $(#nameTextField).enterText('Charlie');
  await $(#passwordTextField).enterText('ny4ncat');
  await $(#termsCheckbox).tap();
  await $(#signUpButton).tap();

  await $('Welcome, Charlie!').waitUntilVisible();
});
```

[Learn more about custom finders in the docs][docs_finders]!

Patrol's custom finders are also available standalone in [the patrol_finders
package][patrol_finders_link].

## Patrol native automation

Flutter's default [integration_test] package can't interact with the OS your
Flutter app is running on. This makes it impossible to test many critical
business features, such as:

- granting runtime permissions
- signing into the app which through WebView or Google Services
- tapping on notifications
- [much more!](https://patrol.leancode.co/native/feature-parity)

Patrol's native automation feature solves these problems:

```dart
void main() {
  patrolTest('showtime', (PatrolIntegrationTester $) async {
    await $.pumpWidgetAndSettle(AwesomeApp());
    // prepare network conditions
    await $.native.enableCellular();
    await $.native.disableWifi();

    // toggle system theme
    await $.native.enableDarkMode();

    // handle native location permission request dialog
    await $.native.selectFineLocation();
    await $.native.grantPermissionWhenInUse();

    // tap on the first notification
    await $.native.openNotifications();
    await $.native.tapOnNotificationByIndex(0);
  });
}

```

## CLI

See [packages/patrol_cli][github_patrol_cli].

The CLI is needed to enable Patrol's native automation feature in integration
tests. It also makes development of integration tests much faster thanks to [Hot
Restart].

To run widget tests, you can continue to use `flutter test`.

## Package

See [packages/patrol][github_patrol].

[patrol_badge]: https://img.shields.io/pub/v/patrol?label=patrol
[patrol_finders_badge]: https://img.shields.io/pub/v/patrol_finders?label=patrol_finders
[patrol_cli_badge]: https://img.shields.io/pub/v/patrol_cli?label=patrol_cli
[leancode_lint_badge]: https://img.shields.io/badge/code%20style-leancode__lint-black
[docs_page_badge]: https://img.shields.io/badge/documentation-docs.page-34C4AC.svg?style
[patrol_link]: https://pub.dev/packages/patrol
[patrol_finders_link]: https://pub.dev/packages/patrol_finders
[patrol_cli_link]: https://pub.dev/packages/patrol_cli
[leancode_lint_link]: https://pub.dev/packages/leancode_lint
[docs_page_link]: https://docs.page
[github_patrol]: https://github.com/leancodepl/patrol/tree/master/packages/patrol
[github_patrol_finders]: https://github.com/leancodepl/patrol/tree/master/packages/patrol_finders
[github_patrol_cli]: https://github.com/leancodepl/patrol/tree/master/packages/patrol_cli
[docs]: https://patrol.leancode.co
[docs_finders]: https://patrol.leancode.co/finders/overview
[promo_graphics]: docs/assets/promo.png
[article_0x]: https://leancode.co/blog/patrol-flutter-first-ui-testing-framework
[article_1x]: https://leancode.co/blog/patrol-1-0-powerful-flutter-ui-testing-framework
[article_2x]: https://leancode.co/blog/patrol-2-0-improved-flutter-ui-testing
[integration_test]: https://github.com/flutter/flutter/tree/master/packages/integration_test
[hot restart]: https://patrol.leancode.co/cli-commands/develop
