import 'package:patrol_cli/src/features/drive/device.dart';

typedef TestRunCallback = Future<void> Function(String target, Device device);

/// Orchestrates running tests on devices.
class TestRunner {
  final Map<String, Device> _devices = {};
  final List<String> _targets = [];
  //final List<Test> _tests = [];
  bool _running = false;

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
    _targets.add(target);
  }

  /// Runs all test targets on on all added devices.
  ///
  /// Tests are run sequentially on a single device, but many devices can be
  /// attached at the same time, and thus many tests can be running at the same
  /// time.
  Future<void> run(TestRunCallback cb) async {
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
        for (final test in _targets) {
          await cb(test, device);
        }
      }

      testRunsOnAllDevices.add(runTestsOnDevice());
    }

    await Future.wait<void>(testRunsOnAllDevices);
    _running = false;
  }
}
