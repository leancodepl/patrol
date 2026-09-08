import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/mobile/patrol_app_service_io.dart';

DartGroupEntry _emptyGroup() => const DartGroupEntry(
  name: '',
  type: GroupEntryType.group,
  entries: [],
  skip: false,
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
  group('PatrolAppService', () {
    test(
      'with reuseAcrossTests serves many tests from one instance (orchestrator '
      'off / coverage mode)',
      () async {
        final service = PatrolAppService(
          topLevelDartTestGroup: _emptyGroup(),
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
      final service = PatrolAppService(
        topLevelDartTestGroup: _emptyGroup(),
        reuseAcrossTests: false,
      );

      final first = await _runCycle(service, 'a_test', passed: true);
      expect(first.result, RunDartTestResponseResult.success);

      // The one-shot completers are spent; a second request must not be
      // silently accepted.
      await expectLater(
        service.runDartTest(RunDartTestRequest(name: 'b_test')),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
