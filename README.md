# Patrol

[![patrol on pub.dev][patrol_badge]][patrol_link]
[![patrol_cli on pub.dev][patrol_cli_badge]][patrol_cli_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![patrol_discord]][patrol_discord_link]
[![code style][leancode_lint_badge]][leancode_lint_link]
[![patrol_github_stars]][patrol_github_link]
[![patrol_x]][patrol_x_link]

Simple yet powerful Flutter-first UI testing framework overcoming limitations of
`flutter_test`, `integration_test`, and `flutter_driver`. Created and supported
by [LeanCode](https://leancode.co?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme).

[![Patrol promotial graphics][promo_graphics]][docs]

## Learn more about Patrol:

- [Our extensive documentation][docs]
- [How Patrol 4.0 Makes Cross-Platform Flutter Testing Possible][article_4x]
- [Simplifying Flutter Web Testing: Patrol Web][article_web]
- [Patrol VS Code Extension - A Better Way to Run and Debug Flutter UI Tests][article_vscode]

## How can we help you:

Patrol is an open-source framework created and maintained by LeanCode.
However, if your company wants to scale fast and accelerate Patrol’s
adoption, we offer a set of value-added services on top of the core framework.

You can find out more below:

- 🚀  [Automate Flutter app testing with Patrol][automate_flutter_app_testing_with_patrol]
- 🚀  [Patrol Setup & Patrol Training][patrol_setup_and_training]

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
    await $.platform.mobile.enableCellular();
    await $.platform.mobile.disableWifi();

    // toggle system theme
    await $.platform.mobile.enableDarkMode();

    // handle native location permission request dialog
    await $.platform.mobile.selectFineLocation();
    await $.platform.mobile.grantPermissionWhenInUse();

    // tap on the first notification
    await $.platform.mobile.openNotifications();
    await $.platform.mobile.tapOnNotificationByIndex(0);
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

## CI/CD Workflows

See [.github/WORKFLOWS.md][github_workflows] for detailed documentation about all GitHub Actions workflows, including test schedules, Flutter versions, and deployment pipelines.

## Patrol contracts generator

1. (Optionally) add new request type:

```dart
class OpenAppRequest {
  late String appId;
}
```

2. Add new method to `NativeAutomator`:

```dart
abstract class NativeAutomator<IOSServer, AndroidServer, DartClient> {
  ...
  void openApp(OpenAppRequest request);
  ...
}
```

3. Run `gen_from_schema` script, few files will be updated

## Develop patrol_cli

If you have previously activated patrol_cli run:

```bash
dart pub global deactivate patrol_cli
```

then

```bash
cd packages/patrol_cli
flutter pub global activate -s path .
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

[patrol_badge]: https://img.shields.io/pub/v/patrol?label=patrol
[patrol_finders_badge]: https://img.shields.io/pub/v/patrol_finders?label=patrol_finders
[patrol_cli_badge]: https://img.shields.io/pub/v/patrol_cli?label=patrol_cli
[leancode_lint_badge]: https://img.shields.io/badge/code%20style-leancode__lint-black
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
[github_patrol]: https://github.com/leancodepl/patrol/tree/master/packages/patrol
[github_patrol_cli]: https://github.com/leancodepl/patrol/tree/master/packages/patrol_cli
[github_workflows]: https://github.com/leancodepl/patrol/blob/master/.github/WORKFLOWS.md
[docs]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[docs_finders]: https://patrol.leancode.co/finders/overview
[promo_graphics]: assets/promo_banner.png
[article_web]: https://leancode.co/blog/patrol-web-support?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_4x]: https://leancode.co/blog/patrol-4-0-release?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_vscode]: https://leancode.co/blog/patrol-vs-code-extension?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[integration_test]: https://github.com/flutter/flutter/tree/master/packages/integration_test
[automate_flutter_app_testing_with_patrol]: https://leancode.co/products/automated-ui-testing-in-flutter?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[patrol_setup_and_training]: https://leancode.co/products/patrol-setup-training?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
