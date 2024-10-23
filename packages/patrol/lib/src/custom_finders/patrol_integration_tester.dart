import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/native/native_automator.dart';
import 'package:patrol/src/native/native_automator2.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;
import 'package:patrol_log/patrol_log.dart';

/// PatrolIntegrationTester extends the capabilities of [finders.PatrolTester]
/// with the ability to interact with native platform features via [native].
class PatrolIntegrationTester extends finders.PatrolTester {
  /// Creates a new [PatrolIntegrationTester] which wraps [tester].
  const PatrolIntegrationTester({
    required super.tester,
    required super.config,
    required this.nativeAutomator,
    required this.nativeAutomator2,
    required PatrolLogWriter patrolLog,
  }) : _patrolLog = patrolLog;

  /// The log for the patrol.
  final PatrolLogWriter _patrolLog;

  /// Native automator that allows for interaction with OS the app is running
  /// on.
  ///
  final NativeAutomator nativeAutomator;

  /// Native automator with new Selector api that allows for interaction
  /// with OS the app is running on.
  ///
  final NativeAutomator2 nativeAutomator2;

  /// Shorthand for [nativeAutomator].
  NativeAutomator get native => nativeAutomator;

  /// Shorthand for [nativeAutomator2].
  NativeAutomator2 get native2 => nativeAutomator2;

  /// Logs a message to the patrol log.
  void log(String message) {
    _patrolLog.log(LogEntry(message: message));
  }

  /// Wraps a function with a log entry for the start and end of the function.
  Future<T> wrapWithPatrolLog<T>({
    required String action,
    String? value,
    Finder? finder,
    required String color,
    required Function function,
  }) async {
    final finderText = finder
            ?.toString(describeSelf: true)
            .replaceAll('A finder that searches for', '') ??
        '';
    final valueText = value != null ? ' "$value"' : '';
    final text = '\u001b[$color$action\u001b[0m$valueText$finderText';
    _patrolLog.log(StepEntry(action: text, status: StepEntryStatus.start));
    try {
      // ignore: avoid_dynamic_calls
      final result = await function.call();
      _patrolLog.log(StepEntry(action: text, status: StepEntryStatus.success));
      return result as T;
    } catch (err) {
      _patrolLog.log(
        StepEntry(
          action: text,
          status: StepEntryStatus.failure,
          exception: err.toString(),
        ),
      );
      rethrow;
    }
  }

  @override
  Future<finders.PatrolFinder> dragUntilExists({
    required Finder finder,
    required Finder view,
    required Offset moveStep,
    int maxIteration = finders.defaultScrollMaxIteration,
    Duration? settleBetweenScrollsTimeout,
    Duration? dragDuration,
    finders.SettlePolicy? settlePolicy,
  }) {
    return wrapWithPatrolLog<finders.PatrolFinder>(
      action: 'dragUntilExists',
      finder: view,
      color: '34m',
      function: () =>
          super.dragUntilExists(finder: finder, view: view, moveStep: moveStep),
    );
  }

  @override
  Future<finders.PatrolFinder> dragUntilVisible({
    required Finder finder,
    required Finder view,
    required Offset moveStep,
    int maxIteration = finders.defaultScrollMaxIteration,
    Duration? settleBetweenScrollsTimeout,
    Duration? dragDuration,
    finders.SettlePolicy? settlePolicy,
  }) {
    return wrapWithPatrolLog<finders.PatrolFinder>(
      action: 'dragUntilVisible',
      finder: view,
      color: '34m',
      function: () => super
          .dragUntilVisible(finder: finder, view: view, moveStep: moveStep),
    );
  }

  @override
  Future<void> enterText(
    Finder finder,
    String text, {
    finders.SettlePolicy? settlePolicy,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) {
    return wrapWithPatrolLog(
      action: 'enterText',
      value: text,
      finder: finder,
      color: '35m',
      function: () => super.enterText(finder, text),
    );
  }

  @override
  Future<void> longPress(
    Finder finder, {
    finders.SettlePolicy? settlePolicy,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) {
    return wrapWithPatrolLog<void>(
      action: 'longPress',
      finder: finder,
      color: '33m',
      function: () => super.longPress(finder),
    );
  }

  @override
  Future<finders.PatrolFinder> scrollUntilExists({
    required Finder finder,
    Finder? view,
    double delta = finders.defaultScrollDelta,
    AxisDirection? scrollDirection,
    int maxScrolls = finders.defaultScrollMaxIteration,
    Duration? settleBetweenScrollsTimeout,
    Duration? dragDuration,
    finders.SettlePolicy? settlePolicy,
  }) {
    return wrapWithPatrolLog<finders.PatrolFinder>(
      action: 'scrollUntilExists',
      finder: view,
      color: '32m',
      function: () => super.scrollUntilExists(
        finder: finder,
        view: view,
        delta: delta,
        scrollDirection: scrollDirection,
        maxScrolls: maxScrolls,
        settleBetweenScrollsTimeout: settleBetweenScrollsTimeout,
        dragDuration: dragDuration,
        settlePolicy: settlePolicy,
      ),
    );
  }

  @override
  Future<finders.PatrolFinder> scrollUntilVisible({
    required Finder finder,
    Finder? view,
    double delta = finders.defaultScrollDelta,
    AxisDirection? scrollDirection,
    int maxScrolls = finders.defaultScrollMaxIteration,
    Duration? settleBetweenScrollsTimeout,
    Duration? dragDuration,
    finders.SettlePolicy? settlePolicy,
  }) {
    return wrapWithPatrolLog<finders.PatrolFinder>(
      action: 'scrollUntilVisible',
      finder: view,
      color: '32m',
      function: () => super.scrollUntilVisible(
        finder: finder,
        view: view,
        delta: delta,
        scrollDirection: scrollDirection,
        maxScrolls: maxScrolls,
        settleBetweenScrollsTimeout: settleBetweenScrollsTimeout,
        dragDuration: dragDuration,
        settlePolicy: settlePolicy,
      ),
    );
  }

  @override
  Future<void> tap(
    Finder finder, {
    finders.SettlePolicy? settlePolicy,
    Duration? visibleTimeout,
    Duration? settleTimeout,
  }) {
    return wrapWithPatrolLog<void>(
      action: 'tap',
      finder: finder,
      color: '33m',
      function: () => super.tap(finder),
    );
  }

  @override
  Future<finders.PatrolFinder> waitUntilExists(
    finders.PatrolFinder finder, {
    Duration? timeout,
  }) {
    return wrapWithPatrolLog<finders.PatrolFinder>(
      action: 'waitUntilExists',
      finder: finder,
      color: '36m',
      function: () => super.waitUntilExists(finder),
    );
  }

  @override
  Future<finders.PatrolFinder> waitUntilVisible(
    Finder finder, {
    Duration? timeout,
  }) {
    return wrapWithPatrolLog<finders.PatrolFinder>(
      action: 'waitUntilVisible',
      finder: finder,
      color: '36m',
      function: () => super.waitUntilVisible(finder),
    );
  }
}
