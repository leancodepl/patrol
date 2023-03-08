import 'package:dispose_scope/dispose_scope.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/devices.dart';

typedef TestRunCallback = Future<void> Function(String target, Device device);

// NOTE: This class should probably expose a stream so that test results can be
// listened to in real time.

/// Orchestrates running tests on devices.
///
/// It maps running T test targets on D devices, resulting in T * D test runs.
/// Every test target can also be repeated R times, resulting in T * R * D test
/// runs.
///
/// Tests targets are run sequentially in the context of a single device.
///
/// This class requires a separate builder and executor callbacks. This
/// decouples the building of a test from running the test. All exceptions
/// thrown by [builder] and [executor] are swallowed and reported as test
/// failures. It's up to these callbacks to perform more elaborate error
/// reporting.
abstract class TestRunner implements Disposable {
  /// Sets the numbes of times each test target should be repeated.
  set repeats(int newValue);

  /// Sets the builder callback that is called once for every test target.
  ///
  /// This callback should:
  ///
  ///  * call Gradle task `assembleAndroidTest` (when building for Android)
  ///
  ///  * call `xcodebuild build-for-testing` (when building for iOS)
  ///
  /// The builder callback must build the artifacts necessary for the [executor]
  /// callback to be able to run a test, or throw if it's not possible to build
  /// the artifacts.
  ///
  /// Error reporting is the callback's responsibility.
  set builder(TestRunCallback callback);

  /// Sets the executor callback that can is called 1 or more times for every
  /// test target, except if the [builder] callback threw, in which case the
  /// executor callback isn't called.
  ///
  /// This callback should:
  ///
  /// * call Gradle task `connectedAndroidTest` (when running on Android)
  ///
  /// * call `xcodebuild test-without-building` (when running on iOS simulator)
  ///
  /// * call a combination of `ios-deploy` and `xcodebuild
  ///   test-without-building` (when running on iOS device)
  ///
  /// Error reporting is the callback's responsibility.
  set executor(TestRunCallback callback);

  /// Adds [device] to this runner's internal list of devices.
  void addDevice(Device device);

  /// Adds [target] (a Dart test file) to this runner's internal list of
  /// devices.
  void addTarget(String target);

  /// Runs all added test targets on on all added devices.
  ///
  /// Tests are run sequentially on a single device, but many devices can be
  /// attached at the same time, and thus many tests can be running at the same
  /// time.
  Future<RunResults> run();
}

class RunResults with EquatableMixin {
  const RunResults({required this.targetRunResults});

  final List<TargetRunResult> targetRunResults;

  bool get allSuccessful => targetRunResults.every((e) => e.allRunsPassed);

  @override
  List<Object?> get props => [targetRunResults];
}

/// Represents a single run of a single target on a single device.
class TargetRunResult with EquatableMixin {
  TargetRunResult({
    required this.target,
    required this.device,
    required this.runs,
  });

  final String target;
  final Device device;

  final List<TargetRunStatus> runs;

  String get targetName => basename(target);

  bool get allRunsPassed => runs.every((run) => run == TargetRunStatus.passed);

  bool get allRunsFailed => runs.every(
        (run) =>
            run == TargetRunStatus.failedToBuild ||
            run == TargetRunStatus.failedToExecute,
      );

  /// True if at least 1 test run was canceled.
  bool get canceled => runs.any((run) => run == TargetRunStatus.canceled);

  int get passedRuns {
    return runs.where((run) => run == TargetRunStatus.passed).length;
  }

  int get runsFailedToBuild {
    return runs.where((run) => run == TargetRunStatus.failedToBuild).length;
  }

  int get runsFailedToExecute {
    return runs.where((run) => run == TargetRunStatus.failedToExecute).length;
  }

  @override
  List<Object?> get props => [target, device, runs];
}

enum TargetRunStatus { failedToBuild, failedToExecute, passed, canceled }
