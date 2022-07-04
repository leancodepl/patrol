import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/extensions.dart';
import 'package:meta/meta.dart';

/// Signature for callback to [maestroTest].
typedef MaestroTesterCallback = Future<void> Function(MaestroTester $);

/// Like [testWidgets], but with Maestro custom selector support.
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
}) {
  return testWidgets(
    description,
    (widgetTester) => callback(MaestroTester(widgetTester)),
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
  );
}

class MaestroFinder extends MatchFinder {
  MaestroFinder({required this.finder, required this.tester}) {
    print('Created MaestroFinder with finder: $this');
  }

  final Finder finder;
  final WidgetTester tester;

  Future<void> tap({bool andSettle = true, int index = 0}) async {
    await tester.tap(finder.at(index));

    if (andSettle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

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

  MaestroFinder $(dynamic matching) {
    return _$(
      matching: matching,
      tester: tester,
      parentFinder: this,
    );
  }

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

class MaestroTester {
  MaestroTester(this.tester);

  final WidgetTester tester;

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
  Future<void> pumpAndSettle(
      [Duration duration = const Duration(milliseconds: 100),
      EnginePhase phase = EnginePhase.sendSemanticsUpdate,
      Duration timeout = const Duration(minutes: 10)]) async {
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
}

Finder _createFinder(dynamic expression) {
  if (expression is Type) {
    return find.byType(expression);
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
