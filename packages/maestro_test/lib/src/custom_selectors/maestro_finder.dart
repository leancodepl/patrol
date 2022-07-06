library custom_selectors;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_selectors/common.dart';

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
    return resolve(
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
  String get description => finder.description;

  @override
  bool matches(Element candidate) {
    return (finder as MatchFinder).matches(candidate);
  }
}
