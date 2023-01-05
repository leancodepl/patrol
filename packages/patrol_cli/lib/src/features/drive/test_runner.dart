import 'package:dispose_scope/dispose_scope.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/features/run_commons/device.dart';

typedef _Callback = Future<void> Function(String target, Device device);

class TestRunnerResult with EquatableMixin {
  const TestRunnerResult({required this.targetRunResults});

  final List<TargetRunResult> targetRunResults;

  bool get allSuccessful => targetRunResults.every((e) => e.allRunsPassed);

  @override
  List<Object?> get props => [targetRunResults];
}

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

/// Orchestrates running tests on devices.
///
/// It maps running T test targets on D devices, resulting in T * D test runs.
/// Every test target can also be repeated R times, resulting in T * R * D test
/// runs.
///
/// Tests targets are run sequentially in the context of a single device.
class TestRunner extends Disposable {
  TestRunner();

  final Map<String, Device> _devices = {};
  final Set<String> _targets = {};
  bool _running = false;
  bool _disposed = false;

  int _repeats = 1;
  set repeats(int newValue) {
    if (_running) {
      throw StateError('repeats cannot be changed while running');
    }

    _repeats = newValue;
  }

  String? _useApplicationBinary;
  set useApplicationBinary(String? newValue) {
    if (_running) {
      throw StateError('application binary cannot be changed while running');
    }

    _useApplicationBinary = newValue;
  }

  _Callback? _builder;

  /// Sets the builder callback that is called once for every test target.
  ///
  /// The builder callback must build the artifacts necessary for the
  /// [_executor] callback to run a test, or throw if it's not possible to build
  /// the artifacts.
  ///
  /// Error reporting is the callback's responsibility.
  set builder(_Callback callback) => _builder = callback;

  _Callback? _executor;

  /// Sets the executor callback that can is called 1 or more times for every
  /// test target, except if the [_builder] callback threw, in which case the
  /// executor callback isn't called.
  ///
  /// Error reporting is the callback's responsibility.
  set executor(_Callback callback) => _executor = callback;

  /// Adds [device] to runner's internal list.
  void addDevice(Device device) {
    if (_running) {
      throw StateError('devices can only be added before run');
    }

    if (_devices[device.id] != null) {
      throw StateError('device with id ${device.id} is already added');
    }

    _devices[device.id] = device;
  }

  /// Adds [target] (a Dart test file) to runner's internal list.
  void addTarget(String target) {
    if (_running) {
      throw StateError('tests can only be added before run');
    }

    if (_targets.contains(target)) {
      throw StateError('target $target is already added');
    }

    _targets.add(target);
  }

  /// Runs all test targets on on all added devices.
  ///
  /// Tests are run sequentially on a single device, but many devices can be
  /// attached at the same time, and thus many tests can be running at the same
  /// time.
  Future<TestRunnerResult> run() async {
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

          if (_useApplicationBinary == null) {
            try {
              await builder(target, device);
            } catch (_) {
              targetRuns.add(TargetRunStatus.failedToBuild);
              continue;
            }
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

    return TestRunnerResult(targetRunResults: targetRunResults);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }
}
