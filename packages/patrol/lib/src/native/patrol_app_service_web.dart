/// This file contains web-specific bindings and interop for Patrol's app service,
/// including Playwright native bridge integration and JS interop for Dart test execution.
///
/// Exposes Dart functions to the browser environment for test discovery and execution,
/// and provides a Dart API for calling Playwright-exposed native actions.

// Identifier name is for JS interop only; its value is not significant in Dart.
// ignore_for_file: non_constant_identifier_names
library;

import 'dart:async';
import 'dart:js_interop';
import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/contracts/patrol_app_service_server.dart';
import 'package:patrol_log/patrol_log.dart';

class _TestExecutionResult {
  const _TestExecutionResult({required this.passed, required this.details});

  final bool passed;
  final String? details;
}

@JS()
external set __patrol__getTests(JSFunction value);

@JS()
external set __patrol__runTest(JSFunction value);

@JS()
external JSBoolean? get __patrol__isInitialised;

@JS()
external set __patrol__onInitialised(JSFunction value);

@JS()
external JSPromise<JSAny?> __patrol__platformHandler(JSAny? request);

/// Calls a native action via Playwright's exposed patrolNative binding.
///
/// [action] - the action name (e.g., 'grantPermissions')
/// [params] - action-specific parameters as a Map
/// [logger] - optional logger function for logging
/// [patrolLog] - optional PatrolLogWriter for step logging
/// Returns a Map with 'ok' boolean and optional 'data' or 'error' fields.
Future<void> callPlaywright(
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
    await __patrol__platformHandler(request.jsify()).toDart;

    logger?.call('$action() succeeded');
    if (patrolLog != null) {
      patrolLog.log(StepEntry(action: text, status: StepEntryStatus.success));
    }
  } catch (err) {
    logger?.call('$action() failed');

    if (patrolLog != null) {
      patrolLog.log(StepEntry(action: text, status: StepEntryStatus.failure));
    }

    throw Exception(err);
  }
}

Future<void> initAppService() {
  final isInitialised = Completer<void>();

  JSVoid onInitialised() {
    isInitialised.complete();
  }

  __patrol__onInitialised = onInitialised.toJS;

  if (__patrol__isInitialised?.toDart ?? false) {
    return Future.value();
  }

  return isInitialised.future;
}

Future<void> runAppService(PatrolAppService service) async {
  JSAny? getTests() {
    return ListDartTestsResponse(
      group: service.topLevelDartTestGroup,
    ).toJson().jsify();
  }

  JSPromise<JSAny?> runTest(JSString name) {
    final dartName = name.toDart;
    return service
        .runDartTest(RunDartTestRequest(name: dartName))
        .then((result) => result.toJson().jsify())
        .toJS;
  }

  __patrol__getTests = getTests.toJS;
  __patrol__runTest = runTest.toJS;
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
