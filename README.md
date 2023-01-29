# Patrol

Simple yet powerful Flutter-native UI testing framework eliminating limitations
of `flutter_test`, `integration_test`, and `flutter_driver`.

[![patrol on pub.dev][patrol_badge]][patrol_link] [![patrol_cli on
pub.dev][patrol_cli_badge]][patrol_cli_link] [![code
style][leancode_lint_badge]][leancode_lint_link] [![powered
by][docs_page_badge]][docs_page_link]

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
    'bartek@awesome.com',
  );
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(Key('nameTextField')),
    'Bartek',
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

  expect(find.text('Welcome, Bartek!'), findsOneWidget);
});
```

to this:

```dart
patrolTest('signs up', (PatrolTester $) async {
  await $.pumpWidgetAndSettle(AwesomeApp());

  await $(#emailTextField).enterText('bartek@awesome.com');
  await $(#nameTextField).enterText('Bartek');
  await $(#passwordTextField).enterText('ny4ncat');
  await $(#termsCheckbox).tap();
  await $(#signUpButton).tap();
  expect($('Welcome, Bartek!'), findsOneWidget);
});
```

Learn more in our [extensive documentation][patrol_docs]!

## CLI

See [packages/patrol_cli][github_patrol_cli].

The CLI is needed to enable Patrol's native automation feature in integration
tests.

To run widget tests, you can simply use `flutter test`.

## Package

See [packages/patrol][github_patrol].

[github_patrol_cli]: https://github.com/leancodepl/patrol/tree/master/packages/patrol_cli
[github_patrol]: https://github.com/leancodepl/patrol/tree/master/packages/patrol
[patrol_badge]: https://img.shields.io/pub/v/patrol?label=patrol
[patrol_link]: https://pub.dev/packages/patrol
[patrol_cli_badge]: https://img.shields.io/pub/v/patrol_cli?label=patrol_cli
[patrol_cli_link]: https://pub.dev/packages/patrol_cli
[leancode_lint_badge]: https://img.shields.io/badge/code%20style-leancode__lint-black
[leancode_lint_link]: https://pub.dev/packages/leancode_lint
[docs_page_badge]: https://img.shields.io/badge/documentation-docs.page-34C4AC.svg?style
[docs_page_link]: https://docs.page
[patrol_docs]: https://patrol.leancode.co
