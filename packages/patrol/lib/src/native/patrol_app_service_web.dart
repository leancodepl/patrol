/// This file contains web-specific bindings and interop for Patrol's app service,
/// including Playwright native bridge integration and JS interop for Dart test execution.
///
/// Exposes Dart functions to the browser environment for test discovery and execution,
/// and provides a Dart API for calling Playwright-exposed native actions.

// Identifier name is for JS interop only; its value is not significant in Dart.
// ignore_for_file: non_constant_identifier_names

library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
// No unsafe APIs needed with export setters; keep to pure dart:js_interop

import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/contracts/patrol_app_service_server.dart';
import 'package:patrol_log/patrol_log.dart';

class _TestExecutionResult {
  const _TestExecutionResult({required this.passed, required this.details});

  final bool passed;
  final String? details;
}

@JS()
external set __patrol_listDartTests(JSFunction value);

@JS()
external set __patrol_runDartTestWithCallback(JSFunction value);

@JS()
external set __patrol_setInitialised(JSFunction value);

/// Completer that completes when Patrol is initialised on the JS side.
///
/// Used to keep track of whether the JS environment has called the Dart initialisation
/// callback (e.g., via `__patrol_setInitialised`). This allows Dart code to await
/// initialisation before proceeding with actions that require the JS side to be ready.
final isInitialised = Completer<void>();

// Playwright native bridge: exposed by Playwright via page.exposeBinding('patrolNative', ...)
@JS('patrolNative')
external JSPromise<JSString> _patrolNative(JSString requestJson);

/// Calls a native action via Playwright's exposed patrolNative binding.
///
/// [action] - the action name (e.g., 'grantPermissions')
/// [params] - action-specific parameters as a Map
/// [logger] - optional logger function for logging
/// [patrolLog] - optional PatrolLogWriter for step logging
/// Returns a Map with 'ok' boolean and optional 'data' or 'error' fields.
Future<Map<String, dynamic>> callPlaywright(
  String action,
  Map<String, dynamic> params, {
  void Function(String)? logger,
  PatrolLogWriter? patrolLog,
}) async {
  logger?.call('$action() started');
  final text =
      '${AnsiCodes.lightBlue}$action${AnsiCodes.reset} ${AnsiCodes.gray}(native)${AnsiCodes.reset}';

  if (patrolLog != null) {
    patrolLog.log(StepEntry(action: text, status: StepEntryStatus.start));
  }

  try {
    final request = {'action': action, 'params': params};
    final requestJson = jsonEncode(request).toJS;
    final responseJson = await _patrolNative(requestJson).toDart;
    final response = jsonDecode(responseJson.toDart) as Map<String, dynamic>;

    // TODO: check if this was actually successful
    logger?.call('$action() succeeded');
    if (patrolLog != null) {
      patrolLog.log(StepEntry(action: text, status: StepEntryStatus.success));
    }
    return response;
  } catch (err) {
    logger?.call('$action() failed');
    final log = 'Failed to call Playwright: $err';

    if (patrolLog != null) {
      patrolLog.log(StepEntry(action: text, status: StepEntryStatus.failure));
    }
    return {'ok': false, 'error': log};
  }
}

/// Starts the web-exposed service by wiring Dart methods to JS functions.
Future<void> initAppService() async {
  // This cannot be a tearoff (e.g. `isInitialised.complete.toJS`) because
  // that would change the type of the function and it cannot be casted to JS via `toJS`.
  // We must use a lambda to preserve the correct signature for JS interop.
  // ignore: unnecessary_lambdas
  __patrol_setInitialised = () {
    isInitialised.complete();
  }.toJS;
}

/// Starts the web-exposed service by wiring Dart methods to JS functions.
Future<void> runAppService(PatrolAppService service) async {
  // Synchronous version - return JSON string directly
  __patrol_listDartTests = (() {
    return jsonEncode(
      ListDartTestsResponse(group: service.topLevelDartTestGroup).toJson(),
    );
  }).toJS;

  // Callback-based approach for async operations
  __patrol_runDartTestWithCallback = ((JSAny? name, JSFunction callback) {
    final dartName = (name! as JSString).toDart;
    service
        .runDartTest(RunDartTestRequest(name: dartName))
        .then((resp) {
          final result = jsonEncode(resp.toJson());
          callback.callAsFunction(null, result.toJS);
        })
        .catchError((error) {
          callback.callAsFunction(null, 'ERROR: $error'.toJS);
        });
  }).toJS;
}

class PatrolAppService extends PatrolAppServiceServer {
  PatrolAppService({required this.topLevelDartTestGroup});

  // Unused on web; present for API parity
  final int port = 0;

  final DartGroupEntry topLevelDartTestGroup;

  final _testExecutionRequested = Completer<String>();
  Future<String> get testExecutionRequested => _testExecutionRequested.future;

  final _testExecutionCompleted = Completer<_TestExecutionResult>();
  Future<_TestExecutionResult> get testExecutionCompleted =>
      _testExecutionCompleted.future;

  final _patrolLog = PatrolLogWriter();

  Future<void> markDartTestAsCompleted({
    required String dartFileName,
    required bool passed,
    required String? details,
  }) async {
    final requestedDartTestName = await testExecutionRequested;
    assert(requestedDartTestName == dartFileName);
    _testExecutionCompleted.complete(
      _TestExecutionResult(passed: passed, details: details),
    );
  }

  Future<bool> waitForExecutionRequest(String dartTest) async {
    final requestedDartTest = await testExecutionRequested;
    return requestedDartTest == dartTest;
  }

  @override
  Future<ListDartTestsResponse> listDartTests() async {
    return ListDartTestsResponse(group: topLevelDartTestGroup);
  }

  @override
  Future<RunDartTestResponse> runDartTest(RunDartTestRequest request) async {
    _testExecutionRequested.complete(request.name);
    final result = await testExecutionCompleted;
    if (!result.passed) {
      _patrolLog.log(
        TestEntry(name: request.name, status: TestEntryStatus.failure),
      );
      result.details
          ?.split('\n')
          .forEach((e) => _patrolLog.log(ErrorEntry(message: e)));
    } else {
      _patrolLog.log(
        TestEntry(name: request.name, status: TestEntryStatus.success),
      );
    }
    return RunDartTestResponse(
      result: result.passed
          ? RunDartTestResponseResult.success
          : RunDartTestResponseResult.failure,
      details: result.details,
    );
  }
}
