import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/mobile/patrol_app_service_io.dart';

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

/// Drives one native<->Dart round trip: native requests [name] via
/// `runDartTest`, the Dart side reports it done via `markDartTestAsCompleted`,
/// and we return the response the native side would receive.
Future<RunDartTestResponse> _runCycle(
  PatrolAppService service,
  String name, {
  required bool passed,
}) async {
  // Don't await yet: runDartTest completes the "requested" completer, then
  // blocks on the "completed" one, exactly like the real HTTP handler.
  final response = service.runDartTest(RunDartTestRequest(name: name));
  await service.markDartTestAsCompleted(
    dartFileName: name,
    passed: passed,
    details: passed ? null : 'boom',
  );
  return response;
}

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

  group('PatrolAppService reuseAcrossTests', () {
    // The tests have to exist in the group, otherwise runDartTest reports them
    // missing and returns before any of the completer handling is reached.
    DartGroupEntry knownTests() =>
        _group('', [_test('a_test'), _test('b_test'), _test('c_test')]);

    test(
      'with reuseAcrossTests serves many tests from one instance (orchestrator '
      'off / coverage mode)',
      () async {
        final service = PatrolAppService(
          topLevelDartTestGroup: knownTests(),
          reuseAcrossTests: true,
        );

        final first = await _runCycle(service, 'a_test', passed: true);
        expect(first.result, RunDartTestResponseResult.success);

        // The completers were recreated, so the next test's request is matched
        // by a fresh waitForExecutionRequest and served without error.
        final requested = service.waitForExecutionRequest('b_test');
        final second = await _runCycle(service, 'b_test', passed: false);
        expect(await requested, isTrue);
        expect(second.result, RunDartTestResponseResult.failure);
        expect(second.details, 'boom');

        final third = await _runCycle(service, 'c_test', passed: true);
        expect(third.result, RunDartTestResponseResult.success);
      },
    );

    test('without reuseAcrossTests a second runDartTest is rejected (normal '
        'orchestrator-on flow is one test per process)', () async {
      // reuseAcrossTests defaults to false; this is the normal flow.
      final service = PatrolAppService(topLevelDartTestGroup: knownTests());

      final first = await _runCycle(service, 'a_test', passed: true);
      expect(first.result, RunDartTestResponseResult.success);

      // The one-shot completers are spent; a second request must not be
      // silently accepted.
      await expectLater(
        service.runDartTest(const RunDartTestRequest(name: 'b_test')),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
