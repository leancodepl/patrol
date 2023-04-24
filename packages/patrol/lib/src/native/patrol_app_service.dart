import 'dart:async';
import 'dart:io' as io;

import 'package:grpc/grpc.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';

const _port = 8082;

Future<void> runAppService(PatrolAppService service) async {
  final services = [service];
  final interceptors = <Interceptor>[];
  final codecRegistry = CodecRegistry();

  final server = Server(services, interceptors, codecRegistry);
  await server.serve(address: io.InternetAddress.anyIPv4, port: _port);
  print('PatrolAppService started on port $_port');
}

/// Implements a stateful gRPC service for querying and executing Dart tests.
class PatrolAppService extends PatrolAppServiceBase {
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

  final _testExecutionCompleted = Completer<bool>();

  /// A future that completes when the Dart test file (whose execution was
  /// requested by the native side) completes.
  ///
  /// Returns true if the test passed, false otherwise.
  Future<bool> get testExecutionCompleted => _testExecutionCompleted.future;

  Future<void> markDartTestAsCompleted(
    String completedDartTestName,
    bool passed,
  ) async {
    print('PatrolAppService.markDartTestAsCompleted(): $completedDartTestName');
    assert(
      _testExecutionRequested.isCompleted,
      'Tried to mark a test as completed, but no tests were requested to run',
    );

    final requestedDartTestName = await testExecutionRequested;
    assert(
      requestedDartTestName == completedDartTestName,
      'Tried to mark test $completedDartTestName as completed, but the test '
      'that was most recently requested to run was $requestedDartTestName',
    );

    _testExecutionCompleted.complete(passed);
  }

  /// Returns when the native side requests execution of a Dart test file.
  ///
  /// The native side requests execution by RPC-ing [runDartTest] and providing
  /// name of a Dart test file.
  ///
  /// Returns true if the native side requsted execution of [dartTestFile].
  /// Returns false otherwise.
  Future<bool> waitForRunRequest(String dartTestFile) async {
    print('PatrolAppService.waitUntilRunRequested(): $dartTestFile registered');

    final requestedDartTestFile = await testExecutionRequested;
    if (requestedDartTestFile != dartTestFile) {
      // If the requested Dart test file is not the one we're waiting for now,
      // it means that dartTestFile was already executed. Return false so that
      // callers can skip the already executed test.

      print(
        'PatrolAppService.waitUntilRunRequested(): $dartTestFile was not matched by requested test $requestedDartTestFile',
      );

      return false;
    }

    return true;
  }

  @override
  Future<ListDartTestsResponse> listDartTests(
    ServiceCall call,
    Empty request,
  ) async {
    print('PatrolAppService.listDartTests() called');
    return ListDartTestsResponse(group: topLevelDartTestGroup);
  }

  @override
  Future<RunDartTestResponse> runDartTest(
    ServiceCall call,
    RunDartTestRequest request,
  ) async {
    assert(_testExecutionCompleted.isCompleted == false);
    // patrolTest() always calls this method.

    print('PatrolAppService.runDartTest(${request.name}) called');
    _testExecutionRequested.complete(request.name);

    final passed = await testExecutionCompleted;
    return RunDartTestResponse(
      result: passed
          ? RunDartTestResponse_Result.SUCCESS
          : RunDartTestResponse_Result.FAILURE,
    );
  }
}
