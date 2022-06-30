import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/extensions.dart';

/// Signature for callback to [maestroTest].
typedef MaestroTesterCallback = Future<void> Function(
  MaestroTester maestroTester,
);

late final MaestroTester $;

const withDescendant = Chainers.withDescendant;

/// Specifies a relation between two [Widget]s.
enum Chainers {
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
  return testWidgets(description, (tester) async {
    final maestroTester = MaestroTester(tester);
    $ = maestroTester;
    await callback(maestroTester);
  });
}

class MaestroFinder {
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
  String? get text {
    return (finder.evaluate().first.widget as Text).data;
  }

  MaestroFinder $(dynamic matching, [Chainers? chainer, dynamic of]) {
    return _$(
      matching: matching,
      chainer: chainer,
      of: of,
      tester: tester,
      initialFinder: finder,
    );
  }
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

  MaestroFinder call(dynamic matching, [Chainers? chainer, dynamic of]) {
    return _$(
      matching: matching,
      chainer: chainer,
      of: of,
      tester: tester,
      initialFinder: null,
    );
  }
}

/// [expression] must be either [Type] or a String.
///
/// If [expression] is a String, then it must start with '#' (which represents
/// ValueKey).
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
    'expression must be of type `Type`, `Symbol`, or `String`',
  );
}

bool _isComplex(Chainers? chainer, dynamic of) {
  if ((chainer == null) != (of == null)) {
    throw ArgumentError(
      '`chainer` and `of` must be both null or both non-null',
    );
  }

  final isComplex = chainer != null && of != null;

  if (isComplex && chainer != Chainers.withDescendant) {
    throw ArgumentError('chainer must be "with"');
  }

  return isComplex;
}

MaestroFinder _$({
  required dynamic matching,
  required Chainers? chainer,
  required dynamic of,
  required WidgetTester tester,
  required Finder? initialFinder,
}) {
  final isComplex = _isComplex(chainer, of);

  if (initialFinder == null) {
    if (isComplex) {
      return MaestroFinder(
        tester: tester,
        finder: find.ancestor(
          of: _createFinder(of),
          matching: _createFinder(matching),
        ),
      );
    }

    return MaestroFinder(
      tester: tester,
      finder: _createFinder(matching),
    );
  }

  if (isComplex) {
    return MaestroFinder(
      tester: tester,
      finder: find.descendant(
        of: initialFinder,
        matching: find.ancestor(
          of: _createFinder(of),
          matching: _createFinder(matching),
        ),
      ),
    );
  }

  return MaestroFinder(
    tester: tester,
    finder: find.descendant(
      of: initialFinder,
      matching: _createFinder(matching),
    ),
  );
}
