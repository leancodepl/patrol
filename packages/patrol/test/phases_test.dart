import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/phases.dart' show patrolPhasesOf;
import 'package:patrol/src/platform/contracts/contracts.dart';

void main() {
  group('phases()', () {
    test('attaches an immutable phase definition to its callback', () {
      final declaredPhases = <PatrolPhase>[
        PatrolPhase((_) => Future.value()),
        PatrolPhase(
          (_) => Future.value(),
          launch: const PatrolAppLaunch.deepLink('patrol://settings'),
        ),
      ];

      final callback = phases(declaredPhases);
      final definition = patrolPhasesOf(callback);

      expect(definition, isNotNull);
      expect(definition!.phases, hasLength(2));

      final continuation = definition.continuationAfter(0);
      expect(continuation, isNotNull);
      expect(continuation!.nextPhaseIndex, 1);
      expect(continuation.launchUrl, 'patrol://settings');
      expect(definition.continuationAfter(1), isNull);

      declaredPhases.clear();
      expect(definition.phases, hasLength(2));
      expect(
        () => definition.phases.add(PatrolPhase((_) => Future.value())),
        throwsUnsupportedError,
      );
    });

    test('an attach phase keeps the process and can follow a restart', () {
      final definition = patrolPhasesOf(
        phases([
          PatrolPhase((_) => Future.value()),
          PatrolPhase(
            (_) => Future.value(),
            launch: const PatrolAppLaunch.attach(),
          ),
          PatrolPhase((_) => Future.value()),
        ]),
      )!;

      final attach = definition.continuationAfter(0)!;
      expect(attach.keepsProcess, isTrue);
      expect(attach.launchUrl, isNull);
      expect(definition.continuationAfter(1)!.keepsProcess, isFalse);

      expect(definition.canAttachAt(0), isFalse);
      expect(definition.canAttachAt(1), isTrue);
      expect(definition.canAttachAt(2), isFalse);
      expect(definition.canAttachAt(3), isFalse);
    });

    test('rejects an empty phase list', () {
      expect(() => phases([]), throwsArgumentError);
    });
  });

  test('continuation response survives JSON serialization', () {
    const response = RunDartTestResponse(
      result: RunDartTestResponseResult.continuation,
      nextPhaseIndex: 2,
      nextPhaseLaunchUrl: 'patrol://settings',
      nextPhaseKeepsProcess: true,
    );

    expect(RunDartTestResponse.fromJson(response.toJson()), response);
  });

  test('restart request survives JSON serialization', () {
    const request = RunDartTestRequest(
      name: 'test',
      phaseIndex: 1,
      engineRestarted: true,
    );

    expect(RunDartTestRequest.fromJson(request.toJson()), request);
  });
}
