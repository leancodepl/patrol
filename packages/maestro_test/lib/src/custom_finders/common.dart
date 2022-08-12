import 'dart:io' as io;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/maestro_finder.dart';
import 'package:maestro_test/src/custom_finders/maestro_tester.dart';
import 'package:maestro_test/src/extensions.dart';
import 'package:meta/meta.dart';

/// Signature for callback to [maestroTest].
typedef MaestroTesterCallback = Future<void> Function(MaestroTester $);

/// Like [testWidgets], but with support for Maestro custom finders.
///
/// To customize the Maestro-specific configuration, set [config].
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
  dynamic tags,
  MaestroTestConfig config = const MaestroTestConfig(),
}) {
  return testWidgets(
    description,
    (widgetTester) async {
      final maestroTester = MaestroTester(
        widgetTester,
        appName: config.appName,
        andSettle: config.andSettle,
        findTimeout: config.findTimeout,
      );
      await callback(maestroTester);
      if (config.sleep != Duration.zero) {
        maestroTester.log(
          'sleeping for ${config.sleep.inSeconds} seconds',
          name: 'maestroTest',
        );
        io.sleep(config.sleep);
        maestroTester.log('done sleeping', name: 'maestroTest');
      }
    },
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
  );
}

/// Maestro-specific test configuration.
class MaestroTestConfig {
  /// Creates a new [MaestroTestConfig].
  const MaestroTestConfig({
    this.findTimeout = const Duration(seconds: 10),
    this.sleep = Duration.zero,
    this.andSettle = true,
    this.appName,
  });

  /// Amount of time to sleep after successful test execution. If set to
  /// [Duration.zero], then the test completes immediately after successful
  /// execution.
  final Duration sleep;

  /// Amount of time
  final Duration findTimeout;

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [MaestroFinder.tap] and [MaestroFinder]. If false, only
  /// [WidgetTester.pump] is called.
  final bool andSettle;

  /// Name of the application under test.
  final String? appName;
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
/// - [MaestroFinder], which returns a [Finder] that the [MaestroFinder]
///   resolves to, for example:
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
    return find.text(matching, findRichText: true);
  }

  if (matching is Pattern) {
    // TODO: Re-add `findRichText: true` when minimum SDK version is >= 2.17
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
