import 'package:dispose_scope/dispose_scope.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/devices.dart';

// TODO(bartekpacia): Lots of this code is not needed after #1004 is done.

enum TargetRunStatus { failedToBuild, failedToExecute, passed, canceled }

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

typedef TestRunCallback = Future<void> Function(String target, Device device);

// NOTE: TestRunner should probably expose a stream so that test results can be
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
  factory TestRunner() => _NativeTestRunner();

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

class _NativeTestRunner implements TestRunner, Disposable {
  final Map<String, Device> _devices = {};
  final Set<String> _targets = {};
  bool _running = false;
  bool _disposed = false;
  int _repeats = 1;

  @override
  set repeats(int newValue) {
    if (newValue < 1) {
      throw StateError('repeats must be greater than 0');
    }

    if (_running) {
      throw StateError('repeats cannot be changed while running');
    }

    _repeats = newValue;
  }

  TestRunCallback? _builder;

  @override
  set builder(TestRunCallback callback) => _builder = callback;

  TestRunCallback? _executor;

  @override
  set executor(TestRunCallback callback) => _executor = callback;

  @override
  void addDevice(Device device) {
    if (_running) {
      throw StateError('devices can only be added before run');
    }

    if (_devices[device.id] != null) {
      throw StateError('device with id ${device.id} is already added');
    }

    _devices[device.id] = device;
  }

  @override
  void addTarget(String target) {
    if (_running) {
      throw StateError('tests can only be added before run');
    }

    if (_targets.contains(target)) {
      throw StateError('target $target is already added');
    }

    _targets.add(target);
  }

  @override
  Future<RunResults> run() async {
    if (_running) {
      throw StateError('tests are already running');
    }
    if (_devices.isEmpty) {
      throw StateError('no devices to run tests on');
    }
    if (_targets.isEmpty) {
      throw StateError('no test targets to run');
    }

    final builder = _builder;
    if (builder == null) {
      throw StateError('builder is null');
    }

    final executor = _executor;
    if (executor == null) {
      throw StateError('executor is null');
    }

    _running = true;

    final targetRunResults = <TargetRunResult>[];

    final testRunsOnAllDevices = <Future<void>>[];
    for (final device in _devices.values) {
      Future<void> runTestsOnDevice() async {
        for (final target in _targets) {
          final targetRuns = <TargetRunStatus>[];
          targetRunResults.add(
            TargetRunResult(target: target, device: device, runs: targetRuns),
          );

          if (_disposed) {
            for (var i = 0; i < _repeats; i++) {
              targetRuns.add(TargetRunStatus.canceled);
            }
            continue;
          }

          // Build once for every target, no matter how many repeats.
          try {
            await builder(target, device);
          } catch (_) {
            targetRuns.add(TargetRunStatus.failedToBuild);
            continue;
          }

          for (var i = 0; i < _repeats; i++) {
            if (_disposed) {
              targetRuns.add(TargetRunStatus.canceled);
              continue;
            }

            try {
              await executor(target, device);
            } catch (_) {
              targetRuns.add(TargetRunStatus.failedToExecute);
              continue;
            }

            targetRuns.add(TargetRunStatus.passed);
          }
        }
      }

      final future = runTestsOnDevice();
      testRunsOnAllDevices.add(future);
    }

    await Future.wait<void>(testRunsOnAllDevices);
    _running = false;

    return RunResults(targetRunResults: targetRunResults);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }

  @override
  void disposedBy(DisposeScope disposeScope) {
    disposeScope.addDispose(dispose);
  }
}
