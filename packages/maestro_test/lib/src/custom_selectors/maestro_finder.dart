library custom_selectors;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_selectors/common.dart';

import 'maestro_tester.dart';

/// A decorator around [Finder] that provides Maestro _custom selector_ (also
/// known as `$`).
class MaestroFinder extends MatchFinder {
  /// Creates a new [MaestroFinder] with the given [finder] and [tester].
  ///
  /// Usually, you won't use this constructor directly. Instead, you'll use the
  /// [MaestroTester] (which is provided by [MaestroTesterCallback] in
  /// [maestroTest]) and [MaestroFinder.$].
  MaestroFinder({required this.finder, required this.tester});

  /// Returns a [MaestroFinder] that looks for [matching] in descendants of
  /// [parentFinder]. If [parentFinder] is null, it looks for [matching]
  /// anywhere in the widget tree.
  factory MaestroFinder.resolve({
    required dynamic matching,
    required Finder? parentFinder,
    required WidgetTester tester,
  }) {
    final finder = createFinder(matching);

    if (parentFinder != null) {
      return MaestroFinder(
        tester: tester,
        finder: find.descendant(
          of: parentFinder,
          matching: finder,
        ),
      );
    }

    return MaestroFinder(
      tester: tester,
      finder: finder,
    );
  }

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

  /// A shortcut for [MaestroFinder.resolve]
  MaestroFinder $(dynamic matching) {
    return MaestroFinder.resolve(
      matching: matching,
      tester: tester,
      parentFinder: this,
    );
  }

  /// Returns [MaestroFinder] that this method was called on and which contains
  /// [matching] as a descendant.
  MaestroFinder containing(dynamic matching) {
    return MaestroFinder(
      tester: tester,
      finder: find.ancestor(
        of: createFinder(matching),
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
  MaestroFinder get first {
    return MaestroFinder(tester: tester, finder: finder.first);
  }

  @override
  MaestroFinder get last {
    return MaestroFinder(
      tester: tester,
      finder: finder.last,
    );
  }

  @override
  MaestroFinder at(int index) {
    return MaestroFinder(
      tester: tester,
      finder: finder.at(index),
    );
  }

  @override
  String get description => finder.description;

  @override
  bool matches(Element candidate) {
    return (finder as MatchFinder).matches(candidate);
  }

  @override
  String toString() => finder.toString();
}
