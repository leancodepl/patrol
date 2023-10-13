import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/global_state.dart' as global_state;

const _success = 'success';

void _defaultPrintLogger(String message) {
  // ignore: avoid_print
  print('PatrolBinding: $message');
}

/// Binding that enables some of Patrol's custom functionality, such as tapping
/// on WebViews during a test.
///
/// ### Reporting results of bundled tests
///
/// This binding is also responsible for reporting the results of the tests to
/// the native side of Patrol. It does so by registering a tearDown() callback
/// that is executed after each test. Inside that callback, the name of the Dart
/// test file being currently executed is retrieved.
///
/// At this point, the [PatrolAppService] is handling the gRPC `runDartTest()`
/// called by the native side.
///
/// [PatrolBinding] submits the Dart test file name that is being currently
/// executed to [PatrolAppService]. Once the name is submitted to it, that
/// pending `runDartTest()` method returns.
class PatrolBinding extends IntegrationTestWidgetsFlutterBinding {
  /// Creates a new [PatrolBinding].
  ///
  /// You most likely don't want to call it yourself.
  PatrolBinding(this.patrolAppService) {
    logger('created');
    final oldTestExceptionReporter = reportTestException;
    reportTestException = (details, testDescription) {
      final currentDartTest = _currentDartTest;
      if (currentDartTest != null) {
        assert(!global_state.hotRestartEnabled);
        _testResults[currentDartTest] = Failure(testDescription, '$details');
      }
      oldTestExceptionReporter(details, testDescription);
    };

    setUp(() {
      if (global_state.hotRestartEnabled) {
        // Sending results ends the test, which we don't want for Hot Restart
        return;
      }

      if (global_state.currentTestIndividualName == 'patrol_test_explorer') {
        // Ignore the fake test.
        return;
      }

      _currentDartTest = global_state.currentTestFullName;
      logger('setUp(): called with current Dart test = "$_currentDartTest"');
    });

    tearDown(() async {
      if (global_state.hotRestartEnabled) {
        // Sending results ends the test, which we don't want for Hot Restart
        return;
      }

      if (await global_state.isInitialRun) {
        // If this is the initial run, then no test has been requested to
        // execute. Return to avoid blocking on testExecutionRequested below.
        return;
      }

      final testName = global_state.currentTestIndividualName;
      final isTestExplorer = testName == 'patrol_test_explorer';
      if (isTestExplorer) {
        // Ignore the fake test.
        return;
      }

      logger('tearDown(): called with current Dart test = "$_currentDartTest"');
      logger('tearDown(): there are ${_testResults.length} test results:');
      _testResults.forEach((dartTestName, result) {
        logger('tearDown(): test "$dartTestName": "$result"');
      });

      final requestedDartTest = await patrolAppService.testExecutionRequested;

      if (requestedDartTest == _currentDartTest) {
        logger(
          'tearDown(): finished test "$_currentDartTest". Will report its status back to the native side',
        );

        final passed = global_state.isCurrentTestPassing;
        logger('tearDown(): test "$_currentDartTest", passed: $passed');
        await patrolAppService.markDartTestAsCompleted(
          dartFileName: _currentDartTest!,
          passed: passed,
          details: _testResults[_currentDartTest!] is Failure
              ? (_testResults[_currentDartTest!] as Failure?)?.details
              : null,
        );
      } else {
        logger(
          'tearDown(): finished test "$_currentDartTest", but it was not requested, so its status will not be reported back to the native side',
        );
      }
    });
  }

  /// Returns an instance of the [PatrolBinding], creating and initializing it
  /// if necessary.
  ///
  /// This method is idempotent.
  factory PatrolBinding.ensureInitialized(PatrolAppService patrolAppService) {
    if (_instance == null) {
      PatrolBinding(patrolAppService);
    }
    return _instance!;
  }

  /// Logger used by this binding.
  void Function(String message) logger = _defaultPrintLogger;

  /// The [PatrolAppService] used by this binding to report tests to the native
  /// side.
  ///
  /// It's only for test reporting purposes and should not be used for anything
  /// else.
  final PatrolAppService patrolAppService;

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must be
  /// initialized before using this getter; this is typically done by calling
  /// [PatrolBinding.ensureInitialized].
  static PatrolBinding get instance => BindingBase.checkInstance(_instance);
  static PatrolBinding? _instance;

  String? _currentDartTest;

  /// Keys are the test descriptions, and values are either [_success] or
  /// a [Failure].
  final Map<String, Object> _testResults = <String, Object>{};

  // TODO: Remove once https://github.com/flutter/flutter/pull/108430 is available on the stable channel
  @override
  TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  @override
  Future<void> runTest(
    Future<void> Function() testBody,
    VoidCallback invariantTester, {
    String description = '',
    @Deprecated(
        'This parameter has no effect. Use the `timeout` parameter on `testWidgets` instead. '
        'This feature was deprecated after v2.6.0-1.0.pre.')
    Duration? timeout,
  }) async {
    await super.runTest(
      testBody,
      invariantTester,
      description: description,
    );
    _testResults[description] ??= _success;
  }

  @override
  void attachRootWidget(Widget rootWidget) {
    assert(
      (_currentDartTest != null) != (global_state.hotRestartEnabled),
      '_currentDartTest can be null if and only if Hot Restart is enabled',
    );

    const testLabelEnabled = bool.fromEnvironment('PATROL_TEST_LABEL_ENABLED');
    if (!testLabelEnabled || global_state.hotRestartEnabled) {
      super.attachRootWidget(RepaintBoundary(child: rootWidget));
    } else {
      super.attachRootWidget(
        Stack(
          textDirection: TextDirection.ltr,
          children: [
            RepaintBoundary(child: rootWidget),
            // Prevents crashes when Android activity is resumed (see https://github.com/leancodepl/patrol/issues/901)
            ExcludeSemantics(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQueryData.fromWindow(window).padding.top + 4,
                  left: 4,
                ),
                child: IgnorePointer(
                  child: Text(
                    _currentDartTest!,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
