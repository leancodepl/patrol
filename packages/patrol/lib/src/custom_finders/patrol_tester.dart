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
    this.andSettle = true,
    this.appName,
  });

  /// Time after which [PatrolFinder.waitUntilExists] fails if it doesn't finds
  /// a widget.
  final Duration existsTimeout;

  /// Time after which [PatrolFinder.waitUntilVisible] fails if it doesn't finds
  /// a widget.
  ///
  /// [PatrolFinder.waitUntilVisible] is used internally by [PatrolFinder.tap]
  /// and [PatrolFinder.enterText].
  ///
  final Duration visibleTimeout;

  /// Time after which [PatrolTester.pumpAndSettle] fails.
  final Duration settleTimeout;

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [PatrolFinder.tap] and [PatrolFinder]. If false, only [WidgetTester.pump]
  /// is called.
  final bool andSettle;

  /// Name of the application under test.
  ///
  /// Used in [PatrolTester.log].
  final String? appName;

  /// Creates a copy of this config but with the given fields replaced with the
  /// new values.
  PatrolTesterConfig copyWith({
    Duration? existsTimeout,
    Duration? visibleTimeout,
    Duration? settleTimeout,
    bool? andSettle,
    String? appName,
    String? packageName,
    String? bundleId,
  }) {
    return PatrolTesterConfig(
      existsTimeout: existsTimeout ?? this.existsTimeout,
      visibleTimeout: visibleTimeout ?? this.visibleTimeout,
      settleTimeout: settleTimeout ?? this.settleTimeout,
      andSettle: andSettle ?? this.andSettle,
      appName: appName ?? this.appName,
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
    required this.hostAutomator,
    required this.config,
  });

  /// Global configuration of this tester.
  final PatrolTesterConfig config;

  /// Flutter's widget tester that this [PatrolTester] wraps.
  final WidgetTester tester;

  /// Native automator that allows for interaction with OS the app is running
  /// on.
  final NativeAutomator? nativeAutomator;

  /// Provides functionality to run actions as the host system (your computer).
  final HostAutomator? hostAutomator;

  /// Shorthand for [nativeAutomator]. Throws if [nativeAutomator] is null,
  /// which is the case if it wasn't initialized.
  NativeAutomator get native {
    assert(nativeAutomator != null, 'native automator is null');
    return nativeAutomator!;
  }

  /// Shorthand for [hostAutomator]. Throws if [hostAutomator] is null, which is
  /// the case if it wasn't initialized.
  HostAutomator get host {
    assert(hostAutomator != null, 'host automator is null');
    return hostAutomator!;
  }

  /// Makes it simple to log. No need to use `print` or depend on
  /// `package:logging`.
  void log(Object? object, {String? name}) {
    final log = StringBuffer();

    final tag = name ?? config.appName;
    if (tag != null) {
      log.write('$tag: ');
    }

    log.write(object);

    // ignore: avoid_print
    print(log);
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
    await _performPump(andSettle: true, settleTimeout: timeout);
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
    bool? andSettle,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) {
    return TestAsyncUtils.guard(() async {
      final resolvedFinder = await waitUntilVisible(
        finder,
        timeout: visibleTimeout,
      );
      await tester.tap(resolvedFinder.first);
      await _performPump(
        andSettle: andSettle,
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
    bool? andSettle,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) {
    return TestAsyncUtils.guard(() async {
      final resolvedFinder = await waitUntilVisible(
        finder,
        timeout: visibleTimeout,
      );
      await tester.enterText(resolvedFinder.first, text);
      await _performPump(
        andSettle: andSettle,
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

      while (finder.hitTestable().evaluate().isEmpty) {
        final now = tester.binding.clock.now();
        if (now.isAfter(end)) {
          throw WaitUntilVisibleTimeoutException(
            finder: finder,
            duration: duration,
          );
        }

        await tester.pump(const Duration(milliseconds: 100));
      }

      return PatrolFinder(finder: finder, tester: this);
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
    bool? andSettle,
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

      await _performPump(
        andSettle: andSettle,
        settleTimeout: config.settleTimeout,
      );

      return PatrolFinder(finder: finder.first, tester: this);
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
  ///  * if the [view] finder finds more than 1 view, it scrolls the first one
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
    bool? andSettle,
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

      await _performPump(
        andSettle: andSettle,
        settleTimeout: config.settleTimeout,
      );

      return PatrolFinder(finder: finder.first, tester: this);
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
    bool? andSettle,
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

      final resolvedFinder = await dragUntilExists(
        finder: finder,
        view: scrollablePatrolFinder.first,
        moveStep: moveStep,
        maxIteration: maxScrolls,
        duration: duration,
        andSettle: andSettle,
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
    bool? andSettle,
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

      final resolvedFinder = await dragUntilVisible(
        finder: finder,
        view: scrollablePatrolFinder.first,
        moveStep: moveStep,
        maxIteration: maxScrolls,
        duration: duration,
        andSettle: andSettle,
      );

      return resolvedFinder;
    });
  }

  Future<void> _performPump({
    required bool? andSettle,
    required Duration? settleTimeout,
  }) async {
    final settle = andSettle ?? config.andSettle;
    if (settle) {
      final timeout = settleTimeout ?? config.settleTimeout;
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        timeout,
      );
    } else {
      await tester.pump();
    }
  }
}
