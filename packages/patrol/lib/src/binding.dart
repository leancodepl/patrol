// We allow for using properties of IntegrationTestWidgetsFlutterBinding, which
// are marked as @visibleForTesting but we need them (we could write our own,
// but we're lazy and prefer to use theirs).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:test_api/src/backend/live_test.dart';

import 'constants.dart' as constants;

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
  PatrolBinding() {
    final oldTestExceptionReporter = reportTestException;
    reportTestException = (details, testDescription) {
      final currentDartTestFile = _currentDartTestFile;
      if (currentDartTestFile != null) {
        assert(!constants.hotRestartEnabled);
        _testResults[currentDartTestFile] =
            Failure(testDescription, '$details');
      }
      oldTestExceptionReporter(details, testDescription);
    };

    setUp(() {
      if (constants.hotRestartEnabled) {
        // Sending results ends the test, which we don't want for Hot Restart
        return;
      }

      _currentDartTestFile = Invoker.current!.liveTest.parentGroupName;
    });

    tearDown(() async {
      if (constants.hotRestartEnabled) {
        // Sending results ends the test, which we don't want for Hot Restart
        return;
      }

      final testName = Invoker.current!.liveTest.individualName;
      final isTestExplorer = testName == 'patrol_test_explorer';
      if (isTestExplorer) {
        return;
      } else {
        logger(
          'tearDown(): count: ${_testResults.length}, results: $_testResults',
        );
      }

      final invoker = Invoker.current!;

      final nameOfRequestedTest = await patrolAppService.testExecutionRequested;
      if (nameOfRequestedTest == _currentDartTestFile) {
        final passed = invoker.liveTest.state.result.isPassing;
        logger(
          'tearDown(): test "$testName" in group "$_currentDartTestFile", passed: $passed',
        );
        await patrolAppService.markDartTestAsCompleted(
          dartFileName: _currentDartTestFile!,
          passed: passed,
          details: _testResults[_currentDartTestFile!] is Failure
              ? (_testResults[_currentDartTestFile!] as Failure?)?.details
              : null,
        );
      }
    });
  }

  /// Returns an instance of the [PatrolBinding], creating and initializing it
  /// if necessary.
  ///
  /// This method is idempotent.
  factory PatrolBinding.ensureInitialized() {
    if (_instance == null) {
      PatrolBinding();
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
  late PatrolAppService patrolAppService;

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must be
  /// initialized before using this getter; this is typically done by calling
  /// [PatrolBinding.ensureInitialized].
  static PatrolBinding get instance => BindingBase.checkInstance(_instance);
  static PatrolBinding? _instance;

  String? _currentDartTestFile;

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
      (_currentDartTestFile != null) != (constants.hotRestartEnabled),
      '_currentDartTestFile can be null if and only if Hot Restart is enabled',
    );

    const testLabelEnabled = bool.fromEnvironment('PATROL_TEST_LABEL_ENABLED');
    if (!testLabelEnabled || constants.hotRestartEnabled) {
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
                child: Text(
                  _currentDartTestFile!,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

extension on LiveTest {
  /// Get the direct parent group of the currently running test.
  ///
  /// The group's name is the name of the Dart test file the test is defined in.
  String get parentGroupName => groups.last.name;
}
