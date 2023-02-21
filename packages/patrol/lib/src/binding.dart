import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meta/meta.dart';
import 'package:test_api/src/backend/invoker.dart'; // ignore: implementation_imports

// ignore: avoid_print
void _defaultPrintLogger(String message) {
  if (const bool.fromEnvironment('PATROL_VERBOSE')) {
    // ignore: avoid_print
    print('PatrolBinding: $message');
  }
}

/// The method channel used to report the results of the tests to the underlying
/// platform's testing framework.
///
/// On Android, this is relevant when running instrumented tests with
/// UIAutomator.
///
/// On iOS, this is relevant when running UI tests with XCUITest.
const patrolChannel = MethodChannel('plugins.flutter.io/integration_test');

/// Binding that enables some of Patrol's custom functionality, such as tapping
/// on WebViews during a test.
class PatrolBinding extends IntegrationTestWidgetsFlutterBinding {
  /// Returns an instance of the [PatrolBinding], creating and initializing it
  /// if necessary.
  factory PatrolBinding.ensureInitialized() {
    if (_instance == null) {
      PatrolBinding();
    }
    return _instance!;
  }

  /// Default constructor that only calls the superclass constructor.
  PatrolBinding() {
    // Override FlutterError.onError to log all exceptions
    final oldReporter = FlutterError.onError;

    setUp(() {
      final name = Invoker.current?.liveTest.individualName;
      print('DEBUG Starting test: $name');
      _currentTestName = name;
    });

    tearDown(() {
      final name = Invoker.current?.liveTest.individualName;
      print('DEBUG Finishing test: $name');
      _currentTestName = null;
    });

    FlutterError.onError = (details) {
      final currentTestName = _currentTestName;
      debugPrint('Exception caught during test: $currentTestName');
      if (currentTestName == null) {
        debugPrint(
          'DEBUG FLutterError was thrown but current test name is null',
        );
        return;
      }
      testResults[currentTestName] = Failure(
        'HELLO1 ${Invoker.current?.liveTest.individualName}',
        'HELLO2 $details',
      );

      oldReporter!(details);
    };

    final oldTestExceptionReporter = reportTestException;
    reportTestException = (details, testDescription) {
      oldTestExceptionReporter(details, testDescription);

      final previousResult = testResults[testDescription];
      testResults[testDescription] = Failure(
        'Name: $testDescription',
        'Details: $details + $previousResult',
      );
    };

    tearDownAll(() async {
      try {
        // TODO: Migrate communication to gRPC
        _logger('Sending Dart test results to the native side');
        await patrolChannel.invokeMethod<void>(
          'allTestsFinished',
          <String, dynamic>{
            // ignore: invalid_use_of_visible_for_testing_member
            'results': testResults.map<String, dynamic>((name, result) {
              if (result is Failure) {
                return MapEntry<String, dynamic>(name, result.details);
              }

              return MapEntry<String, Object>(name, result);
            }),
          },
        );
      } on MissingPluginException {
        debugPrint('''
Warning: Patrol plugin was not detected.

Thrown by PatrolBinding.
''');
      }
    });
  }

  String? _currentTestName;

  final _logger = _defaultPrintLogger;

  // TODO: Remove once https://github.com/flutter/flutter/pull/108430 is available on the stable channel
  @override
  TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  @internal
  Map<String, Object> testResults = <String, Object>{};

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
            // Prevents crashes when Android activity is resumed
            // See https://github.com/leancodepl/patrol/issues/901
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
