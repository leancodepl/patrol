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
  const PatrolAppLaunch.normal() : url = null, keepsProcess = false;

  /// Launches the app through [url].
  const PatrolAppLaunch.deepLink(String this.url)
    : assert(url != ''),
      keepsProcess = false;

  /// Does not kill or launch the app. The phase runs in the app as the
  /// previous phase left it.
  ///
  /// Use it when the previous phase can make the app restart its Flutter
  /// engine, for example when Android recreates the activity for a deep link.
  /// The Dart test cannot survive that, so the previous phase ends where the
  /// engine stops, even if that is in the middle of its callback. If the
  /// engine keeps running, the previous phase runs to its end and this phase
  /// follows in the same engine.
  ///
  /// The process keeps its native state in both cases. Dart state is lost only
  /// when the engine restarts, so do not share Dart objects between the two
  /// phases.
  const PatrolAppLaunch.attach() : url = null, keepsProcess = true;

  /// The deep link URL, or `null` if Patrol does not open one.
  final String? url;

  /// Whether the phase starts without killing the app.
  final bool keepsProcess;
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

  /// Describes how to start the phase after [phaseIndex].
  PatrolPhaseContinuation? continuationAfter(int phaseIndex) {
    phaseAt(phaseIndex);
    final nextPhaseIndex = phaseIndex + 1;
    if (nextPhaseIndex >= phases.length) {
      return null;
    }

    final launch = phases[nextPhaseIndex].launch;
    return PatrolPhaseContinuation(
      nextPhaseIndex: nextPhaseIndex,
      launchUrl: launch.url,
      keepsProcess: launch.keepsProcess,
    );
  }

  /// Whether the phase at [phaseIndex] can run in an engine that replaced the
  /// one the previous phase ran in.
  bool canAttachAt(int phaseIndex) {
    return phaseIndex > 0 &&
        phaseIndex < phases.length &&
        phases[phaseIndex].launch.keepsProcess;
  }
}

/// How to start the next phase, returned after a Dart phase completes.
@internal
final class PatrolPhaseContinuation {
  PatrolPhaseContinuation({
    required this.nextPhaseIndex,
    required this.launchUrl,
    this.keepsProcess = false,
  });

  /// The next Dart phase.
  final int nextPhaseIndex;

  /// The deep link used to launch it, or `null` for a normal launch.
  final String? launchUrl;

  /// Whether the next phase attaches to the running app.
  final bool keepsProcess;
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
  Future<void> callback(PatrolIntegrationTester $) {
    throw UnsupportedError(
      'A phased Patrol test body can only be executed by patrolTest',
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
