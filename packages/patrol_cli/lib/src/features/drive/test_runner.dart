import 'package:dispose_scope/dispose_scope.dart';
import 'package:logging/logging.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

typedef TestRunCallback = Future<void> Function(String target, Device device);

class _TestTarget {
  const _TestTarget(this.target, this.times, this.builder);

  final String target;
  final int times;
  final Future<void> Function() builder;

  @override
  bool operator ==(Object o) => o is _TestTarget && target == o.target;

  @override
  int get hashCode => target.hashCode;
}

/// Orchestrates running tests on devices.
///
/// It maps running T test targets on D devices, resulting in T * D test runs.
/// Every test target can also be repeated R times, resulting in T * R * D test
/// runs.
class TestRunner extends Disposable {
  TestRunner({required Logger logger}) : _logger = logger;

  final Map<String, Device> _devices = {};
  final Set<_TestTarget> _targets = {};
  bool _running = false;
  bool _disposed = false;

  final Logger _logger;

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
  ///
  /// [builder] will be called before running the tests.
  void addTarget(
    String target, {
    int times = 1,
    required Future<void> Function() builder,
  }) {
    final testTarget = _TestTarget(target, times, builder);

    if (_running) {
      throw StateError('tests can only be added before run');
    }

    if (times < 1) {
      throw StateError('times must be larger than 0');
    }

    if (_targets.contains(testTarget)) {
      throw StateError('target $target is already added');
    }

    _targets.add(testTarget);
  }

  /// Runs all test targets on on all added devices.
  ///
  /// Tests are run sequentially on a single device, but many devices can be
  /// attached at the same time, and thus many tests can be running at the same
  /// time.
  Future<void> run(TestRunCallback runTest) async {
    if (_running) {
      throw StateError('tests are already running');
    }
    if (_devices.isEmpty) {
      throw StateError('no devices to run tests on');
    }
    if (_targets.isEmpty) {
      throw StateError('no test targets to run');
    }

    _running = true;

    final testRunsOnAllDevices = <Future<void>>[];
    for (final device in _devices.values) {
      Future<void> runTestsOnDevice() async {
        for (final testTarget in _targets) {
          await testTarget.builder();

          for (var i = 0; i < testTarget.times; i++) {
            if (_disposed) {
              _logger.fine('Skipping running $testTarget on ${device.id}...');
              continue;
            }
          }

          await runTest(testTarget.target, device);
        }
      }

      final futures = runTestsOnDevice();
      testRunsOnAllDevices.add(futures);
    }

    await Future.wait<void>(testRunsOnAllDevices);
    _running = false;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }
}
