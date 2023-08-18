// ignore_for_file: avoid_print
// TODO: Use a logger instead of print

import 'dart:async';

import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/contracts/patrol_app_service_server.dart';

import 'package:shelf/shelf_io.dart' as shelf_io;

const _port = 8082;

class _TestExecutionResult {
  const _TestExecutionResult({required this.passed, required this.details});

  final bool passed;
  final String? details;
}

/// Starts the gRPC server that runs the [PatrolAppService].
Future<void> runAppService(PatrolAppService service) async {
  await shelf_io.serve(
    (request) async {
      final result = await service.handle(request);
      return result!;
    },
    '0.0.0.0',
    _port,
  );

  print('PatrolAppService started on port $_port');
}

/// Implements a stateful gRPC service for querying and executing Dart tests.
///
/// This is an internal class and you don't want to use it. It's public so that
/// the generated code can access it.
class PatrolAppService extends PatrolAppServiceServer {
  /// Creates a new [PatrolAppService].
  PatrolAppService({required this.topLevelDartTestGroup});

  /// The ambient test group that wraps all the other groups and tests in the
  /// bundled Dart test file.
  final DartTestGroup topLevelDartTestGroup;

  /// A completer that completes with the name of the Dart test file that was
  /// requested to execute by the native side.
  final _testExecutionRequested = Completer<String>();

  /// A future that completes with the name of the Dart test file that was
  /// requested to execute by the native side.
  Future<String> get testExecutionRequested => _testExecutionRequested.future;

  final _testExecutionCompleted = Completer<_TestExecutionResult>();

  /// A future that completes when the Dart test file (whose execution was
  /// requested by the native side) completes.
  ///
  /// Returns true if the test passed, false otherwise.
  Future<_TestExecutionResult> get testExecutionCompleted {
    return _testExecutionCompleted.future;
  }

  /// Marks [dartFileName] as completed with the given [passed] status.
  ///
  /// If an exception was thrown during the test, [details] should contain the
  /// useful information.
  Future<void> markDartTestAsCompleted({
    required String dartFileName,
    required bool passed,
    required String? details,
  }) async {
    print('PatrolAppService.markDartTestAsCompleted(): $dartFileName');
    assert(
      _testExecutionRequested.isCompleted,
      'Tried to mark a test as completed, but no tests were requested to run',
    );

    final requestedDartTestName = await testExecutionRequested;
    assert(
      requestedDartTestName == dartFileName,
      'Tried to mark test $dartFileName as completed, but the test '
      'that was most recently requested to run was $requestedDartTestName',
    );

    _testExecutionCompleted.complete(
      _TestExecutionResult(passed: passed, details: details),
    );
  }

  /// Returns when the native side requests execution of a Dart test file.
  ///
  /// The native side requests execution by RPC-ing [runDartTest] and providing
  /// name of a Dart test file.
  ///
  /// Returns true if the native side requsted execution of [dartTestFile].
  /// Returns false otherwise.
  Future<bool> waitForExecutionRequest(String dartTestFile) async {
    print('PatrolAppService: registered "$dartTestFile"');

    final requestedDartTestFile = await testExecutionRequested;
    if (requestedDartTestFile != dartTestFile) {
      // If the requested Dart test file is not the one we're waiting for now,
      // it means that dartTestFile was already executed. Return false so that
      // callers can skip the already executed test.

      print(
        'PatrolAppService: registered test "$dartTestFile" was not matched by requested test "$requestedDartTestFile"',
      );

      return false;
    }

    print('PatrolAppService: requested execution of test "$dartTestFile"');

    return true;
  }

  @override
  Future<ListDartTestsResponse> listDartTests() async {
    print('PatrolAppService.listDartTests() called');
    return ListDartTestsResponse(group: topLevelDartTestGroup);
  }

  @override
  Future<RunDartTestResponse> runDartTest(RunDartTestRequest request) async {
    assert(_testExecutionCompleted.isCompleted == false);
    // patrolTest() always calls this method.

    print('PatrolAppService.runDartTest(${request.name}) called');
    _testExecutionRequested.complete(request.name);

    final testExecutionResult = await testExecutionCompleted;
    return RunDartTestResponse(
      result: testExecutionResult.passed
          ? RunDartTestResponseResult.success
          : RunDartTestResponseResult.failure,
      details: testExecutionResult.details,
    );
  }
}
