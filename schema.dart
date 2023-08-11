class DartTestCase {
  late String name;
}

class DartTestGroup {
  String? name;
  List<DartTestCase>? tests;
  List<DartTestGroup>? groups;
}

class ListDartTestsResponse {
  late DartTestGroup group;
}

enum RunDartTestResponseResult {
  success,
  skipped,
  failure,
}

class RunDartTestRequest {
  String? name;
}

class RunDartTestResponse {
  late RunDartTestResponseResult result;
  String? details;
}

abstract class PatrolAppService<SwiftClient, DartServer> {
  ListDartTestsResponse listDartTests();
  RunDartTestResponse runDartTest(RunDartTestRequest request);
}
