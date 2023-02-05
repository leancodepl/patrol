import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/run_commons/result.dart';
import 'package:patrol_cli/src/features/run_commons/test_runner.dart';

typedef _Callback = Future<void> Function(String target, Device device);

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

  _Callback? _builder;

  /// Sets the builder callback that is called once for every test target.
  ///
  /// The [callback] should:
  /// * call Gradle task `assembleAndroidTest` (when building for Android)
  /// * call `xcodebuild build-for-testing` (when building for iOS)
  ///
  /// The builder callback must build the artifacts necessary for the
  /// [_executor] callback to be able to run a test, or throw if it's not
  /// possible to build the artifacts.
  ///
  /// Error reporting is the callback's responsibility.
  set builder(_Callback callback) => _builder = callback;

  _Callback? _executor;

  /// Sets the executor callback that can is called 1 or more times for every
  /// test target, except if the [_builder] callback threw, in which case the
  /// executor callback isn't called.
  ///
  /// The callback should:
  /// * call Gradle task `connectedAndroidTest` (when running on Android)
  /// * call `xcodebuild test-without-building` (when running on iOS simulator)
  /// * call a combination of `ios-deploy` and `xcodebuild
  ///   test-without-building` (when running on iOS device)
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

  /// Runs all added test targets on on all added devices.
  ///
  /// Tests are run sequentially on a single device, but many devices can be
  /// attached at the same time, and thus many tests can be running at the same
  /// time.
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
