import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';

@internal
Future<void> runAppService({required DartTestGroup testGroup}) async {
  final services = [PatrolAppService(topLevelDartTestGroup: testGroup)];
  final interceptors = <Interceptor>[];
  final codecRegistry = CodecRegistry();

  final server = Server(services, interceptors, codecRegistry);
  await server.serve(port: 8002);
}

/// Provides a gRPC service for the native side to interact with the Dart tests.
@internal
class PatrolAppService extends PatrolAppServiceBase {
  /// Creates a new [PatrolAppService].
  PatrolAppService({required this.topLevelDartTestGroup});

  /// The ambient Dart test group that wraps all the other groups and tests in
  /// the bundled Dart test file.
  final DartTestGroup topLevelDartTestGroup;

  @override
  Future<ListDartTestsResponse> listDartTests(
    ServiceCall call,
    Empty request,
  ) async {
    return ListDartTestsResponse(group: topLevelDartTestGroup);
  }

  @override
  Future<Empty> runDartTest(
    ServiceCall call,
    RunDartTestRequest request,
  ) async {
    // run a dart test from topLevelDartTestGroups named request.testName

    return Empty();
  }
}
