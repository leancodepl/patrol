import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';

DartGroupEntry _group(String name, List<DartGroupEntry> entries) =>
    DartGroupEntry(
      name: name,
      type: GroupEntryType.group,
      entries: entries,
      skip: false,
      tags: [],
    );

DartGroupEntry _test(String name, {bool skip = false}) => DartGroupEntry(
  name: name,
  type: GroupEntryType.test,
  entries: [],
  skip: skip,
  tags: [],
);

void main() {
  group('PatrolAppService.runDartTest()', () {
    late PatrolAppService service;

    setUp(() {
      service = PatrolAppService(
        topLevelDartTestGroup: _group('', [
          _group('example_test', [
            _test('runs here'),
            _test('skipped here', skip: true),
          ]),
        ]),
      );
    });

    // Both cases would otherwise leave the native runner waiting for a result
    // that nothing in the app is ever going to produce.
    test('reports a skipped test instead of waiting for it', () async {
      final response = await service.runDartTest(
        const RunDartTestRequest(name: 'example_test skipped here'),
      );

      expect(response.result, RunDartTestResponseResult.skipped);
    });

    test('fails a test this app does not have', () async {
      final response = await service.runDartTest(
        const RunDartTestRequest(name: 'example_test gone missing'),
      );

      expect(response.result, RunDartTestResponseResult.failure);
      expect(response.details, contains('patrolTargetPlatform'));
    });

    test('runs a test that exists and is not skipped', () async {
      final response = service.runDartTest(
        const RunDartTestRequest(name: 'example_test runs here'),
      );

      // The test is now waiting for its result, which only the test body
      // reports, so nothing is returned until then.
      await service.testExecutionRequested;
      await service.markDartTestAsCompleted(
        dartFileName: 'example_test runs here',
        passed: true,
        details: null,
      );

      expect((await response).result, RunDartTestResponseResult.success);
    });
  });
}
