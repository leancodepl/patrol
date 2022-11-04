import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

typedef _Callback = Future<void> Function(String target, Device device);

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
  set repeats(int newValue) => _repeats = newValue;

  _Callback? _builder;
  set builder(_Callback newValue) => _builder = newValue;

  _Callback? _executor;
  set executor(_Callback newValue) => _executor = newValue;

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
  Future<void> run() async {
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

    final testRunsOnAllDevices = <Future<void>>[];
    for (final device in _devices.values) {
      Future<void> runTestsOnDevice() async {
        for (final target in _targets) {
          if (_disposed) {
            continue;
          }

          await builder(target, device);

          for (var i = 0; i < _repeats; i++) {
            if (_disposed) {
              continue;
            }

            await executor(target, device);
          }
        }
      }

      final future = runTestsOnDevice();
      testRunsOnAllDevices.add(future);
    }

    await Future.wait<void>(testRunsOnAllDevices);
    _running = false;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }
}
