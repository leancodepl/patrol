import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Signature for callback to [maestroTest].
typedef MaestroTesterCallback = Future<void> Function(
  MaestroTester maestroTester,
);

late final MaestroTester $;

const With = 'with';

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
  MaestroFinder(this.finder, this.tester);

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

  MaestroFinder $(dynamic matching, [String? chainer, dynamic of]) {
    if ((chainer == null) != (of == null)) {
      throw ArgumentError(
        '`chainer` and `of` must be both null or both non-null',
      );
    }

    final isComplex = chainer != null && of != null;

    if (isComplex && chainer != With) {
      throw ArgumentError('chainer must be "with"');
    }

    if (!isComplex) {
      return MaestroFinder(
        find.descendant(
          of: finder,
          matching: _createFinder(matching),
        ),
        tester,
      );
    }

    return MaestroFinder(
      find.descendant(
        of: finder,
        matching: find.ancestor(
          of: _createFinder(of),
          matching: _createFinder(matching),
        ),
      ),
      tester,
    );
  }
}

class MaestroTester {
  MaestroTester(this.tester);

  final WidgetTester tester;

  Future<void> pump(
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

  MaestroFinder call(dynamic matching, [String? chainer, dynamic of]) {
    return MaestroFinder(
      _createFinder(matching),
      tester,
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

  throw ArgumentError(
    'expression must be of type `Type`, `Symbol`, or `String`',
  );
}

extension SymbolX on Symbol {
  String get name {
    final symbol = toString();
    return symbol.substring(8, symbol.length - 2);
  }
}

/* void main() {
  // final sel = $('#scaffold > #box1 > #tile2 > #icon2'); // old
  $('#scaffold').$('#box1').$('#tile2').$('#icon2').tap(); // new

  // selects the first scrollable with a Text descendant
  $(Scrollable, 'with', Text);

  // taps on a the first Button inside the first Scrollable
  $(Scrollable).$(Button).tap();
}
 */
