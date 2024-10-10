// ignore_for_file: avoid_print

// TODO: Use a logger instead of print

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:patrol/src/binding.dart';
import 'package:patrol/src/common.dart';
import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/contracts/patrol_app_service_server.dart';
import 'package:patrol/src/native/native.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

const _idleTimeout = Duration(hours: 2);

class _TestExecutionResult {
  const _TestExecutionResult({required this.passed, required this.details});

  final bool passed;
  final String? details;
}

/// Starts the gRPC server that runs the [PatrolAppService].
Future<void> runAppService(PatrolAppService service) async {
  final pipeline = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(service.handle);

  final server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4,
    service.port,
    poweredByHeader: null,
  );

  server.idleTimeout = _idleTimeout;

  final address = server.address;

  print(
    'PatrolAppService started, address: ${address.address}, host: ${address.host}, port: ${server.port}',
  );
}

/// Implements a stateful HTTP service for querying and executing Dart tests.
///
/// This is an internal class and you don't want to use it. It's public so that
/// the generated code can access it.
class PatrolAppService extends PatrolAppServiceServer {
  /// Creates a new [PatrolAppService].
  PatrolAppService({required this.topLevelDartTestGroup})
      : port = const int.fromEnvironment(
          'PATROL_APP_SERVER_PORT',
          defaultValue: 8082,
        );

  /// Port the server will use to listen for incoming HTTP traffic.
  final int port;

  /// The ambient test group that wraps all the other groups and tests in the
  /// bundled Dart test file.
  final DartGroupEntry topLevelDartTestGroup;

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

  /// Returns when the native side requests execution of a Dart test. If the
  /// native side requsted execution of [dartTest], returns true. Otherwise
  /// returns false.
  ///
  /// It's used inside of [patrolTest] to halt execution of test body until
  /// [runDartTest] is called.
  ///
  /// The native side requests execution by RPC-ing [runDartTest] and providing
  /// name of a Dart test that it wants to currently execute [dartTest].
  Future<bool> waitForExecutionRequest(String dartTest) async {
    print('PatrolAppService: registered "$dartTest"');

    final requestedDartTest = await testExecutionRequested;
    if (requestedDartTest != dartTest) {
      // If the requested Dart test is not the one we're waiting for now, it
      // means that dartTest was already executed. Return false so that callers
      // can skip the already executed test.

      print(
        'PatrolAppService: registered test "$dartTest" was not matched by requested test "$requestedDartTest"',
      );

      return false;
    }

    print('PatrolAppService: requested execution of test "$dartTest"');

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

    final patrolBinding =
        PatrolBinding.ensureInitialized(const NativeAutomatorConfig());

    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final previousDetails =
          switch (patrolBinding.testResults[request.name] as Failure?) {
        Failure(:final details?) => FlutterErrorDetails(exception: details),
        _ => null,
      };

      patrolBinding.testResults[request.name] = Failure(
        request.name,
        '$details\n$previousDetails',
      );
    };
    final testExecutionResult = await testExecutionCompleted;
    FlutterError.onError = previousOnError;

    return RunDartTestResponse(
      result: testExecutionResult.passed
          ? RunDartTestResponseResult.success
          : RunDartTestResponseResult.failure,
      details: testExecutionResult.details,
    );
  }
}
