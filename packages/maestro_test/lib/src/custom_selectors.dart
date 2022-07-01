import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/extensions.dart';

/// Signature for callback to [maestroTest].
typedef MaestroTesterCallback = Future<void> Function(MaestroTester $);

const withDescendant = Chainer.withDescendant;

/// Specifies a relation between two [Widget]s.
enum Chainer {
  /// It signals to Maestro custom selector system that a "widget_1 CONTAINS
  /// widget_2" check should be performed.
  withDescendant,
}

/// Like [testWidgets], but with Maestro custom selector support.
///
/// ### Using the default [WidgetTester]
/// If you need to do something using Flutter's [WidgetTester], you can access
/// it like this:
///
/// ```dart
/// maestroTest(
///    'increase counter text',
///    (maestroTester) async {
///      await maestroTester.tester.tap(find.byIcon(Icons.add));
///    },
/// );
/// ```
void maestroTest(
  String description,
  MaestroTesterCallback callback,
) {
  return testWidgets(description, (widgetTester) async {
    final $ = MaestroTester(widgetTester);
    await callback($);
  });
}

class MaestroFinder extends Finder {
  MaestroFinder({required this.finder, required this.tester});

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
      parentFinder: finder,
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
  Iterable<Element> apply(Iterable<Element> candidates) {
    return finder.apply(candidates);
  }

  @override
  String get description => finder.description;
}

class MaestroTester {
  MaestroTester(this.tester);

  final WidgetTester tester;

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

  MaestroFinder call(dynamic matching) {
    return _$(
      matching: matching,
      tester: tester,
      parentFinder: null,
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

  throw ArgumentError(
    'expression must be of type `Type`, `Symbol`, `String`, or `Pattern`',
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
