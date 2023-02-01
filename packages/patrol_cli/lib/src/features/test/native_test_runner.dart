import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/run_commons/result.dart';
import 'package:patrol_cli/src/features/run_commons/test_runner.dart';

typedef _Callback = Future<void> Function(String target, Device device);

/// This class doesn't have a builder callback.
///
/// This means that it's not possible to split the build and run phases.
class NativeTestRunner extends TestRunner implements Disposable {
  final Map<String, Device> _devices = {};
  final Set<String> _targets = {};
  bool _running = false;
  bool _disposed = false;

  int _repeats = 1;
  @override
  set repeats(int newValue) {
    if (_running) {
      throw StateError('repeats cannot be changed while running');
    }

    _repeats = newValue;
  }

  _Callback? _executor;

  /// Sets the executor callback that can is called 1 or more times for every
  /// test target.
  ///
  /// Error reporting is the callback's responsibility.
  set executor(_Callback callback) => _executor = callback;

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
