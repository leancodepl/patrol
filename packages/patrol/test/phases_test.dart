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
          launch: PatrolAppLaunch.deepLink('patrol://settings'),
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

    test('rejects a deep link on the first phase', () {
      expect(
        () => phases([
          PatrolPhase(
            (_) => Future.value(),
            launch: PatrolAppLaunch.deepLink('patrol://settings'),
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('rejects attach on the first phase', () {
      expect(
        () => phases([
          PatrolPhase(
            (_) => Future.value(),
            launch: const PatrolAppLaunch.attach(),
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('takes deep links with a scheme, with or without a host', () {
      expect(
        PatrolAppLaunch.deepLink('patrol://check/somepath?query=10').url,
        'patrol://check/somepath?query=10',
      );
      expect(PatrolAppLaunch.deepLink('myapp:settings').url, 'myapp:settings');
    });

    test('rejects a deep link without a scheme', () {
      expect(() => PatrolAppLaunch.deepLink('/settings'), throwsAssertionError);
      expect(() => PatrolAppLaunch.deepLink(''), throwsAssertionError);
    });

    // Runners that can relaunch the app ask for phase 0; the others send no
    // phase, and a test that needs a relaunch fails before its first phase.
    test('fails a multi-phase test when the runner sends no phase', () {
      final definition = patrolPhasesOf(
        phases([
          PatrolPhase((_) => Future.value()),
          PatrolPhase((_) => Future.value()),
        ]),
      )!;

      expect(() => definition.phaseIndexFor(null), throwsUnsupportedError);
      expect(definition.phaseIndexFor(0), 0);
      expect(definition.phaseIndexFor(1), 1);
    });

    // Attach phases need the runner to ask for the next phase, which only the
    // runners that send phase 0 do.
    test(
      'fails a test with an attach phase when the runner sends no phase',
      () {
        final definition = patrolPhasesOf(
          phases([
            PatrolPhase((_) => Future.value()),
            PatrolPhase(
              (_) => Future.value(),
              launch: const PatrolAppLaunch.attach(),
            ),
          ]),
        )!;

        expect(() => definition.phaseIndexFor(null), throwsUnsupportedError);
      },
    );

    test('runs a single phase on any runner', () {
      final definition = patrolPhasesOf(
        phases([PatrolPhase((_) => Future.value())]),
      )!;

      expect(definition.phaseIndexFor(null), 0);
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
