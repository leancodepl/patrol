library custom_selectors;

import 'dart:async';

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
    required MaestroTester tester,
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

  /// [MaestroTester] that this [MaestroFinder] wraps.
  final MaestroTester tester;

  /// Taps on the first widget resolved by this finder.
  ///
  /// See also:
  ///  - [WidgetController.tap] (which [WidgetTester] extends from)
  Future<void> tap({bool? andSettle}) async {
    await tester.tester.tap(finder.first);
    await tester.performPump(andSettle);
  }

  /// Enters text into the first widget resolved by this finder.
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after
  /// entering text. If you want to disable this behavior, pass `false` to
  /// [andSettle].
  ///
  /// See also:
  ///  - [WidgetTester.enterText]
  Future<void> enterText(String text, {bool? andSettle}) async {
    await tester.tester.enterText(finder.first, text);
    await tester.performPump(andSettle);
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

  /// Waits until this finder finds at least one visible widget.
  ///
  /// It throws a [TimeoutException] if more than [MaestroTester.findTimeout]
  /// passed and no widgets were found.
  Future<MaestroFinder> get visible async {
    final end = DateTime.now().add(tester.findTimeout);

    while (hitTestable().evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        throw TimeoutException('Timed out waiting for $finder');
      }

      await tester.tester.pump(const Duration(milliseconds: 100));
    }

    return this;
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
  bool matches(Element candidate) {
    return (finder as MatchFinder).matches(candidate);
  }

  @override
  bool precache() => finder.precache();

  @override
  MaestroFinder hitTestable({Alignment at = Alignment.center}) {
    return MaestroFinder(finder: finder.hitTestable(at: at), tester: tester);
  }

  @override
  String get description => finder.description;

  @override
  String toString() => finder.toString();
}
