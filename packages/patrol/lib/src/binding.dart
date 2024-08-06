import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/devtools_service_extensions/devtools_service_extensions.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:patrol/src/global_state.dart' as global_state;

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
class PatrolBinding extends LiveTestWidgetsFlutterBinding {
  /// Creates a new [PatrolBinding].
  ///
  /// You most likely don't want to call it yourself.
  PatrolBinding(NativeAutomatorConfig config)
      : _serviceExtensions = DevtoolsServiceExtensions(config) {
    final oldTestExceptionReporter = reportTestException;

    /// Wraps the default test exception reporter to report the test results to
    /// the native side of Patrol.
    reportTestException = (details, testDescription) {
      final currentDartTest = _currentDartTest;
      if (currentDartTest != null) {
        assert(!constants.hotRestartEnabled);
        // On iOS in release mode, diagnostics are compacted or truncated.
        // We use the exceptionAsString() and stack to get the information
        // about the exception. See [DiagnosticLevel].
        final detailsAsString = (kReleaseMode && io.Platform.isIOS)
            ? '${details.exceptionAsString()} \n ${details.stack}'
            : details.toString();
        _testResults[currentDartTest] = Failure(
          testDescription,
          detailsAsString,
        );
      }
      oldTestExceptionReporter(details, testDescription);
    };

    setUp(() {
      if (constants.hotRestartEnabled) {
        return;
      }

      if (global_state.currentTestIndividualName == 'patrol_test_explorer') {
        return;
      }

      _currentDartTest = global_state.currentTestFullName;
    });

    tearDown(() async {
      if (constants.hotRestartEnabled) {
        // Sending results ends the test, which we don't want for Hot Restart
        return;
      }

      final testName = global_state.currentTestIndividualName;
      if (testName == 'patrol_test_explorer') {
        return;
      } else {
        logger(
          'tearDown(): count: ${_testResults.length}, results: $_testResults',
        );
      }

      final nameOfRequestedTest = await patrolAppService.testExecutionRequested;

      if (nameOfRequestedTest == _currentDartTest) {
        if (const bool.fromEnvironment('COVERAGE_ENABLED')) {
          postEvent(
            'waitForCoverageCollection',
            {'mainIsolateId': Service.getIsolateId(Isolate.current)},
          );

          var stopped = true;

          registerExtension('ext.patrol.markTestCompleted',
              (method, parameters) async {
            stopped = false;
            return ServiceExtensionResponse.result(jsonEncode({}));
          });

          while (stopped) {
            // The loop is needed to keep this isolate alive until the coverage
            // data is collected.
            await Future<void>.delayed(const Duration(seconds: 1));
          }
        }

        logger(
          'finished test $_currentDartTest. Will report its status back to the native side',
        );

        final passed = global_state.isCurrentTestPassing;
        logger(
          'tearDown(): test "$testName" in group "$_currentDartTest", passed: $passed',
        );

        await patrolAppService.markDartTestAsCompleted(
          dartFileName: _currentDartTest!,
          passed: passed,
          details: _testResults[_currentDartTest!] is Failure
              ? (_testResults[_currentDartTest!] as Failure?)?.details
              : null,
        );
      } else {
        logger(
          'finished test $_currentDartTest, but it was not requested, so its status will not be reported back to the native side',
        );
      }
    });
  }

  /// Returns an instance of the [PatrolBinding], creating and initializing it
  /// if necessary.
  ///
  /// This method is idempotent.
  factory PatrolBinding.ensureInitialized(NativeAutomatorConfig config) {
    if (_instance == null) {
      PatrolBinding(config);
    }
    return _instance!;
  }

  @override
  bool get overrideHttpClient => false;

  @override
  bool get registerTestTextInput => false;

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

  String? _currentDartTest;

  /// Keys are the test descriptions, and values are either [_success] or a
  /// [Failure].
  final Map<String, Object> _testResults = <String, Object>{};

  final DevtoolsServiceExtensions _serviceExtensions;

  /// Temporary workaround for DevTools extension changing this value and not
  /// resetting it.
  ///
  /// See https://github.com/flutter/devtools/issues/6719
  TargetPlatform? workaroundDebugDefaultTargetPlatformOverride;

  /// Allows for gestures made with human finger to be percevied as gestures
  /// made with [WidgetTester], allowing to interact with a running test.
  ///
  /// We thought we may replace this override by setting
  /// [shouldPropagateDevicePointerEvents] to true but it doesn't work.
  ///
  /// See also:
  ///
  ///  * https://github.com/leancodepl/patrol/issues/1956
  @override
  TestBindingEventSource get pointerEventSource {
    return TestBindingEventSource.test;
  }

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();

    logger('Register Patrol service extensions');

    registerServiceExtension(
      name: 'patrol.getNativeUITree',
      callback: _serviceExtensions.getNativeUITree,
    );
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
  ViewConfiguration createViewConfigurationFor(RenderView renderView) {
    final view = renderView.flutterView;
    return TestViewConfiguration.fromView(
      size: view.physicalSize / view.devicePixelRatio,
      view: view,
    );
  }

  @override
  Widget wrapWithDefaultView(Widget rootWidget) {
    assert(
      (_currentDartTest != null) != (constants.hotRestartEnabled),
      '_currentDartTest can be null if and only if Hot Restart is enabled',
    );

    const testLabelEnabled = bool.fromEnvironment('PATROL_TEST_LABEL_ENABLED');
    if (!testLabelEnabled || constants.hotRestartEnabled) {
      return super.wrapWithDefaultView(RepaintBoundary(child: rootWidget));
    } else {
      return super.wrapWithDefaultView(
        Stack(
          textDirection: TextDirection.ltr,
          children: [
            RepaintBoundary(child: rootWidget),
            // Prevents crashes when Android activity is resumed (see
            // https://github.com/leancodepl/patrol/issues/901)
            ExcludeSemantics(
              child: Builder(
                builder: (context) {
                  final view = View.of(context);
                  return Padding(
                    padding: EdgeInsets.only(
                      top: MediaQueryData.fromView(view).padding.top + 4,
                      left: 4,
                    ),
                    child: IgnorePointer(
                      child: Text(
                        _currentDartTest!,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void reportExceptionNoticed(FlutterErrorDetails exception) {
    // This override is copied from IntegrationTestWidgetsFlutterBinding. It may
    // be not needed.
    //
    // See: https://github.com/flutter/flutter/issues/81534
  }
}

/// Representing a failure includes the method name and the failure details.
class Failure {
  /// Constructor requiring all fields during initialization.
  Failure(this.methodName, this.details);

  /// The name of the test method which failed.
  final String methodName;

  /// The details of the failure such as stack trace.
  final String? details;

  /// Serializes the object to JSON.
  String toJson() {
    return json.encode(<String, String?>{
      'methodName': methodName,
      'details': details,
    });
  }

  @override
  String toString() => toJson();

  /// Decode a JSON string to create a Failure object.
  // ignore: prefer_constructors_over_static_methods
  static Failure fromJsonString(String jsonString) {
    final failure = json.decode(jsonString) as Map<String, dynamic>;
    return Failure(
      failure['methodName'] as String,
      failure['details'] as String?,
    );
  }
}
