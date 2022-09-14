library custom_finders;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/custom_finders/common.dart';
import 'package:patrol/src/custom_finders/exceptions.dart';
import 'package:patrol/src/custom_finders/patrol_tester.dart';
import 'package:patrol/src/extensions.dart';

/// Creates a [Finder] from [matching].
///
/// This function maps types onto Flutter finders.
///
/// ### Usage
///
/// Usually, you won't use this function directly. Instead, you'll use
/// [PatrolTester.call] and [PatrolFinder.$], like this:
///
/// ```dart
/// patrolTest(
///    'increase counter text',
///    ($) async {
///      // calls createFinder method under the hood
///      await $(Scaffold).$(#passwordTextField).enterText('my password');
///    },
/// );
/// ```
///
/// ### What does this method accept?
///
/// The [Finder] that this method returns depends on the type of [matching].
/// Supported types of [matching] are:
/// - [Type], which translates to [CommonFinders.byType], for example:
///   ```dart
///   final finder = createFinder(Button);
///   ```
/// - [Key], which translates to [CommonFinders.byKey], for example:
///   ```dart
///   final finder = createFinder(Key('signInWithGoogle'));
///   ```
/// - [Symbol], which translates to [CommonFinders.byKey], for example:
///   ```dart
///   final finder = createFinder(#signInWithGoogle);
///   ```
/// - [String], which translates to [CommonFinders.text], for example:
///   ```dart
///   final finder = createFinder('Sign in with Google');
///   ```
/// - [Pattern], which translates to [CommonFinders.textContaining]. Example
///   [Pattern] is a [RegExp].
///   ```dart
///   final finder = createFinder(RegExp('.*in with.*'));
///   ```
/// - [IconData], which translates to [CommonFinders.byIcon], for example:
///   ```dart
///   final finder = createFinder(Icons.add);
///   ```
/// - [PatrolFinder], which returns a [Finder] that the [PatrolFinder] resolves
///   to, for example:
///   ```dart
///   final finder = createFinder($(Text('Sign in with Google')));
///   ```
/// - [Finder], which simply returns the [Finder] itself.
///   ```dart
///   final finder = createFinder(find.text('Log in'));
///   ```
///
/// See also:
///  - [PatrolTester.call]
///  - [PatrolFinder.$]
/// -  [PatrolFinder.resolve]
@visibleForTesting
Finder createFinder(dynamic matching) {
  if (matching is Type) {
    return find.byType(matching);
  }

  if (matching is Key) {
    return find.byKey(matching);
  }

  if (matching is Symbol) {
    return find.byKey(Key(matching.name));
  }

  if (matching is String) {
    return find.text(matching, findRichText: true);
  }

  if (matching is Pattern) {
    return find.textContaining(matching, findRichText: true);
  }

  if (matching is IconData) {
    return find.byIcon(matching);
  }

  if (matching is PatrolFinder) {
    return matching.finder;
  }

  if (matching is Finder) {
    return matching;
  }

  throw ArgumentError(
    'expression of type ${matching.runtimeType} is not one of supported types `Type`, `Key`, `Symbol`, `String`, `Pattern`, `IconData`, or `PatrolFinder`',
  );
}

/// Patrol custom finder, also known as `$`.
///
/// This is decorator around [Finder] that extends it with Patrol features, but
/// also preserves Finder's behavior.
class PatrolFinder extends MatchFinder {
  /// Creates a new [PatrolFinder] with the given [finder] and [tester].
  ///
  /// Usually, you won't use this constructor directly. Instead, you'll use the
  /// [PatrolTester] (which is provided by [PatrolTesterCallback] in
  /// [patrolTest]) and [PatrolFinder.$].
  @internal
  PatrolFinder({required this.finder, required this.tester});

  /// Returns a [PatrolFinder] that looks for [matching] in descendants of
  /// [parentFinder]. If [parentFinder] is null, it looks for [matching]
  /// anywhere in the widget tree.
  @internal
  factory PatrolFinder.resolve({
    required dynamic matching,
    required Finder? parentFinder,
    required PatrolTester tester,
  }) {
    final finder = createFinder(matching);

    if (parentFinder != null) {
      return PatrolFinder(
        tester: tester,
        finder: find.descendant(
          of: parentFinder,
          matching: finder,
        ),
      );
    }

    return PatrolFinder(
      tester: tester,
      finder: finder,
    );
  }

  /// Finder that this [PatrolFinder] wraps.
  final Finder finder;

  /// [PatrolTester] that this [PatrolFinder] wraps.
  final PatrolTester tester;

  /// Waits until this finder finds at least 1 visible widget and then taps on
  /// it.
  ///
  /// Example:
  /// ```dart
  /// // taps on the first widget having Key('createAccount')
  /// await $(#createAccount).tap();
  /// ```
  ///
  /// If the finder finds more than 1 widget, you can choose which one to tap
  /// on:
  ///
  /// ```dart
  /// // taps on the third TextButton widget
  /// await $(TextButton).at(2).tap();
  /// ```
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after
  /// tapping. If you want to disable this behavior, set [andSettle] to false.
  ///
  /// See also:
  ///  - [PatrolFinder.waitUntilVisible], which is used to wait for the widget
  ///    to appear
  ///  - [WidgetController.tap]
  Future<void> tap({
    bool? andSettle,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) async {
    await tester.tap(
      this,
      andSettle: andSettle,
      visibleTimeout: visibleTimeout,
      settleTimeout: settleTimeout,
    );
  }

  /// Waits until this finder finds at least 1 visible widget and then enters
  /// text into it.
  ///
  /// Example:
  /// ```dart
  /// // enters text into the first widget having Key('email')
  /// await $(#email).enterText(user@example.com);
  /// ```
  ///
  /// If the finder finds more than 1 widget, you can choose which one to enter
  /// text into:
  ///
  /// ```dart
  /// // enters text into the third TextField widget
  /// await $(TextField).at(2).enterText('Code ought to be lean');
  /// ```
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] after
  /// entering text. If you want to disable this behavior, set [andSettle] to
  /// false.
  ///
  /// See also:
  ///  - [PatrolFinder.waitUntilVisible], which is used to wait for the widget
  ///    to appear
  ///  - [WidgetTester.enterText]
  Future<void> enterText(
    String text, {
    bool? andSettle,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) async {
    await tester.enterText(
      this,
      text,
      andSettle: andSettle,
      visibleTimeout: visibleTimeout,
      settleTimeout: settleTimeout,
    );
  }

  /// Shorthand for [PatrolTester.scrollUntilVisible].
  ///
  /// Scrolls [scrollable] in its scrolling direction until this finders finds
  /// at least one visible widget.
  ///
  /// It also ensures that [scrollable] is visible, by calling
  /// [PatrolFinder.waitUntilVisible].
  ///
  /// See also:
  ///  - [PatrolTester.scrollUntilVisible], which this method wraps
  Future<PatrolFinder> scrollTo({
    Finder? scrollable,
    double step = defaultScrollDelta,
    int maxScrolls = defaultScrollMaxIteration,
    Duration duration = const Duration(milliseconds: 50),
  }) {
    return tester.scrollUntilVisible(
      finder: finder,
      scrollable: scrollable,
      delta: step,
      maxScrolls: maxScrolls,
      duration: duration,
    );
  }

  /// Waits until this finder finds at least one widget.
  ///
  /// Throws a [WaitUntilVisibleTimeoutException] if no widgets  found.
  ///
  /// Timeout is globally set by [PatrolTester.config.visibleTimeout]. If you
  /// want to override this global setting, set [timeout].
  Future<PatrolFinder> waitUntilExists({Duration? timeout}) {
    return tester.waitUntilExists(this, timeout: timeout);
  }

  /// Waits until this finder finds at least one visible widget.
  ///
  /// Throws a [WaitUntilVisibleTimeoutException] if more time than specified by
  /// timeout passed and no widgets were found.
  ///
  /// Timeout is globally set by [PatrolTester.config.visibleTimeout]. If you
  /// want to override this global setting, set [timeout].
  Future<PatrolFinder> waitUntilVisible({Duration? timeout}) {
    return tester.waitUntilVisible(this, timeout: timeout);
  }

  /// If the first widget found by this finder is a [Text] or [RichText] widget,
  /// then this method returns its data.
  ///
  /// If you want to make sure that that widget is visible, first use
  /// [waitUntilVisible] method:
  ///
  /// ```dart
  /// expect(await $(Key('Sign in Button')).waitUntilVisible().text, 'Sign in');
  /// ```
  ///
  /// Otherwise it throws an exception.
  String? get text {
    final elements = finder.evaluate();
    // TODO: Throw a better error than "StateError, Bad state: No element" if no
    // element is found

    final firstWidget = elements.first.widget;

    if (firstWidget is Text) {
      return firstWidget.data;
    }

    if (firstWidget is RichText) {
      return (firstWidget.text as TextSpan).toPlainText();
    }

    throw Exception(
      'The first ${firstWidget.runtimeType} widget resolved by this finder '
      'is not a Text or RichText widget',
    );
  }

  /// Shorthand for [PatrolFinder.resolve].
  PatrolFinder $(dynamic matching) {
    return PatrolFinder.resolve(
      matching: matching,
      tester: tester,
      parentFinder: this,
    );
  }

  /// Returns [PatrolFinder] that this method was called on and which contains
  /// [matching] as a descendant.
  PatrolFinder containing(dynamic matching) {
    return PatrolFinder(
      tester: tester,
      finder: find.ancestor(
        of: createFinder(matching),
        matching: finder,
      ),
    );
  }

  /// Returns true if this finder finds at least 1 widget.
  bool get exists => evaluate().isNotEmpty;

  /// Returns true if this finder finds at least 1 visible widget.
  bool get visible {
    final isVisible = hitTestable().evaluate().isNotEmpty;
    if (isVisible == true) {
      assert(
        exists == true,
        'visible returned true, but exists returned false',
      );
    }

    return isVisible;
  }

  // region Overriden fields

  @override
  Iterable<Element> evaluate() => finder.evaluate();

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return finder.apply(candidates);
  }

  @override
  PatrolFinder get first {
    // TODO: Throw a better error than "StateError, Bad state: No element" if no
    // element is found
    return PatrolFinder(tester: tester, finder: finder.first);
  }

  @override
  PatrolFinder get last {
    // TODO: Throw a better error than "StateError, Bad state: No element" if no
    // element is found
    return PatrolFinder(
      tester: tester,
      finder: finder.last,
    );
  }

  @override
  PatrolFinder at(int index) {
    // TODO: Throw a better error than "StateError, Bad state: No element" if no
    // element is found
    return PatrolFinder(
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
  PatrolFinder hitTestable({Alignment at = Alignment.center}) {
    return PatrolFinder(finder: finder.hitTestable(at: at), tester: tester);
  }

  @override
  Iterable<Element> get allCandidates => finder.allCandidates;

  @override
  String get description => finder.description;

  @override
  String toString() => finder.toString();

// endregion
}

/// Useful methods that make chained finders more readable.
extension ActionCombiner on Future<PatrolFinder> {
  /// Same as [PatrolFinder.tap], but on a [PatrolFinder] which is not yet
  /// visible.
  Future<void> tap({
    bool? andSettle,
    Duration? visibleTimeout,
    Duration? settleTimoeut,
  }) async {
    await (await this).tap(
      andSettle: andSettle,
      visibleTimeout: visibleTimeout,
      settleTimeout: settleTimoeut,
    );
  }

  /// Same as [PatrolFinder.enterText], but on a [PatrolFinder] which is not yet
  /// visible.
  Future<void> enterText(
    String text, {
    bool? andSettle,
    Duration? visibleTimeout,
    Duration? settleTimoeut,
  }) async {
    await (await this).enterText(
      text,
      andSettle: andSettle,
      visibleTimeout: visibleTimeout,
      settleTimeout: settleTimoeut,
    );
  }
}
