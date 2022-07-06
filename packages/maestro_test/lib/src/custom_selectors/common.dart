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
/// If you want to finish the test immediately after it completes, pass
/// [Duration.zero] for [sleep]. By default, Maestro sleeps for a bit to let you
/// see how things looked like afte the test finished.
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
  Duration sleep = const Duration(seconds: 5),
  dynamic tags,
}) {
  return testWidgets(
    description,
    (widgetTester) async {
      await callback(MaestroTester(widgetTester));
      io.sleep(sleep);
    },
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
  );
}

/// Creates a [Finder] from [expression].
///
/// To learn more about rules, see [MaestroFinder.$].
Finder createFinder(dynamic expression) {
  if (expression is Type) {
    return find.byType(expression);
  }

  if (expression is Key) {
    return find.byKey(expression);
  }

  if (expression is Symbol) {
    return find.byKey(Key(expression.name));
  }

  if (expression is String) {
    return find.text(expression);
  }

  if (expression is Pattern) {
    return find.textContaining(expression);
  }

  if (expression is IconData) {
    return find.byIcon(expression);
  }

  if (expression is MaestroFinder) {
    return expression.finder;
  }

  throw ArgumentError(
    'expression must be of type `Type`, `Symbol`, `String`, `Pattern`, `IconData`, or `MaestroFinder`',
  );
}

MaestroFinder resolve({
  required dynamic matching,
  required WidgetTester tester,
  required Finder? parentFinder,
}) {
  if (parentFinder != null) {
    return MaestroFinder(
      tester: tester,
      finder: find.descendant(
        of: parentFinder,
        matching: createFinder(matching),
      ),
    );
  }

  return MaestroFinder(
    tester: tester,
    finder: createFinder(matching),
  );
}
