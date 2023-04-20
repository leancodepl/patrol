import 'dart:async';
import 'dart:io' as io;

import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';

const _port = 8082;

@internal
Future<void> runAppService(PatrolAppService service) async {
  final services = [service];
  final interceptors = <Interceptor>[];
  final codecRegistry = CodecRegistry();

  final server = Server(services, interceptors, codecRegistry);
  print('Starting PatrolAppService on port $_port...');
  await server.serve(address: io.InternetAddress.anyIPv4, port: _port);
  print('PatrolAppService started on port $_port');
}

/// Provides a gRPC service for the native side to interact with the Dart tests.
@internal
class PatrolAppService extends PatrolAppServiceBase {
  /// Creates a new [PatrolAppService].
  PatrolAppService({required this.topLevelDartTestGroup});

  /// The ambient test group that wraps all the other groups and tests in
  /// the bundled Dart test file.
  final DartTestGroup topLevelDartTestGroup;

  /// A completer that completes when the name of the Dart test file that was
  /// requested to be run by the native side.
  final _nameCompleter = Completer<String>();

  final _runCompleter = Completer<void>();

  Future<void> get runFuture => _runCompleter.future;

  Future<void> markDartTestAsCompleted(String completedDartTestName) async {
    print('PatrolAppService.markDartTestAsCompleted(): $completedDartTestName');
    assert(
      _nameCompleter.isCompleted,
      'Tried to mark a test as completed, but no tests were requested to run',
    );

    final requestedDartTestName = await _nameCompleter.future;
    assert(
      requestedDartTestName == completedDartTestName,
      'Tried to mark test $completedDartTestName as completed, but the test'
      'that was most recently requested to run was $requestedDartTestName',
    );

    _runCompleter.complete();
  }

  /// This method returns once the Dart test named [name] is requested by the
  /// native side. Otherwise, it never returns.
  Future<void> waitForRunRequest(String name) async {
    print('PatrolAppService.waitUntilRunRequested(): $name registered');
    final requested = await _nameCompleter.future;
    if (requested != name) {
      print(
        'PatrolAppService.waitUntilRunRequested(): $name was not matched by requested test $requested',
      );

      // If the requested test is not the one we're waiting for, it means that
      // the native test runner doesn't want to run us yet.
      // It's okay, since that other tests have registered themselves for
      // running using this method as well. Our turn will come, eventually.
      return Completer<void>().future;
    }
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
  Future<Empty> runDartTest(
    ServiceCall call,
    RunDartTestRequest request,
  ) async {
    print('PatrolAppService.runDartTest(${request.name}) called');
    // All Dart tests register themselves for running using this method.
    _nameCompleter.complete(request.name);

    await _runCompleter.future;
    return Empty();
  }
}
