// We allow for using properties of IntegrationTestWidgetsFlutterBinding, which
// are marked as @visibleForTesting but we need them (we could write our own,
// but we're lazy and prefer to use theirs).
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';
import 'package:test_api/src/backend/invoker.dart';

void _defaultPrintLogger(String message) {
  // ignore: avoid_print
  print('PatrolBinding: $message');
}

/// An escape hatch if, for any reason, the test reporting has to be
/// disabled.
///
/// Patrol CLI doesn't pass this dart define anywhere.
const bool _shouldReportResultsToNative = bool.fromEnvironment(
  'PATROL_INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE',
  defaultValue: true,
);

const bool _hotRestartEnabled = bool.fromEnvironment('PATROL_HOT_RESTART');

/// The method channel used to report the results of the tests to the underlying
/// platform's testing framework (JUnit on Android and XCTest on iOS).
const patrolChannel = MethodChannel('pl.leancode.patrol/main');

/// Binding that enables some of Patrol's custom functionality, such as tapping
/// on WebViews during a test.
class PatrolBinding extends IntegrationTestWidgetsFlutterBinding {
  /// Default constructor that only calls the superclass constructor.
  PatrolBinding() {
    final oldTestExceptionReporter = reportTestException;
    reportTestException = (details, testDescription) {
      results[testDescription] = Failure(testDescription, details.toString());
      oldTestExceptionReporter(details, testDescription);
    };

    tearDown(() async {
      if (!_shouldReportResultsToNative) {
        return;
      }

      if (_hotRestartEnabled) {
        // Sending results ends the test, which we don't want for Hot Restart
        return;
      }

      final individualTestName = Invoker.current!.liveTest.individualName;
      final isTestExplorer = individualTestName == 'patrol_test_explorer';
      if (isTestExplorer) {
        print('PatrolBinding.tearDown() called on test explorer, skipping');
        return;
      } else {
        print(
          'PatrolBinding.tearDown() called, count: ${results.length}, results: $results',
        );
      }

      print(
        'PatrolBinding: test name in teardown is: ${Invoker.current!.liveTest.individualName}',
      );
      print(
        'PatrolBinding: innermost group name teardown is: ${Invoker.current!.liveTest.groups.last}',
      );

      print('PatrolBinding: before stupid temporary wait');
      await Future.delayed(const Duration(seconds: 5));
      print('PatrolBinding: after stupid temporary wait');

      await patrolAppService.markDartTestAsCompleted('IDK!');

      // FIXME: Report the results back to the native side. Dilemma: long method for whole test or a callback?
      // logger('Sending ${results.length} test results to the native side...');
      // await nativeAutomator.submitTestResults(
      //   results.map((name, result) {
      //     if (result is Failure) {
      //       return MapEntry(name, result.details ?? 'No details');
      //     }

      //     if (result is String) {
      //       return MapEntry(name, result);
      //     }

      //     throw StateError('result ($result) is neither a Failure or a String');
      //   }),
      // );
      // logger('Test results sent');
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

  // TODO: Remove once https://github.com/flutter/flutter/pull/108430 is available on the stable channel
  @override
  TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must be
  /// initialized before using this getter; this is typically done by calling
  /// [PatrolBinding.ensureInitialized].
  static PatrolBinding get instance => BindingBase.checkInstance(_instance);
  static PatrolBinding? _instance;

  @override
  void attachRootWidget(Widget rootWidget) {
    const testLabel = String.fromEnvironment('PATROL_TEST_LABEL');
    if (testLabel.isEmpty) {
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
                child: const Text(
                  testLabel,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
