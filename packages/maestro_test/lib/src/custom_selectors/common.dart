import 'dart:io' as io;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_selectors/maestro_finder.dart';
import 'package:maestro_test/src/custom_selectors/maestro_tester.dart';
import 'package:maestro_test/src/extensions.dart';
import 'package:meta/meta.dart';

/// Signature for callback to [maestroTest].
typedef MaestroTesterCallback = Future<void> Function(MaestroTester $);

/// Like [testWidgets], but with Maestro custom selector support.
///
/// If you want to not close the app immediately after the test completes, use
/// [sleep].
///
/// To call [WidgetTester.pump] instead of [WidgetTester.pumpAndSettle] after
/// actions such as [MaestroFinder.tap] and [MaestroFinder.enterText], set
/// [andSettle] to `false`.
///
/// ### Custom selectors
///
/// Custom selectors greatly simplify writing widget tests.
///
/// ### Using the default [WidgetTester]
/// If you need to do something using Flutter's [WidgetTester], you can access
/// it like this:
///
/// ```dart
/// maestroTest(
///    'increase counter text',
///    ($) async {
///      await $.tester.tap(find.byIcon(Icons.add));
///    },
/// );
/// ```
@isTest
void maestroTest(
  String description,
  MaestroTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  Duration sleep = Duration.zero,
  String? appName,
  bool andSettle = true,
  dynamic tags,
}) {
  return testWidgets(
    description,
    (widgetTester) async {
      final maestroTester = MaestroTester(
        widgetTester,
        appName: appName,
        andSettle: andSettle,
      );
      await callback(maestroTester);
      if (sleep != Duration.zero) {
        maestroTester.log(
          'sleeping for ${sleep.inSeconds} seconds',
          name: 'maestroTest',
        );
        io.sleep(sleep);
        maestroTester.log('sleeping finished', name: 'maestroTest');
      }
    },
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
  );
}

/// Creates a [Finder] from [matching].
///
/// ### Usage
///
/// Usually, you won't use `createFinder` directly. Instead, you'll use
/// [MaestroTester.call] and [MaestroFinder.$], like this:
///
/// ```dart
/// maestroTest(
///    'increase counter text',
///    ($) async {
///      // calls createFinder method under the hood
///      await $(Scaffold).$(#passwordTextField).enterText('my password');
///    },
/// );
/// ```
///
/// ### What does this method accept?
///
/// The [Finder] that this method returns depends on the type of [matching].
/// Supported types of [matching] are:
/// - [Type], which translates to [CommonFinders.byType], for example:
///   ```dart
///   final finder = createFinder(Button);
///   ```
/// - [Key], which translates to [CommonFinders.byKey], for example:
///   ```dart
///   final finder = createFinder(Key('signInWithGoogle'));
///   ```
/// - [Symbol], which translates to [CommonFinders.byKey], for example:
///   ```dart
///   final finder = createFinder(#signInWithGoogle);
///   ```
/// - [String], which translates to [CommonFinders.text], for example:
///   ```dart
///   final finder = createFinder('Sign in with Google');
///   ```
/// - [Pattern], which translates to [CommonFinders.textContaining]. Example
///   [Pattern] is a [RegExp].
///   ```dart
///   final finder = createFinder(RegExp('.*in with.*'));
///   ```
/// - [IconData], which translates to [CommonFinders.byIcon], for example:
///   ```dart
///   final finder = createFinder(Icons.add);
///   ```
/// - [MaestroFinder], which returns a [Finder] that the [MaestroFinder], for
///   example: passed as [matching] resolves to.
///   ```dart
///   final finder = createFinder($(Text('Sign in with Google')));
///   ```
/// - [Finder], which simply returns the [Finder] itself.
///   ```dart
///   final finder = createFinder(find.text('Log in'));
///   ```
///
/// See also:
///  - [MaestroTester.call]
///  - [MaestroFinder.$]
/// -  [MaestroFinder.resolve]
Finder createFinder(dynamic matching) {
  if (matching is Type) {
    return find.byType(matching);
  }

  if (matching is Key) {
    return find.byKey(matching);
  }

  if (matching is Symbol) {
    return find.byKey(Key(matching.name));
  }

  if (matching is String) {
    return find.text(matching);
  }

  if (matching is Pattern) {
    return find.textContaining(matching);
  }

  if (matching is IconData) {
    return find.byIcon(matching);
  }

  if (matching is MaestroFinder) {
    return matching.finder;
  }

  if (matching is Finder) {
    return matching;
  }

  throw ArgumentError(
    'expression of type ${matching.runtimeType} is not one of supported types `Type`, `Key`, `Symbol`, `String`, `Pattern`, `IconData`, or `MaestroFinder`',
  );
}
