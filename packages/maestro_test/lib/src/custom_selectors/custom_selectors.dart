import 'dart:io' as io;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

/// [MaestroTester] wraps a [WidgetTester].
///
/// Usually, you won't create a [MaestroFinder] instance directly. Instead,
/// you'll use the [MaestroTester] which is provided by [MaestroTesterCallback]
/// in [maestroTest], like this:
///
/// ```dart
/// import 'package:maestro_test/maestro_test.dart';
///
/// void main() {
///   maestroTest('Counter increments smoke test', (maestroTester) async {
///     await maestroTester.pumpWidgetAndSettle(const MyApp());
///     await maestroTester(#startAppButton).tap();
///   });
/// }
/// ```
///
/// To make test code more concise, `maestroTester` variable is usually called
/// `$`, like this:
///
/// ```dart
/// import 'package:maestro_test/maestro_test.dart';
/// void main() {
///   maestroTest('Counter increments smoke test', ($) async {
///     await $.pumpWidgetAndSettle(const MyApp());
///     await $(#startAppButton).tap();
///   });
/// }
/// ```
/// You can call [MaestroTester] just like a normal method, because it is a
/// [callable class][callable-class].
///
/// [callable-class]:
/// https://dart.dev/guides/language/language-tour#callable-classes
class MaestroTester {
  /// Creates a new [MaestroTester] with the given WidgetTester [tester].
  const MaestroTester(this.tester);

  /// Widget tester that this [MaestroTester] wraps.
  final WidgetTester tester;

  /// Returns a [MaestroFinder] that matches [matching].
  ///
  /// Refer to
  MaestroFinder call(dynamic matching) {
    return _$(
      matching: matching,
      tester: tester,
      parentFinder: null,
    );
  }

  /// See [WidgetTester.pumpWidget].
  Future<void> pumpWidget(
    Widget widget, [
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) async {
    await tester.pumpWidget(widget, duration, phase);
  }

  /// See [WidgetTester.pumpAndSettle].
  Future<void> pumpAndSettle([
    Duration duration = const Duration(milliseconds: 100),
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration timeout = const Duration(minutes: 10),
  ]) async {
    await tester.pumpAndSettle();
  }

  /// A convenience method combining [WidgetTester.pumpWidget] and
  /// [WidgetTester.pumpAndSettle].
  Future<void> pumpWidgetAndSettle(
    Widget widget, [
    Duration? pumpWidgetDuration,
    EnginePhase pumpWidgetPhase = EnginePhase.sendSemanticsUpdate,
    Duration pumpAndSettleDuration = const Duration(milliseconds: 100),
    Duration pumpAndSettleTimeout = const Duration(minutes: 10),
    EnginePhase pumpAndSettlePhase = EnginePhase.sendSemanticsUpdate,
  ]) async {
    await tester.pumpWidget(widget, pumpWidgetDuration, pumpWidgetPhase);
    await tester.pumpAndSettle(
      pumpAndSettleDuration,
      pumpAndSettlePhase,
      pumpAndSettleTimeout,
    );
  }

  //// A convenience method combining [WidgetTester.dragUntilVisible] and
  /// [WidgetTester.pumpAndSettle].
  ///
  /// Specify [index] to select on which [finder] to tap. It defaults to the
  /// first finder.
  ///
  /// See also:
  ///  - [WidgetController.dragUntilVisible].
  Future dragUntilVisible(
    Finder finder,
    Finder view,
    Offset moveStep, {
    int index = 0,
    int maxIteration = 50,
    Duration dragDuration = const Duration(milliseconds: 50),
    Duration pumpDuration = const Duration(milliseconds: 100),
    EnginePhase pumpPhase = EnginePhase.sendSemanticsUpdate,
    Duration pumpTimeout = const Duration(minutes: 10),
  }) async {
    await tester.dragUntilVisible(
      finder.at(index),
      view,
      moveStep,
      maxIteration: maxIteration,
      duration: dragDuration,
    );

    await tester.pumpAndSettle(pumpDuration, pumpPhase, pumpTimeout);
  }
}

/// A decorator around [Finder] that provides Maestro _custom selector_ (also
/// known as `$`).
class MaestroFinder extends MatchFinder {
  /// Creates a new [MaestroFinder] with the given [finder] and [tester].
  ///
  /// Usually, you won't use this constructor directly. Instead, you'll use the
  /// [MaestroTester] (which is provided by [MaestroTesterCallback] in
  /// [maestroTest]) and [MaestroFinder.$].
  MaestroFinder({required this.finder, required this.tester});

  /// Finder that this [MaestroFinder] wraps.
  final Finder finder;

  /// Widget tester that this [MaestroFinder] wraps.
  final WidgetTester tester;

  /// Taps on the widget resolved by this finder.
  ///
  /// If more than one widget is found, the [index]-th widget is tapped, instead
  /// of throwing an exception (like [WidgetTester.tap] does).
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after tap. If
  /// you want to disable this behavior, pass `false` to [andSettle].
  ///
  /// See also:
  ///  - [WidgetController.tap] (which [WidgetTester] extends from)
  Future<void> tap({bool andSettle = true, int index = 0}) async {
    await tester.tap(finder.at(index));

    if (andSettle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  /// Enters text into the widget resolved by this finder.
  ///
  /// If more than one widget is found, [text] in entered into the [index]-th
  /// widget, instead of throwing an exception (like [WidgetTester.enterText]
  /// does).
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after
  /// entering text. If you want to disable this behavior, pass `false` to
  /// [andSettle].
  ///
  /// See also:
  ///  - [WidgetTester.enterText]
  Future<void> enterText(
    String text, {
    bool andSettle = true,
    int index = 0,
  }) async {
    await tester.enterText(finder.at(index), text);

    if (andSettle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  /// If this [MaestroFinder] matches a [Text] widget, then this method returns
  /// its data.
  ///
  /// Otherwise it throws an error.
  String? get text {
    return (finder.evaluate().first.widget as Text).data;
  }

  /// Returns a [MaestroFinder] that looks for [matching] in descendants of this
  /// [MaestroFinder].
  ///
  /// The [Finder] that this method returns depends on the type of [matching].
  /// Supported [matching] types are:
  /// - [Type], which translates to [CommonFinders.byType]
  /// - [Key], which translates to [CommonFinders.byKey]
  /// - [Symbol], which translates to [CommonFinders.byKey]
  /// - [String], which translates to [CommonFinders.text]
  /// - [Pattern], which translates to [CommonFinders.textContaining]. Example
  ///   [Pattern] is a [RegExp].
  /// - [IconData], which translates to [CommonFinders.byIcon]
  /// - [MaestroFinder], which returns a [Finder] that the [MaestroFinder]
  ///   passed as [matching] resolves to.
  MaestroFinder $(dynamic matching) {
    return _$(
      matching: matching,
      tester: tester,
      parentFinder: this,
    );
  }

  /// Returns a [MaestroFinder] that this method was called on.
  ///
  /// Checks whether the [Widget] that this [MaestroFinder] was called on has
  /// [matching] as a descendant.
  MaestroFinder withDescendant(dynamic matching) {
    return MaestroFinder(
      tester: tester,
      finder: find.ancestor(
        of: _createFinder(matching),
        matching: finder,
      ),
    );
  }

  @override
  Iterable<Element> evaluate() {
    return finder.evaluate();
  }

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return finder.apply(candidates);
  }

  @override
  String get description => finder.description;

  @override
  bool matches(Element candidate) {
    return (finder as MatchFinder).matches(candidate);
  }
}

/// Creates a [Finder] from [expression].
///
/// To learn more about rules, see [MaestroFinder.$].
Finder _createFinder(dynamic expression) {
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

MaestroFinder _$({
  required dynamic matching,
  required WidgetTester tester,
  required Finder? parentFinder,
}) {
  if (parentFinder != null) {
    return MaestroFinder(
      tester: tester,
      finder: find.descendant(
        of: parentFinder,
        matching: _createFinder(matching),
      ),
    );
  }

  return MaestroFinder(
    tester: tester,
    finder: _createFinder(matching),
  );
}
