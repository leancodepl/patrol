import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Common configuration for [PatrolTester] and [PatrolFinder].
class PatrolTesterConfig {
  /// Creates a new [PatrolTesterConfig].
  const PatrolTesterConfig({
    this.existsTimeout = const Duration(seconds: 10),
    this.visibleTimeout = const Duration(seconds: 10),
    this.settleTimeout = const Duration(seconds: 10),
    @Deprecated('Use settleBeahvior argument instead') this.andSettle = true,
    this.settlePolicy = SettlePolicy.settle,
  });

  /// Time after which [PatrolFinder.waitUntilExists] fails if it doesn't find
  /// an existing widget.
  ///
  /// If a widget exists, it doesn't mean that it is visible.
  ///
  /// On the other hand, if a widget is visible, then it always exists.
  final Duration existsTimeout;

  /// Time after which [PatrolFinder.waitUntilVisible] fails if it doesn't find
  /// a visible widget.
  ///
  /// [PatrolFinder.waitUntilVisible] is used internally by methods such as
  /// [PatrolFinder.tap] and [PatrolFinder.enterText].
  final Duration visibleTimeout;

  /// Time after which [PatrolTester.pumpAndSettle] fails.
  ///
  /// [PatrolFinder.waitUntilVisible] is used internally by methods such as
  /// [PatrolFinder.tap] and [PatrolFinder.enterText] (unless disabled by
  /// [settlePolicy]).
  final Duration settleTimeout;

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [PatrolFinder.tap] and [PatrolFinder]. If false, only [WidgetTester.pump]
  /// is called.
  @Deprecated('Use PatrolTester.settlePolicy instead')
  final bool andSettle;

  /// Defines which pump method should be called after actions such as
  /// [PatrolFinder.tap] and [PatrolFinder].
  ///
  /// See [SettlePolicy] for more information.
  final SettlePolicy settlePolicy;

  /// Creates a copy of this config but with the given fields replaced with the
  /// new values.
  PatrolTesterConfig copyWith({
    Duration? existsTimeout,
    Duration? visibleTimeout,
    Duration? settleTimeout,
    @Deprecated('Use settleBeahvior argument instead') bool? andSettle,
    SettlePolicy? settlePolicy,
    String? appName,
    String? packageName,
    String? bundleId,
  }) {
    return PatrolTesterConfig(
      existsTimeout: existsTimeout ?? this.existsTimeout,
      visibleTimeout: visibleTimeout ?? this.visibleTimeout,
      settleTimeout: settleTimeout ?? this.settleTimeout,
      andSettle: andSettle ?? this.andSettle,
      settlePolicy: settlePolicy ?? this.settlePolicy,
    );
  }
}

/// Default amount to drag by when scrolling.
const defaultScrollDelta = 64.0;

/// Default maximum number of drags during scrolling.
const defaultScrollMaxIteration = 100;

/// [PatrolTester] wraps a [WidgetTester]. It provides support for _Patrol
/// custom finder_, a.k.a `$`.
///
/// If you want to do something that [WidgetTester] supports, but [PatrolTester]
/// does not, you can access the underlying [WidgetTester] via [tester] field of
/// [PatrolTester].
///
/// Usually, you won't create a [PatrolTester] instance directly. Instead,
/// you'll use the [PatrolTester] which is provided by [PatrolTesterCallback] in
/// [patrolTest], like this:
///
/// ```dart
/// import 'package:patrol/patrol.dart';
///
/// void main() {
///   patrolTest('Counter increments smoke test', (patrolTester) async {
///     await patrolTester.pumpWidgetAndSettle(const MyApp());
///     await patrolTester(#startAppButton).tap();
///   });
/// }
/// ```
///
/// To make test code more concise, `patrolTester` variable is usually called
/// `$`, like this:
///
/// ```dart
/// import 'package:patrol/patrol.dart';
/// void main() {
///   patrolTest('Counter increments smoke test', ($) async {
///     await $.pumpWidgetAndSettle(const MyApp());
///     await $(#startAppButton).tap();
///   });
/// }
/// ```
///
///
/// You can call [PatrolTester] just like a normal method, because it is a
/// [callable class][callable-class].
///
/// [callable-class]:
/// <https://dart.dev/guides/language/language-tour#callable-classes>
class PatrolTester {
  /// Creates a new [PatrolTester] which wraps [tester].
  const PatrolTester({
    required this.tester,
    required this.nativeAutomator,
    required this.config,
  });

  /// Global configuration of this tester.
  final PatrolTesterConfig config;

  /// Flutter's widget tester that this [PatrolTester] wraps.
  final WidgetTester tester;

  /// Native automator that allows for interaction with OS the app is running
  /// on.
  final NativeAutomator? nativeAutomator;

  /// Shorthand for [nativeAutomator]. Throws if [nativeAutomator] is null,
  /// which is the case if it wasn't initialized.
  NativeAutomator get native {
    assert(
      nativeAutomator != null,
      'NativeAutomator is not initialized. Make sure you passed '
      "`nativeAutomation: true` to patrolTest(), and that you're *not* "
      'initializing any bindings in your test.',
    );
    return nativeAutomator!;
  }

  /// Returns a [PatrolFinder] that matches [matching].
  ///
  /// See also:
  ///  - [PatrolFinder.resolve]
  PatrolFinder call(dynamic matching) {
    return PatrolFinder.resolve(
      matching: matching,
      tester: this,
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

  /// See [WidgetTester.pump].
  Future<void> pump([
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) async {
    await tester.pump(duration, phase);
  }

  /// See [WidgetTester.pumpAndSettle].
  Future<void> pumpAndSettle({
    Duration duration = const Duration(milliseconds: 100),
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration? timeout,
  }) async {
    await tester.pumpAndSettle(
      duration,
      phase,
      timeout ?? config.settleTimeout,
    );
  }

  /// Calls [WidgetTester.pumpAndSettle] but it doesn't throw if it times out.
  /// It prevents the tests from failing when you expect e.g. an
  /// infinite animation to appear.
  ///
  /// See also [WidgetTester.pumpAndSettle].
  Future<void> pumpAndTrySettle({
    Duration duration = const Duration(milliseconds: 100),
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      await tester.pumpAndSettle(duration, phase, timeout);
      // ignore: avoid_catching_errors
    } on FlutterError catch (err) {
      if (err.message == 'pumpAndSettle timed out') {
        // This is fine. This method ignores pumpAndSettle timeouts on purpose
      } else {
        rethrow;
      }
    }
  }

  /// Pumps [widget] and then calls [WidgetTester.pumpAndSettle].
  ///
  /// This is a convenience method combining [WidgetTester.pumpWidget] and
  /// [WidgetTester.pumpAndSettle].
  Future<void> pumpWidgetAndSettle(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration? timeout,
  }) async {
    await tester.pumpWidget(widget, duration, phase);
    await _performPump(
      settlePolicy: SettlePolicy.settle,
      settleTimeout: timeout,
    );
  }

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
  Future<void> tap(
    Finder finder, {
    @Deprecated('Use settleBeahvior argument instead') bool? andSettle,
    SettlePolicy? settlePolicy,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) {
    return TestAsyncUtils.guard(() async {
      final resolvedFinder = await waitUntilVisible(
        finder,
        timeout: visibleTimeout,
      );
      await tester.tap(resolvedFinder.first);
      final settle = _choosesettlePolicy(andSettle, settlePolicy);
      await _performPump(
        settlePolicy: settle,
        settleTimeout: settleTimeout,
      );
    });
  }

  /// Waits until [finder] finds at least 1 visible widget and then enters text
  /// into it.
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
    Finder finder,
    String text, {
    @Deprecated('Use settleBeahvior argument instead') bool? andSettle,
    SettlePolicy? settlePolicy,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) {
    if (Platform.isIOS && kReleaseMode) {
      // Fix for enterText() not working in release mode on real iOS devices.
      // See https://github.com/flutter/flutter/pull/89703
      tester.testTextInput.register();
    }

    return TestAsyncUtils.guard(() async {
      final resolvedFinder = await waitUntilVisible(
        finder,
        timeout: visibleTimeout,
      );
      await tester.enterText(resolvedFinder.first, text);
      final settle = _choosesettlePolicy(andSettle, settlePolicy);
      await _performPump(
        settlePolicy: settle,
        settleTimeout: settleTimeout,
      );
    });
  }

  /// Waits until this finder finds at least one widget.
  ///
  /// Throws a [WaitUntilVisibleTimeoutException] if no widgets  found.
  ///
  /// Timeout is globally set by [PatrolTester.config.visibleTimeout]. If you
  /// want to override this global setting, set [timeout].
  Future<PatrolFinder> waitUntilExists(
    PatrolFinder finder, {
    Duration? timeout,
  }) {
    return TestAsyncUtils.guard(() async {
      final duration = timeout ?? config.existsTimeout;
      final end = tester.binding.clock.now().add(duration);

      while (finder.evaluate().isEmpty) {
        final now = tester.binding.clock.now();
        if (now.isAfter(end)) {
          throw WaitUntilExistsTimeoutException(
            finder: finder,
            duration: duration,
          );
        }

        await tester.pump(const Duration(milliseconds: 100));
      }

      return finder;
    });
  }

  /// Waits until [finder] finds at least one visible widget.
  ///
  /// Throws a [WaitUntilVisibleTimeoutException] if more time than specified by
  /// the timeout passed and no widgets were found.
  ///
  /// Timeout is globally set by [PatrolTester.config.visibleTimeout]. If you
  /// want to override this global setting, set [timeout].
  Future<PatrolFinder> waitUntilVisible(
    Finder finder, {
    Duration? timeout,
  }) {
    return TestAsyncUtils.guard(() async {
      final duration = timeout ?? config.visibleTimeout;
      final end = tester.binding.clock.now().add(duration);
      final hitTestableFinder = finder.hitTestable();
      while (hitTestableFinder.evaluate().isEmpty) {
        final now = tester.binding.clock.now();
        if (now.isAfter(end)) {
          throw WaitUntilVisibleTimeoutException(
            finder: finder,
            duration: duration,
          );
        }

        await tester.pump(const Duration(milliseconds: 100));
      }

      return PatrolFinder(finder: hitTestableFinder, tester: this);
    });
  }

  /// Repeatedly drags [view] by [moveStep] until [finder] finds at least one
  /// existing widget.
  ///
  /// Between each drag, advances the clock by [duration].
  ///
  /// This method automatically calls [WidgetTester.pumpAndSettle] or
  /// [WidgetTester.pump] after the drag is complete. If you want to override
  /// this behavior to not call [WidgetTester.pumpAndSettle], set [andSettle] to
  /// false.
  ///
  /// This is a reimplementation of [WidgetController.dragUntilVisible] that
  /// differs from the original in the following ways:
  ///
  ///  * has a better name
  ///
  ///  * waits until [view] is visible
  ///
  ///  * uses [WidgetController.firstElement] instead of
  ///    [WidgetController.element], which avoids [StateError] being thrown in
  ///    situations when [finder] finds more than 1 visible widget
  ///
  /// See also:
  ///  * [PatrolTester.config.andSettle], which controls the default behavior if
  ///    [andSettle] is null
  Future<PatrolFinder> dragUntilExists({
    required Finder finder,
    required Finder view,
    required Offset moveStep,
    int maxIteration = defaultScrollMaxIteration,
    Duration duration = const Duration(milliseconds: 50),
    @Deprecated('Use settleBeahvior argument instead') bool? andSettle,
    SettlePolicy? settlePolicy,
  }) {
    return TestAsyncUtils.guard(() async {
      final viewPatrolFinder = PatrolFinder(finder: view, tester: this);
      await viewPatrolFinder.waitUntilVisible();

      var iterationsLeft = maxIteration;
      while (iterationsLeft > 0 && finder.evaluate().isEmpty) {
        await tester.drag(view, moveStep);
        await tester.pump(duration);
        iterationsLeft -= 1;
      }
      await Scrollable.ensureVisible(tester.firstElement(finder));

      final settle = _choosesettlePolicy(andSettle, settlePolicy);
      await _performPump(
        settlePolicy: settle,
        settleTimeout: config.settleTimeout,
      );

      return PatrolFinder(finder: finder, tester: this);
    });
  }

  /// Repeatedly drags [view] by [moveStep] until [finder] finds at least one
  /// visible widget.
  ///
  /// Between each drag, advances the clock by [duration].
  ///
  /// This is a reimplementation of [WidgetController.dragUntilVisible] that
  /// differs from the original in the following ways:
  ///
  ///  * actually scrolls until [finder] finds at least one *visible* widget,
  ///    not an *existing* widget.
  ///
  ///  * waits until [view] is visible
  ///
  ///  * if the [view] finder finds more than 1 widget, it scrolls the first one
  ///    instead of throwing a [StateError]
  ///
  ///  * uses [WidgetController.firstElement] instead of
  ///    [WidgetController.element], which avoids [StateError] being thrown in
  ///    situations when [finder] finds more than 1 visible widget
  Future<PatrolFinder> dragUntilVisible({
    required Finder finder,
    required Finder view,
    required Offset moveStep,
    int maxIteration = defaultScrollMaxIteration,
    Duration duration = const Duration(milliseconds: 50),
    @Deprecated('Use settleBeahvior argument instead') bool? andSettle,
    SettlePolicy? settlePolicy,
  }) {
    return TestAsyncUtils.guard(() async {
      var viewPatrolFinder = PatrolFinder(finder: view, tester: this);
      await viewPatrolFinder.waitUntilVisible();
      viewPatrolFinder = viewPatrolFinder.first;

      var iterationsLeft = maxIteration;
      while (iterationsLeft > 0 && finder.hitTestable().evaluate().isEmpty) {
        await tester.drag(viewPatrolFinder, moveStep);
        await tester.pump(duration);
        iterationsLeft -= 1;
      }
      await Scrollable.ensureVisible(tester.firstElement(finder));

      final settle = _choosesettlePolicy(andSettle, settlePolicy);
      await _performPump(
        settlePolicy: settle,
        settleTimeout: config.settleTimeout,
      );

      return PatrolFinder(finder: finder.hitTestable().first, tester: this);
    });
  }

  /// Scrolls [scrollable] in its scrolling direction until this finders finds
  /// at least one existing widget.
  ///
  /// If [scrollable] is null, it defaults to the first found [Scrollable].
  ///
  /// See also:
  ///  - [PatrolTester.scrollUntilVisible], which this method wraps and gives it
  ///    a better name
  Future<PatrolFinder> scrollUntilExists({
    required Finder finder,
    Finder? scrollable,
    double delta = defaultScrollDelta,
    int maxScrolls = defaultScrollMaxIteration,
    Duration duration = const Duration(milliseconds: 50),
    @Deprecated('Use settleBeahvior argument instead') bool? andSettle,
    SettlePolicy? settlePolicy,
  }) async {
    assert(maxScrolls > 0, 'maxScrolls must be positive number');
    scrollable ??= find.byType(Scrollable);

    final scrollablePatrolFinder = await PatrolFinder(
      finder: scrollable,
      tester: this,
    ).waitUntilVisible();

    return TestAsyncUtils.guard<PatrolFinder>(() async {
      Offset moveStep;
      switch (tester.firstWidget<Scrollable>(scrollable!).axisDirection) {
        case AxisDirection.up:
          moveStep = Offset(0, delta);
          break;
        case AxisDirection.down:
          moveStep = Offset(0, -delta);
          break;
        case AxisDirection.left:
          moveStep = Offset(delta, 0);
          break;
        case AxisDirection.right:
          moveStep = Offset(-delta, 0);
          break;
      }

      final settle = _choosesettlePolicy(andSettle, settlePolicy);
      final resolvedFinder = await dragUntilExists(
        finder: finder,
        view: scrollablePatrolFinder.first,
        moveStep: moveStep,
        maxIteration: maxScrolls,
        duration: duration,
        settlePolicy: settle,
      );

      return resolvedFinder;
    });
  }

  /// Scrolls [scrollable] in its scrolling direction until this finders finds
  /// at least one existing widget.
  ///
  /// If [scrollable] is null, it defaults to the first found [Scrollable].
  ///
  /// This is a reimplementation of [WidgetController.scrollUntilVisible] that
  /// actually scrolls until [finder] finds at least one *visible* widget, not
  /// *existing* widget.
  Future<PatrolFinder> scrollUntilVisible({
    required Finder finder,
    Finder? scrollable,
    double delta = defaultScrollDelta,
    int maxScrolls = defaultScrollMaxIteration,
    Duration duration = const Duration(milliseconds: 50),
    @Deprecated('Use settleBeahvior argument instead') bool? andSettle,
    SettlePolicy? settlePolicy,
  }) async {
    assert(maxScrolls > 0, 'maxScrolls must be positive number');
    scrollable ??= find.byType(Scrollable);

    final scrollablePatrolFinder = await PatrolFinder(
      finder: scrollable,
      tester: this,
    ).waitUntilVisible();

    return TestAsyncUtils.guard<PatrolFinder>(() async {
      Offset moveStep;
      switch (tester.firstWidget<Scrollable>(scrollable!).axisDirection) {
        case AxisDirection.up:
          moveStep = Offset(0, delta);
          break;
        case AxisDirection.down:
          moveStep = Offset(0, -delta);
          break;
        case AxisDirection.left:
          moveStep = Offset(delta, 0);
          break;
        case AxisDirection.right:
          moveStep = Offset(-delta, 0);
          break;
      }

      final settle = _choosesettlePolicy(andSettle, settlePolicy);
      final resolvedFinder = await dragUntilVisible(
        finder: finder,
        view: scrollablePatrolFinder.first,
        moveStep: moveStep,
        maxIteration: maxScrolls,
        duration: duration,
        settlePolicy: settle,
      );

      return resolvedFinder;
    });
  }

  Future<void> _performPump({
    required SettlePolicy? settlePolicy,
    required Duration? settleTimeout,
  }) async {
    final settle = settlePolicy ?? config.settlePolicy;
    final timeout = settleTimeout ?? config.settleTimeout;
    if (settle == SettlePolicy.trySettle) {
      await pumpAndTrySettle(
        timeout: timeout,
      );
    } else if (settle == SettlePolicy.settle) {
      await pumpAndSettle(
        timeout: timeout,
      );
    } else {
      await tester.pump();
    }
  }

  SettlePolicy? _choosesettlePolicy(
    bool? andSettle,
    SettlePolicy? settlePolicy,
  ) {
    SettlePolicy? settle;
    if (andSettle == null) {
      settle = settlePolicy;
    } else {
      if (andSettle) {
        settle = SettlePolicy.settle;
      } else {
        settle = SettlePolicy.none;
      }
    }
    return settle;
  }
}

/// Specifies how methods such as [PatrolTester.tap] or [PatrolTester.enterText] handle pumping, i.e rendering new frames.
///
/// It's usually useful when dealing with situations involving finite and infinite animations.
enum SettlePolicy {
  /// When pumping should be performed, [PatrolTester.pump] will be called.
  none,

  /// When pumping should be performed, [PatrolTester.pumpAndSettle] will be called.
  settle,

  /// When pumping should be performed, [PatrolTester.pumpAndTrySettle] will be called.
  trySettle,
}
