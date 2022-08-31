library custom_finders;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/common.dart';
import 'package:maestro_test/src/custom_finders/exceptions.dart';
import 'package:maestro_test/src/extensions.dart';
import 'package:meta/meta.dart';

import 'maestro_tester.dart';

/// Creates a [Finder] from [matching].
///
/// This function maps types onto Flutter finders.
///
/// ### Usage
///
/// Usually, you won't use this function directly. Instead, you'll use
/// [MaestroTester.call] and [MaestroFinder.$], like this:
///
/// ```dart
/// maestroTest(
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
/// - [MaestroFinder], which returns a [Finder] that the [MaestroFinder]
///   resolves to, for example:
///   ```dart
///   final finder = createFinder($(Text('Sign in with Google')));
///   ```
/// - [Finder], which simply returns the [Finder] itself.
///   ```dart
///   final finder = createFinder(find.text('Log in'));
///   ```
///
/// See also:
///  - [MaestroTester.call]
///  - [MaestroFinder.$]
/// -  [MaestroFinder.resolve]
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

  if (matching is MaestroFinder) {
    return matching.finder;
  }

  if (matching is Finder) {
    return matching;
  }

  throw ArgumentError(
    'expression of type ${matching.runtimeType} is not one of supported types `Type`, `Key`, `Symbol`, `String`, `Pattern`, `IconData`, or `MaestroFinder`',
  );
}

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

  /// Waits until this finder finds at least 1 visible widget and then taps on
  /// it.
  ///
  /// Example:
  /// ```dart
  /// // taps on the first widget having Key('createAccount')
  /// await $(#createAccount).tap();
  /// ```
  ///
  /// If the finder resolves to more than 1 widget, you can choose which one to
  /// tap on:
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
  ///  - [MaestroFinder.waitUntilVisible], which is used to wait for the widget
  ///    to appear
  ///  - [WidgetController.tap]
  Future<void> tap({
    bool? andSettle,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) async {
    final resolvedFinder = await waitUntilVisible(timeout: visibleTimeout);
    await tester.tester.tap(resolvedFinder.first);
    await tester.performPump(
      andSettle: andSettle,
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
  /// If the finder resolves to more than 1 widget, you can choose which one to
  /// enter text into:
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
  ///  - [MaestroFinder.waitUntilVisible], which is used to wait for the widget
  ///    to appear
  ///  - [WidgetTester.enterText]
  Future<void> enterText(
    String text, {
    bool? andSettle,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) async {
    final resolvedFinder = await waitUntilVisible(timeout: visibleTimeout);
    await tester.tester.enterText(resolvedFinder.first, text);
    await tester.performPump(
      andSettle: andSettle,
      settleTimeout: settleTimeout,
    );
  }

  /// Scrolls [scrollable] in its scrolling direction until this finders finds
  /// at least one visible widget.
  ///
  /// It also ensures that [scrollable] is visible, by calling
  /// [MaestroFinder.waitUntilVisible].
  ///
  /// If [scrollable] is null, it defaults to the first found [Scrollable].
  ///
  /// See also:
  ///  - [MaestroTester.scrollUntilVisible], which this method wraps
  Future<MaestroFinder> scrollTo({
    Finder? scrollable,
    double step = 16,
    int maxScrolls = 200,
    Duration duration = const Duration(milliseconds: 50),
  }) async {
    scrollable ??= find.byType(Scrollable);

    final scrollableMaestroFinder = await MaestroFinder(
      finder: scrollable,
      tester: tester,
    ).waitUntilVisible();

    final resolvedFinder = await tester.scrollUntilVisible(
      finder: finder,
      scrollable: scrollableMaestroFinder.first,
      delta: step,
      maxScrolls: maxScrolls,
      duration: duration,
    );

    return resolvedFinder;
  }

  /// If the first widget resolved by this [MaestroFinder] matches a [Text]
  /// widget, then this method returns its data.
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

  /// Returns true if this finder finds at least 1 widget.
  bool get exists => evaluate().isNotEmpty;

  /// Returns true if this finder finds at least 1 visible widget.
  bool get visible => hitTestable().evaluate().isNotEmpty;

  /// Waits until this finder finds at least one widget.
  ///
  /// Throws a [WaitUntilVisibleTimedOutException] if no widgets  found.
  ///
  /// Timeout is globally set by [MaestroTester.config.visibleTimeout]. If you
  /// want to override this global setting, set [timeout].
  Future<MaestroFinder> waitUntilExists({Duration? timeout}) async {
    timeout ??= tester.config.existsTimeout;
    final end = DateTime.now().add(timeout);

    while (evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        throw WaitUntilExistsTimedOutException(finder: this, duration: timeout);
      }

      await tester.tester.pump(const Duration(milliseconds: 100));
    }

    return this;
  }

  /// Waits until this finder finds at least one visible widget.
  ///
  /// Throws a [WaitUntilVisibleTimedOutException] if more time than specified
  /// by timeout passed and no widgets were found.
  ///
  /// Timeout is globally set by [MaestroTester.config.visibleTimeout]. If you
  /// want to override this global setting, set [timeout].
  Future<MaestroFinder> waitUntilVisible({Duration? timeout}) async {
    timeout ??= tester.config.visibleTimeout;
    final end = DateTime.now().add(timeout);

    while (hitTestable().evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        throw WaitUntilVisibleTimedOutException(
          finder: this,
          duration: timeout,
        );
      }

      await tester.tester.pump(const Duration(milliseconds: 100));
    }

    return this;
  }

  // region Overriden fields

  @override
  Iterable<Element> evaluate() => finder.evaluate();

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return finder.apply(candidates);
  }

  @override
  MaestroFinder get first {
    // TODO: Throw a better error than "StateError, Bad state: No element" if no
    // element is found
    return MaestroFinder(tester: tester, finder: finder.first);
  }

  @override
  MaestroFinder get last {
    // TODO: Throw a better error than "StateError, Bad state: No element" if no
    // element is found
    return MaestroFinder(
      tester: tester,
      finder: finder.last,
    );
  }

  @override
  MaestroFinder at(int index) {
    // TODO: Throw a better error than "StateError, Bad state: No element" if no
    // element is found
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

// endregion
}

/// Useful methods that make chained finders more readable.
extension ActionCombiner on Future<MaestroFinder> {
  /// Same as [MaestroFinder.tap], but on a [MaestroFinder] which is not yet
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

  /// Same as [MaestroFinder.enterText], but on a [MaestroFinder] which is not
  /// yet visible.
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
