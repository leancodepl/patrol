import 'package:meta/meta.dart';
import 'package:patrol/src/custom_finders/patrol_integration_tester.dart';

/// A callback containing the Dart part of a Patrol test.
typedef PatrolPhaseCallback = Future<void> Function(PatrolIntegrationTester $);

/// One Dart part of a phased Patrol test.
final class PatrolPhase {
  /// Creates a phase with the way the app should be launched before it.
  const PatrolPhase(
    this.callback, {
    this.launch = const PatrolAppLaunch.normal(),
  });

  /// The test code to execute during this phase.
  final PatrolPhaseCallback callback;

  /// How the app should be launched before this phase.
  ///
  /// This is ignored for the first phase, which starts normally.
  final PatrolAppLaunch launch;
}

/// How Patrol launches the app before a phase.
final class PatrolAppLaunch {
  /// Launches the app using its launcher activity.
  const PatrolAppLaunch.normal() : url = null;

  /// Launches the app through [url].
  ///
  /// [url] must include a scheme (for example `myapp://settings`). Plain paths
  /// like `/settings` are rejected.
  PatrolAppLaunch.deepLink(String this.url)
    : assert(url != ''),
      assert(
        url.contains('://'),
        'Deep link URL must include a scheme, e.g. myapp://path',
      );

  /// The deep link URL, or `null` for a normal launch.
  final String? url;
}

/// Metadata attached to the callback returned by [phases].
@internal
final class PatrolPhases {
  PatrolPhases(List<PatrolPhase> phases) : phases = List.unmodifiable(phases);

  /// The phases in declaration order.
  final List<PatrolPhase> phases;

  /// Returns the phase requested by the native runner.
  PatrolPhase phaseAt(int index) {
    if (index < 0 || index >= phases.length) {
      throw RangeError.index(index, phases, 'index');
    }
    return phases[index];
  }

  /// Returns the index of the phase to run for a native request that asked
  /// for [requestedPhaseIndex].
  ///
  /// Runners that can kill and relaunch the app ask for phase `0` explicitly.
  /// The others (macOS, web, Windows and the in-app Android layout) send no
  /// index, so a test with more than one phase fails here, before its first
  /// phase runs, instead of after it.
  int phaseIndexFor(int? requestedPhaseIndex) {
    if (requestedPhaseIndex == null && phases.length > 1) {
      throw UnsupportedError(
        'This test has ${phases.length} phases, but this native test runner '
        "can't kill and relaunch the app. Phased tests run on Android with the "
        ':patrolTest layout and on iOS.',
      );
    }
    return requestedPhaseIndex ?? 0;
  }

  /// Describes how to restart the app for the phase after [phaseIndex].
  PatrolPhaseContinuation? continuationAfter(int phaseIndex) {
    phaseAt(phaseIndex);
    final nextPhaseIndex = phaseIndex + 1;
    if (nextPhaseIndex >= phases.length) {
      return null;
    }

    return PatrolPhaseContinuation(
      nextPhaseIndex: nextPhaseIndex,
      launchUrl: phases[nextPhaseIndex].launch.url,
    );
  }
}

/// Restart information returned after a Dart phase completes.
@internal
final class PatrolPhaseContinuation {
  PatrolPhaseContinuation({
    required this.nextPhaseIndex,
    required this.launchUrl,
  });

  /// The next Dart phase.
  final int nextPhaseIndex;

  /// The deep link used to launch it, or `null` for a normal launch.
  final String? launchUrl;
}

final _phasesByCallback = Expando<PatrolPhases>('Patrol phased test');

/// Creates a phased body accepted by `patrolTest`.
///
/// `patrolTest` reads the phase metadata attached to the returned callback and
/// runs only the Dart phase requested by the native runner. Calling the
/// returned callback directly is unsupported.
PatrolPhaseCallback phases(List<PatrolPhase> phases) {
  if (phases.isEmpty) {
    throw ArgumentError.value(
      phases,
      'phases',
      'A phased test must contain at least one phase',
    );
  }
  if (phases.first.launch.url != null) {
    throw ArgumentError(
      'launch on the first phase is ignored by the native runner; '
      'put PatrolAppLaunch.deepLink on phase 2 or later',
    );
  }
  Future<void> callback(PatrolIntegrationTester $) {
    throw UnsupportedError(
      'phases([...]) must be passed directly as the patrolTest body; '
      'wrapping it in another callback loses the phase metadata',
    );
  }

  _phasesByCallback[callback] = PatrolPhases(phases);
  return callback;
}

/// Returns phased-test metadata attached to [callback], if any.
@internal
PatrolPhases? patrolPhasesOf(PatrolPhaseCallback callback) {
  return _phasesByCallback[callback];
}
