import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test.dart';

class _Response {
  factory _Response.fromJson(Map<String, dynamic> json) {
    return _Response._(
      int.parse(json['request_id'] as String),
      json['status'] == 'true',
      json['error'] as String?,
      json,
    );
  }

  const _Response._(this.id, this.ok, this.error, this.raw);

  final int id;
  final bool ok;
  final String? error;
  final Map<String, dynamic> raw;
}

// ignore: avoid_print
void _defaultPrintLogger(String message) {
  if (const bool.fromEnvironment('PATROL_VERBOSE')) {
    // ignore: avoid_print
    print('PatrolBinding: $message');
  }
}

// copied from package:integration_test/lib/integration_test.dart
const bool _shouldReportResultsToNative = bool.fromEnvironment(
  'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE',
  defaultValue: true,
);

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
    final oldTestExceptionReporter = reportTestException;
    reportTestException = (details, testDescription) {
      // ignore: invalid_use_of_visible_for_testing_member
      results[testDescription] = Failure(testDescription, details.toString());
      oldTestExceptionReporter(details, testDescription);
    };

    if (!_shouldReportResultsToNative) {
      debugPrint('Tests results will not be reported natively');
      return;
    } else {
      debugPrint('Tests results will be reported natively');
    }

    tearDownAll(() async {
      try {
        if (!Platform.isIOS) {
          return;
        }

        debugPrint('Sending Dart test results to the native side');
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

  int _latestEventId = 0;

  final _controller = StreamController<_Response>.broadcast();

  // TODO: Remove once https://github.com/flutter/flutter/pull/108430 is
  // available on the stable channel
  @override
  TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;

    if (!extensionStreamHasListener) {
      _logger("Extension stream has no listeners, so host features won't work");
    }
  }

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();

    if (!kReleaseMode) {
      registerServiceExtension(
        name: 'patrol',
        callback: (args) async {
          _controller.add(_Response.fromJson(args));
          return <String, String>{};
        },
      );
      _logger('registered service extension ext.flutter.patrol');
    }
  }

  /// Takes a screenshot using the `flutter screenshot` command.
  ///
  /// The screenshot is placed in [path], named [name], and has .png extension.
  Future<void> takeFlutterScreenshot({
    required String name,
    required String path,
  }) async {
    final eventId = ++_latestEventId;

    postEvent('patrol', <String, dynamic>{
      'method': 'take_screenshot',
      'request_id': eventId,
      'args': {'name': name, 'path': path}
    });

    final resp = await _controller.stream.firstWhere((r) => r.id == eventId);
    if (!resp.ok) {
      throw StateError('event with request_id $eventId failed: ${resp.error}');
    }
  }

  /// Runs a process using [io.Process.run].
  Future<io.ProcessResult> runProcess({
    required String executable,
    required List<String> arguments,
    required bool runInShell,
  }) async {
    final eventId = ++_latestEventId;

    postEvent('patrol', <String, dynamic>{
      'method': 'run_process',
      'request_id': eventId,
      'args': {
        'executable': executable,
        'arguments': arguments,
        'runInShell': runInShell,
      },
    });

    final resp = await _controller.stream.firstWhere((r) => r.id == eventId);
    if (!resp.ok) {
      throw StateError('event with request_id $eventId failed: ${resp.error}');
    }

    return io.ProcessResult(
      int.parse(resp.raw['pid'] as String),
      int.parse(resp.raw['exitCode'] as String),
      resp.raw['stdout'], // String
      resp.raw['stderr'], // String
    );
  }

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must be
  /// initialized before using this getter; this is typically done by calling
  /// [PatrolBinding.ensureInitialized].
  static PatrolBinding get instance => BindingBase.checkInstance(_instance);
  static PatrolBinding? _instance;
}
