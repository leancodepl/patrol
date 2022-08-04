library custom_finders;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/common.dart';
import 'package:maestro_test/src/custom_finders/exceptions.dart';
import 'package:meta/meta.dart';

import 'maestro_tester.dart';

/// Maestro custom finder, also known as `$`.
///
/// This is decorator around [Finder] that extends it with Maestro features, but
/// also preserves Finder's behavior.
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
  @internal
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

  /// Taps on the first visible (i.e hit testable) widget resolved by this
  /// finder.
  ///
  /// ```dart
  /// await $(#createAccount).tap();
  /// ```
  ///
  /// If the finder resolves to more than 1 widget, you can choose which one to
  /// tap on:
  ///
  /// ```dart
  /// await $(TextButton).at(2).tap(); // tap on the third TextButton
  /// ```
  ///
  /// See also:
  ///  - [WidgetController.tap] (which [WidgetTester] extends from)
  // TODO: Add timeout
  Future<void> tap({bool? andSettle}) async {
    await tester.tester.tap((await visible()).first);
    await tester.performPump(andSettle);
  }

  /// Drags in [direction] until the first widget resolved by this finder
  /// becomes visible.
  ///
  /// If [view] is null, it defaults to the first found [Scrollable].
  ///
  /// See also:
  ///  - [MaestroTester.dragUntilVisible]
  Future<MaestroFinder> dragTo({
    Finder? view,
    Direction direction = Direction.down,
    double step = 16,
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
    bool? andSettle,
  }) async {
    view ??= createFinder(Scrollable);

    final resolvedFinder = await tester.dragUntilVisible(
      finder: finder,
      view: view,
      direction: direction,
      step: step,
      maxIteration: maxIteration,
      duration: duration,
      andSettle: andSettle,
    );

    return resolvedFinder;
  }

  /// Enters text into the first visible (i.e hit testable) widget resolved by
  /// this finder.
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after
  /// entering text. If you want to disable this behavior, set [andSettle] to
  /// false.
  ///
  /// See also:
  ///  - [WidgetTester.enterText]
  // TODO: Add timeout
  Future<void> enterText(String text, {bool? andSettle}) async {
    await tester.tester.enterText((await visible()).first, text);
    await tester.performPump(andSettle);
  }

  /// If the first widget resolved by this [MaestroFinder] matches a [Text]
  /// widget, then this method returns its data.
  ///
  /// If you want to make sure that that widget is visible, first use [visible] method:
  ///
  /// ```dart
  /// expect(await $(Key('Sign in Button')).visible.text, 'Sign in');
  /// ```
  ///
  /// Otherwise it throws an exception.
  String? get text {
    final elements = finder.evaluate();
    if (elements.isEmpty) {
      throw MaestroFinderFoundNothingException(finder: this);
    }

    final firstWidget = elements.first.widget;

    if (firstWidget is! Text) {
      throw Exception(
        'The first ${firstWidget.runtimeType} widget resolved by this finder '
        'is not a Text widget',
      );
    }

    return firstWidget.data;
  }

  /// Shorthand for [MaestroFinder.resolve].
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
  /// Throws a [MaestroFinderFoundNothingException] if more time than specified
  /// by timeout passed and no widgets were found.
  ///
  /// Timeout is globally set by [MaestroTester.findTimeout]. If you want to
  /// override this global setting, set [timeout].
  Future<MaestroFinder> visible({Duration? timeout}) async {
    final end = DateTime.now().add(timeout ?? tester.findTimeout);

    while (hitTestable().evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        throw MaestroFinderFoundNothingException(finder: this);
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
  Iterable<Element> get allCandidates => finder.allCandidates;

  @override
  String get description => finder.description;

  @override
  String toString() => finder.toString();
}

/// Useful methods that make chained finders more readable.
extension ActionCombiner on Future<MaestroFinder> {
  /// Same as [MaestroFinder.tap], but on a [MaestroFinder] which is not yet
  /// visible.
  Future<void> tap({bool? andSettle}) async {
    await (await this).tap(andSettle: andSettle);
  }

  /// Same as [MaestroFinder.enterText], but on a [MaestroFinder] which is not
  /// yet visible.
  Future<void> enterText(String text, {bool? andSettle}) async {
    await (await this).enterText(text, andSettle: andSettle);
  }
}
