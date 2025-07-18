import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:patrol_log/patrol_log.dart';

/// Common configuration for [PatrolTester] and [PatrolFinder].
class PatrolTesterConfig {
  /// Creates a new [PatrolTesterConfig].
  const PatrolTesterConfig({
    this.existsTimeout = const Duration(seconds: 10),
    this.visibleTimeout = const Duration(seconds: 10),
    this.settleTimeout = const Duration(seconds: 10),
    this.settlePolicy = SettlePolicy.trySettle,
    this.dragDuration = const Duration(milliseconds: 100),
    this.settleBetweenScrollsTimeout = const Duration(seconds: 5),
    this.printLogs = false,
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

  /// Defines which pump method should be called after actions such as
  /// [PatrolTester.tap], [PatrolTester.enterText], and [PatrolFinder.scrollTo].
  ///
  /// See [SettlePolicy] for more information.
  final SettlePolicy settlePolicy;

  /// Time that it takes to perform drag gesture in scrolling methods,
  /// such as [PatrolTester.scrollUntilVisible].
  final Duration dragDuration;

  /// Timeout used to settle in between drag gestures in scrolling methods,
  /// such as [PatrolTester.scrollUntilVisible] (unless disabled by
  /// [settlePolicy]).
  final Duration settleBetweenScrollsTimeout;

  /// If true, patrol finders logs will be printed to the console.
  final bool printLogs;

  /// Creates a copy of this config but with the given fields replaced with the
  /// new values.
  PatrolTesterConfig copyWith({
    Duration? existsTimeout,
    Duration? visibleTimeout,
    Duration? settleTimeout,
    SettlePolicy? settlePolicy,
    Duration? dragDuration,
    Duration? settleBetweenScrollsTimeout,
    bool? printLogs,
  }) {
    return PatrolTesterConfig(
      existsTimeout: existsTimeout ?? this.existsTimeout,
      visibleTimeout: visibleTimeout ?? this.visibleTimeout,
      settleTimeout: settleTimeout ?? this.settleTimeout,
      settlePolicy: settlePolicy ?? this.settlePolicy,
      dragDuration: dragDuration ?? this.dragDuration,
      settleBetweenScrollsTimeout:
          settleBetweenScrollsTimeout ?? this.settleBetweenScrollsTimeout,
      printLogs: printLogs ?? this.printLogs,
    );
  }
}

/// Default amount to drag by when scrolling.
const defaultScrollDelta = 64.0;

/// Default maximum number of drags during scrolling.
const defaultScrollMaxIteration = 15;

/// [PatrolTester] wraps a [WidgetTester]. It provides support for _Patrol
/// custom finder_, a.k.a `$`.
///
/// If you want to do something that [WidgetTester] supports, but [PatrolTester]
/// does not, you can access the underlying [WidgetTester] via [tester] field of
/// [PatrolTester].
///
/// ```dart
/// import 'package:patrol/patrol.dart';
///
/// void main() {
///   patrolWidgetTest('Counter increments smoke test', (patrolTester) async {
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
///   patrolWidgetTest('Counter increments smoke test', ($) async {
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
  PatrolTester({required this.tester, required this.config})
    : patrolLog = PatrolLogWriter();

  /// Global configuration of this tester.
  final PatrolTesterConfig config;

  /// Logs a message to the patrol log.
  final PatrolLogWriter patrolLog;

  /// Flutter's widget tester that this [PatrolTester] wraps.
  final WidgetTester tester;

  /// Wraps a function with a log entry for the start and end of the function.
  Future<T> wrapWithPatrolLog<T>({
    required String action,
    String? value,
    Finder? finder,
    required String color,
    required Future<T> Function() function,
    bool enablePatrolLog = true,
  }) async {
    if (!(config.printLogs && enablePatrolLog)) {
      return function();
    }

    final finderText =
        finder
            ?.toString(describeSelf: true)
            .replaceAll('A finder that searches for', '')
            .replaceAll(' (considering only hit-testable ones)', '')
            .replaceAll(' (ignoring all but first)', '') ??
        '';
    final valueText = value != null ? ' "$value"' : '';
    final text = '$color$action${AnsiCodes.reset}$valueText$finderText';
    patrolLog.log(StepEntry(action: text, status: StepEntryStatus.start));
    try {
      final result = await function();
      patrolLog.log(StepEntry(action: text, status: StepEntryStatus.success));
      return result;
    } catch (err) {
      patrolLog.log(StepEntry(action: text, status: StepEntryStatus.failure));
      rethrow;
    }
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
    await tester.pumpWidget(widget, duration: duration, phase: phase);
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

  /// Calls [WidgetTester.pumpAndSettle] but doesn't throw if it times out.
  /// It prevents the test from failing when there's e.g. an
  /// infinite animation.
  ///
  /// See also [WidgetTester.pumpAndSettle].
  Future<void> pumpAndTrySettle({
    Duration duration = const Duration(milliseconds: 100),
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration? timeout,
  }) async {
    try {
      await tester.pumpAndSettle(
        duration,
        phase,
        timeout ?? config.settleTimeout,
      );
      // We want to catch pumpAndSettle timeouts, so we can ignore them
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
    await tester.pumpWidget(widget, duration: duration, phase: phase);
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
  /// tapping. If you want to disable this behavior, set [settlePolicy] to
  /// [SettlePolicy.noSettle].
  ///
  /// See also:
  ///  - [PatrolFinder.waitUntilVisible], which is used to wait for the widget
  ///    to appear
  ///  - [WidgetController.tap]
  Future<void> tap(
    Finder finder, {
    SettlePolicy? settlePolicy,
    Duration? visibleTimeout,
    Duration? settleTimeout,
    Alignment alignment = Alignment.center,
    bool enablePatrolLog = true,
  }) {
    return TestAsyncUtils.guard(
      () => wrapWithPatrolLog(
        action: 'tap',
        finder: finder,
        color: AnsiCodes.yellow,
        enablePatrolLog: enablePatrolLog,
        function: () async {
          final resolvedFinder = await waitUntilVisible(
            finder,
            timeout: visibleTimeout,
            alignment: alignment,
            enablePatrolLog: false,
          );
          final rect = tester.getRect(resolvedFinder.first);
          await tester.tapAt(alignment.withinRect(rect));
          await _performPump(
            settlePolicy: settlePolicy,
            settleTimeout: settleTimeout,
          );
        },
      ),
    );
  }

  /// Waits until this finder finds at least 1 visible widget and then makes
  /// long press gesture on it.
  ///
  /// Example:
  /// ```dart
  /// // long presses on the first widget having Key('createAccount')
  /// await $(#createAccount).longPress();
  /// ```
  ///
  /// If the finder finds more than 1 widget, you can choose which one to make
  /// long press on:
  ///
  /// ```dart
  /// // long presses on the third TextButton widget
  /// await $(TextButton).at(2).longPress();
  /// ```
  ///
  /// After long press gesture this method automatically calls
  /// [WidgetTester.pumpAndSettle]. If you want to disable this behavior,
  /// set [settlePolicy] to [SettlePolicy.noSettle].
  ///
  /// See also:
  ///  - [PatrolFinder.waitUntilVisible], which is used to wait for the widget
  ///    to appear
  ///  - [WidgetController.longPress]
  Future<void> longPress(
    Finder finder, {
    SettlePolicy? settlePolicy,
    Duration? visibleTimeout,
    Duration? settleTimeout,
    Alignment alignment = Alignment.center,
    bool enablePatrolLog = true,
  }) {
    return TestAsyncUtils.guard(
      () => wrapWithPatrolLog(
        action: 'longPress',
        finder: finder,
        color: AnsiCodes.yellow,
        enablePatrolLog: enablePatrolLog,
        function: () async {
          final resolvedFinder = await waitUntilVisible(
            finder,
            timeout: visibleTimeout,
            alignment: alignment,
            enablePatrolLog: false,
          );
          final rect = tester.getRect(resolvedFinder.first);
          await tester.longPressAt(alignment.withinRect(rect));
          await _performPump(
            settlePolicy: settlePolicy,
            settleTimeout: settleTimeout,
          );
        },
      ),
    );
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
  /// entering text. If you want to disable this behavior, set [settlePolicy] to
  /// [SettlePolicy.noSettle].
  ///
  /// See also:
  ///  - [PatrolFinder.waitUntilVisible], which is used to wait for the widget
  ///    to appear
  ///  - [WidgetTester.enterText]
  Future<void> enterText(
    Finder finder,
    String text, {
    SettlePolicy? settlePolicy,
    Duration? visibleTimeout,
    Duration? settleTimeout,
    Alignment alignment = Alignment.center,
    bool enablePatrolLog = true,
  }) {
    if (!kIsWeb) {
      // Fix for enterText() not working in release mode on real iOS devices.
      // See https://github.com/flutter/flutter/pull/89703
      // Also the fix for enterText() is not able to interact with the same
      // textfield 2 times in the same test.
      // See https://github.com/flutter/flutter/issues/134604
      tester.testTextInput.register();
    }
    return TestAsyncUtils.guard(
      () => wrapWithPatrolLog(
        action: 'enterText',
        value: text,
        finder: finder,
        color: AnsiCodes.magenta,
        enablePatrolLog: enablePatrolLog,
        function: () async {
          final resolvedFinder = await waitUntilVisible(
            finder,
            timeout: visibleTimeout,
            alignment: alignment,
            enablePatrolLog: false,
          );

          // Workaround for enterText() not working in release mode on real iOS devices.
          // [EditableTextState._openInputConnection] is not called when the text field is focused.
          // So we need to attach text input connection manually.
          if (!kIsWeb && io.Platform.isIOS && kReleaseMode) {
            final editableTextState = tester.state<EditableTextState>(
              find.descendant(
                of: resolvedFinder.first,
                matching: find.byType(EditableText),
                matchRoot: true,
              ),
            );
            final effectiveAutofillClient =
                editableTextState.widget.autofillClient;

            TextInput.attach(
              editableTextState,
              effectiveAutofillClient?.textInputConfiguration ??
                  const TextInputConfiguration(),
            );
          }

          await tester.enterText(resolvedFinder.first, text);

          if (!kIsWeb) {
            // After interaction is done, we need to reset the testTextInput
            // to not interfere with consecutive interactions in the same test.
            tester.testTextInput.reset();
          }
          await _performPump(
            settlePolicy: settlePolicy,
            settleTimeout: settleTimeout,
          );
        },
      ),
    );
  }

  /// Waits until this finder finds at least one widget.
  ///
  /// Throws a [WaitUntilVisibleTimeoutException] if no widgets  found.
  ///
  /// Timeout is globally set by [PatrolTesterConfig.visibleTimeout] inside
  /// [PatrolTester.config]. If you want to override this global setting, set
  /// [timeout].
  Future<PatrolFinder> waitUntilExists(
    PatrolFinder finder, {
    Duration? timeout,
    bool enablePatrolLog = true,
  }) {
    return TestAsyncUtils.guard(
      () => wrapWithPatrolLog<PatrolFinder>(
        action: 'waitUntilExists',
        finder: finder,
        color: AnsiCodes.cyan,
        enablePatrolLog: enablePatrolLog,
        function: () async {
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
        },
      ),
    );
  }

  /// Waits until [finder] finds at least one visible widget.
  ///
  /// Throws a [WaitUntilVisibleTimeoutException] if more time than specified by
  /// the timeout passed and no widgets were found.
  ///
  /// Timeout is globally set by [PatrolTesterConfig.visibleTimeout] inside
  /// [PatrolTester.config]. If you want to override this global setting, set
  /// [timeout].
  ///
  /// {@template patrol_tester.alignment_on_visible_check}
  /// Provide [alignment] to fine tune the visibility check by calling
  /// [Finder.hitTestable] at this [alignment] of the [Widget].
  /// This might be helpful in case the tested [Widget] is or contains a [Row]
  /// or a [Column]. The default [Alignment.center] might always be the best
  ///  choice as the following example demonstrates:
  ///
  /// ```dart
  ///
  /// /// This [Widget] will only be found when calling
  /// ///await $(Foo).waitUntilVisible(alignment: Alignment.topCenter)
  /// class Foo extends StatelessWidget {
  /// Foo({Key? key}) : super(key: key);
  ///  @override
  ///  Widget build(BuildContext context) {
  ///    return const Column(
  ///        children: [
  ///          Text(
  ///            'Foo',
  ///          ),
  ///          SizedBox(height: 48),
  ///          Text('Bar'),
  ///        ],
  ///      )
  ///  }
  /// }
  /// ```
  /// As there is an empty [SizedBox] in the center of the [Column],
  /// calling ``await $(Foo).waitUntilVisible()`` will fail
  /// as the underlying [Finder.hitTestable] will not find any
  /// hit-testable widget. Changing the ``alignment`` parameter
  /// to ``Alignment.topCenter`` and calling
  /// ``await $(Foo).waitUntilVisible(alignment: Alignment.topCenter)``
  /// will make the test pass as the underlying [Finder.hitTestable]
  /// will find the [Text] widget at the top of the [Column].
  /// {@endtemplate}
  Future<PatrolFinder> waitUntilVisible(
    Finder finder, {
    Duration? timeout,
    Alignment alignment = Alignment.center,
    bool enablePatrolLog = true,
  }) {
    return TestAsyncUtils.guard(
      () => wrapWithPatrolLog(
        action: 'waitUntilVisible',
        finder: finder,
        color: AnsiCodes.cyan,
        enablePatrolLog: enablePatrolLog,
        function: () async {
          final duration = timeout ?? config.visibleTimeout;
          final end = tester.binding.clock.now().add(duration);
          final hitTestableFinder = finder.hitTestable(at: alignment);
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
        },
      ),
    );
  }

  /// Repeatedly drags [view] by [moveStep] until [finder] finds at least one
  /// existing widget.
  ///
  /// Between each drag, calls [pump], [pumpAndSettle] or [pumpAndTrySettle],
  /// depending on chosen [settlePolicy].
  ///
  /// This is a reimplementation of [WidgetController.dragUntilVisible] that
  /// differs from the original in the following ways:
  ///
  ///  * scrolls until until [finder] finds at least one *existing* widget
  ///
  ///  * waits until [view] is visible
  ///
  ///  * if the [view] finder finds more than 1 widget, it scrolls the first one
  ///    instead of throwing a [StateError]
  ///
  ///  * if the [finder] finder finds more than 1 widget, it scrolls to the
  ///    first one instead of throwing a [StateError]
  ///
  ///  * can drag any widget, not only a [Scrollable]
  ///
  ///  * performed drag is slower (it takes some time to performe dragging
  ///    gesture, half a second by default)
  ///
  ///  * you can configure, which version of pumping is performed between
  ///    each drag gesture ([pump], [pumpAndSettle] or [pumpAndTrySettle]),
  ///
  ///  * timeouts and durations, if null, are controlled by values in
  ///    [PatrolTester.config].
  ///
  /// See also:
  ///  * [PatrolTesterConfig.settlePolicy], which controls the default settle
  ///     behavior
  ///  * [PatrolTester.dragUntilVisible], which scrolls to visible widget,
  ///    not only existing one.
  Future<PatrolFinder> dragUntilExists({
    required Finder finder,
    required Finder view,
    required Offset moveStep,
    int maxIteration = defaultScrollMaxIteration,
    Duration? settleBetweenScrollsTimeout,
    Duration? dragDuration,
    SettlePolicy? settlePolicy,
    bool enablePatrolLog = true,
  }) {
    return TestAsyncUtils.guard(
      () => wrapWithPatrolLog<PatrolFinder>(
        action: 'dragUntilExists',
        finder: view,
        color: AnsiCodes.blue,
        enablePatrolLog: enablePatrolLog,
        function: () async {
          var viewPatrolFinder = PatrolFinder(finder: view, tester: this);
          await viewPatrolFinder.waitUntilVisible(enablePatrolLog: false);
          viewPatrolFinder = viewPatrolFinder.hitTestable().first;
          dragDuration ??= config.dragDuration;
          settleBetweenScrollsTimeout ??= config.settleBetweenScrollsTimeout;

          var iterationsLeft = maxIteration;
          while (iterationsLeft > 0 && finder.evaluate().isEmpty) {
            await tester.timedDrag(viewPatrolFinder, moveStep, dragDuration!);
            await _performPump(
              settlePolicy: settlePolicy,
              settleTimeout: settleBetweenScrollsTimeout,
            );
            iterationsLeft -= 1;
          }

          if (iterationsLeft <= 0) {
            throw WaitUntilExistsTimeoutException(
              finder: finder,
              // TODO: set reasonable duration or create new exception for this case
              duration: settleBetweenScrollsTimeout!,
            );
          }

          return PatrolFinder(finder: finder, tester: this);
        },
      ),
    );
  }

  /// Repeatedly drags [view] by [moveStep] until [finder] finds at least one
  /// visible widget.
  ///
  /// Between each drag, calls [pump], [pumpAndSettle] or [pumpAndTrySettle],
  /// depending on chosen [settlePolicy].
  ///
  /// This is a reimplementation of [WidgetController.dragUntilVisible] that
  /// differs from the original in the following ways:
  ///
  ///  * waits until [view] is visible
  ///
  ///  * if the [view] finder finds more than 1 widget, it scrolls the first one
  ///    instead of throwing a [StateError]
  ///
  ///  * if the [finder] finder finds more than 1 widget, it scrolls to the
  ///    first one instead of throwing a [StateError]
  ///
  ///  * can drag any widget, not only a [Scrollable]
  ///
  ///  * performed drag is slower (it takes some time to perform dragging
  ///    gesture, half a second by default)
  ///
  ///  * you can configure, which version of pumping is performed between
  ///    each drag gesture ([pump], [pumpAndSettle] or [pumpAndTrySettle])
  ///
  ///  * timeouts and durations, if null, are controlled by values in
  ///    [PatrolTester.config].
  ///
  /// See also:
  ///  * [PatrolTester.dragUntilExists], which scrolls to existing widget,
  ///    not a visible one.
  Future<PatrolFinder> dragUntilVisible({
    required Finder finder,
    required Finder view,
    required Offset moveStep,
    int maxIteration = defaultScrollMaxIteration,
    Duration? settleBetweenScrollsTimeout,
    Duration? dragDuration,
    SettlePolicy? settlePolicy,
    Alignment alignment = Alignment.center,
    bool enablePatrolLog = true,
  }) {
    return TestAsyncUtils.guard(
      () => wrapWithPatrolLog<PatrolFinder>(
        action: 'dragUntilVisible',
        finder: view,
        color: AnsiCodes.blue,
        enablePatrolLog: enablePatrolLog,
        function: () async {
          final viewPatrolFinder = (await waitUntilVisible(
            PatrolFinder(finder: view, tester: this),
            enablePatrolLog: false,
          )).first;

          dragDuration ??= config.dragDuration;
          settleBetweenScrollsTimeout ??= config.settleBetweenScrollsTimeout;

          final hitTestableFinder = finder.hitTestable(at: alignment);
          var iterationsLeft = maxIteration;
          while (iterationsLeft > 0 && hitTestableFinder.evaluate().isEmpty) {
            await tester.timedDrag(viewPatrolFinder, moveStep, dragDuration!);
            await _performPump(
              settlePolicy: settlePolicy,
              settleTimeout: settleBetweenScrollsTimeout,
            );
            iterationsLeft -= 1;
          }

          if (iterationsLeft <= 0) {
            throw WaitUntilVisibleTimeoutException(
              finder: hitTestableFinder,
              // TODO: set reasonable duration or create new exception for this case
              duration: settleBetweenScrollsTimeout!,
            );
          }

          return PatrolFinder(finder: hitTestableFinder.first, tester: this);
        },
      ),
    );
  }

  /// Scrolls [view] in its scrolling direction until this finders finds
  /// at least one existing widget.
  ///
  /// If [view] is null, it defaults to the first found [Scrollable].
  ///
  /// See also:
  ///  - [PatrolTester.scrollUntilVisible].
  Future<PatrolFinder> scrollUntilExists({
    required Finder finder,
    Finder? view,
    double delta = defaultScrollDelta,
    AxisDirection? scrollDirection,
    int maxScrolls = defaultScrollMaxIteration,
    Duration? settleBetweenScrollsTimeout,
    Duration? dragDuration,
    SettlePolicy? settlePolicy,
    bool enablePatrolLog = true,
  }) {
    assert(maxScrolls > 0, 'maxScrolls must be positive number');
    return wrapWithPatrolLog<PatrolFinder>(
      action: 'scrollUntilExists',
      finder: view,
      color: AnsiCodes.green,
      enablePatrolLog: enablePatrolLog,
      function: () async {
        final finderView = view ?? find.byType(Scrollable);

        final scrollablePatrolFinder = await PatrolFinder(
          finder: finderView,
          tester: this,
        ).waitUntilVisible(enablePatrolLog: false);

        AxisDirection direction;
        if (scrollDirection == null) {
          if (finderView.evaluate().first.widget is Scrollable) {
            direction = tester
                .firstWidget<Scrollable>(finderView)
                .axisDirection;
          } else {
            direction = AxisDirection.down;
          }
        } else {
          direction = scrollDirection;
        }

        return TestAsyncUtils.guard<PatrolFinder>(() async {
          final moveStep = switch (direction) {
            AxisDirection.up => Offset(0, delta),
            AxisDirection.down => Offset(0, -delta),
            AxisDirection.left => Offset(delta, 0),
            AxisDirection.right => Offset(-delta, 0),
          };

          final resolvedFinder = await dragUntilExists(
            finder: finder,
            view: scrollablePatrolFinder.first,
            moveStep: moveStep,
            maxIteration: maxScrolls,
            settleBetweenScrollsTimeout: settleBetweenScrollsTimeout,
            dragDuration: dragDuration,
            settlePolicy: settlePolicy,
            enablePatrolLog: false,
          );

          return resolvedFinder;
        });
      },
    );
  }

  /// Scrolls [view] in [scrollDirection] until this finders finds
  /// at least one existing widget.
  ///
  /// If [view] is null, it defaults to the first found [Scrollable].
  ///
  /// This is a reimplementation of [WidgetController.scrollUntilVisible] that
  /// doesn't throw when [finder] finds more than one widget.
  ///
  /// See also:
  ///  - [PatrolTester.scrollUntilExists].
  Future<PatrolFinder> scrollUntilVisible({
    required Finder finder,
    Finder? view,
    double delta = defaultScrollDelta,
    AxisDirection? scrollDirection,
    int maxScrolls = defaultScrollMaxIteration,
    Duration? settleBetweenScrollsTimeout,
    Duration? dragDuration,
    SettlePolicy? settlePolicy,
    Alignment alignment = Alignment.center,
    bool enablePatrolLog = true,
  }) {
    assert(maxScrolls > 0, 'maxScrolls must be positive number');
    return wrapWithPatrolLog(
      action: 'scrollUntilVisible',
      finder: view,
      color: AnsiCodes.green,
      enablePatrolLog: enablePatrolLog,
      function: () async {
        final finderView = view ?? find.byType(Scrollable);
        final scrollablePatrolFinder = await PatrolFinder(
          finder: finderView,
          tester: this,
        ).waitUntilVisible(enablePatrolLog: false);
        AxisDirection direction;
        if (scrollDirection == null) {
          if (finderView.evaluate().first.widget is Scrollable) {
            direction = tester
                .firstWidget<Scrollable>(finderView)
                .axisDirection;
          } else {
            direction = AxisDirection.down;
          }
        } else {
          direction = scrollDirection;
        }

        return TestAsyncUtils.guard<PatrolFinder>(() async {
          Offset moveStep;
          switch (direction) {
            case AxisDirection.up:
              moveStep = Offset(0, delta);
            case AxisDirection.down:
              moveStep = Offset(0, -delta);
            case AxisDirection.left:
              moveStep = Offset(delta, 0);
            case AxisDirection.right:
              moveStep = Offset(-delta, 0);
          }

          final resolvedFinder = await dragUntilVisible(
            finder: finder,
            view: scrollablePatrolFinder.first,
            moveStep: moveStep,
            maxIteration: maxScrolls,
            settleBetweenScrollsTimeout: settleBetweenScrollsTimeout,
            dragDuration: dragDuration,
            settlePolicy: settlePolicy,
            alignment: alignment,
            enablePatrolLog: false,
          );

          return resolvedFinder;
        });
      },
    );
  }

  Future<void> _performPump({
    required SettlePolicy? settlePolicy,
    required Duration? settleTimeout,
  }) async {
    final settle = settlePolicy ?? config.settlePolicy;
    final timeout = settleTimeout ?? config.settleTimeout;
    if (settle == SettlePolicy.trySettle) {
      await pumpAndTrySettle(timeout: timeout);
    } else if (settle == SettlePolicy.settle) {
      await pumpAndSettle(timeout: timeout);
    } else {
      await tester.pump();
    }
  }
}

/// Specifies how methods such as [PatrolTester.tap] or [PatrolTester.enterText] perform pumping, i.e. rendering new frames.
///
/// It's useful when dealing with situations involving finite and infinite animations.
enum SettlePolicy {
  /// [PatrolTester.pump] is used when pumping.
  ///
  /// This renders a single frame. If some animations are currently in progress, they will move forward by a single frame.
  noSettle,

  /// [PatrolTester.pumpAndSettle] is used when pumping.
  ///
  /// This keeps on rendering new frames until there are no frames pending or timeout is reached. Throws a [FlutterError] if timeout has been reached.
  settle,

  /// [PatrolTester.pumpAndTrySettle] is used when pumping.
  ///
  /// This keeps on rendering new frames until there are no frames pending or timeout is reached. Doesn't throw an exception if timeout has been reached.
  trySettle,
}
