import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test.dart';

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
const patrolChannel = MethodChannel('pl.leancode.patrol/main');

/// Binding that enables some of Patrol's custom functionality, such as tapping
/// on WebViews during a test.
class PatrolBinding extends IntegrationTestWidgetsFlutterBinding {
  /// Default constructor that only calls the superclass constructor.
  PatrolBinding() {
    tearDownAll(() async {
      try {
        if (!Platform.isIOS) {
          return;
        }

        // TODO: Migrate communication to gRPC
        _logger('Sending Dart test results to the native side');
        await patrolChannel.invokeMethod<void>(
          'allTestsFinished',
          <String, dynamic>{
            // ignore: invalid_use_of_visible_for_testing_member
            'results': results.map<String, dynamic>((name, result) {
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

  /// Returns an instance of the [PatrolBinding], creating and initializing it
  /// if necessary.
  factory PatrolBinding.ensureInitialized() {
    if (_instance == null) {
      PatrolBinding();
    }
    return _instance!;
  }

  final _logger = _defaultPrintLogger;

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
