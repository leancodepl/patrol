// ignore_for_file: avoid_print

// TODO: Use a logger instead of print

import 'dart:async';
import 'dart:io' as io;

import 'package:patrol/src/common.dart';
import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/contracts/patrol_app_service_server.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
// ignore: implementation_imports
import 'package:test_api/src/backend/live_test.dart';

const _port = 8082;
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
    io.InternetAddress.anyIPv4,
    _port,
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
  PatrolAppService();

  /// The ambient test group that wraps all the other groups and tests in the
  /// bundled Dart test file.
  DartGroupEntry? topLevelDartTestGroup;

  /// The names of all setUpAll callbacks.
  ///
  /// setUpAlls, unlike setUps, aren't executed in the [LiveTest] context.
  /// Because of this, we can't depend on the [LiveTest]'s name, so we identify
  /// them by the parent group ID instead.
  ///
  /// This is a list of groups containing setUpAllCallbacks with an index
  /// appended.
  List<String> setUpAlls = [];

  final _didReceiveLifecycleCallbacksState = Completer<Map<String, bool>>();

  /// A completer that completes when the native side sets the state of
  /// lifecycle callbacks.
  ///
  /// Completes with a map that knows which lifecycle callbacks have been
  /// already executed.
  Future<Map<String, bool>> get didReceiveLifecycleCallbacksState {
    return _didReceiveLifecycleCallbacksState.future;
  }

  /// A completer that completes with the name of the Dart test file that was
  /// requested to execute by the native side.
  final _didRequestTestExecution = Completer<String>();

  /// A future that completes with the name of the Dart test file that was
  /// requested to execute by the native side.
  Future<String> get didRequestTestExecution => _didRequestTestExecution.future;

  final _didCompleteTestExecution = Completer<_TestExecutionResult>();

  /// A future that completes when the Dart test file (whose execution was
  /// requested by the native side) completes.
  ///
  /// Returns true if the test passed, false otherwise.
  Future<_TestExecutionResult> get didCompleteTestExecution {
    return _didCompleteTestExecution.future;
  }

  /// Adds a setUpAll callback to the list of all setUpAll callbacks.
  ///
  /// Returns the name under which this setUpAll callback was added.
  String addSetUpAll(String group) {
    // Not optimal, but good enough for now.

    // Go over all groups, checking if the group is already in the list.
    var groupIndex = 0;
    for (final setUpAll in setUpAlls) {
      final parts = setUpAll.split(' ');
      final groupName = parts.sublist(0, parts.length - 1).join(' ');

      if (groupName == group) {
        groupIndex++;
      }
    }

    final name = '$group $groupIndex';

    setUpAlls.add(name);
    return name;
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
      _didRequestTestExecution.isCompleted,
      'Tried to mark a test as completed, but no tests were requested to run',
    );

    final requestedDartTestName = await didRequestTestExecution;
    assert(
      requestedDartTestName == dartFileName,
      'Tried to mark test $dartFileName as completed, but the test '
      'that was most recently requested to run was $requestedDartTestName',
    );

    _didCompleteTestExecution.complete(
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

    final requestedDartTest = await didRequestTestExecution;
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

    final topLevelDartTestGroup = this.topLevelDartTestGroup;
    if (topLevelDartTestGroup == null) {
      throw StateError(
        'PatrolAppService.listDartTests(): tests not discovered yet',
      );
    }

    return ListDartTestsResponse(group: topLevelDartTestGroup);
  }

  @override
  Future<RunDartTestResponse> runDartTest(RunDartTestRequest request) async {
    print('PatrolAppService.runDartTest(${request.name}) called');

    assert(_didCompleteTestExecution.isCompleted == false);

    _didRequestTestExecution.complete(request.name);

    final testExecutionResult = await didCompleteTestExecution;
    return RunDartTestResponse(
      result: testExecutionResult.passed
          ? RunDartTestResponseResult.success
          : RunDartTestResponseResult.failure,
      details: testExecutionResult.details,
    );
  }

  @override
  Future<ListDartLifecycleCallbacksResponse>
      listDartLifecycleCallbacks() async {
    print('PatrolAppService.listDartLifecycleCallbacks() called');

    assert(_didRequestTestExecution.isCompleted == false);
    assert(_didCompleteTestExecution.isCompleted == false);
    assert(_didReceiveLifecycleCallbacksState.isCompleted == false);

    return ListDartLifecycleCallbacksResponse(
      setUpAlls: setUpAlls,
      tearDownAlls: [],
    );
  }

  @override
  Future<Empty> setLifecycleCallbacksState(
    SetLifecycleCallbacksStateRequest request,
  ) async {
    print('PatrolAppService.setLifecycleCallbacksState() called');
    assert(_didRequestTestExecution.isCompleted == false);
    assert(_didCompleteTestExecution.isCompleted == false);
    assert(_didReceiveLifecycleCallbacksState.isCompleted == false);

    _didReceiveLifecycleCallbacksState.complete(request.state);
    return Empty();
  }
}
