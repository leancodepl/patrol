import 'package:patrol_cli/src/features/drive/device.dart';

typedef Test = Future<void> Function(Device device);

/// Orchestrates running tests on devices.
class TestRunner {
  final List<Device> _devices = [];
  final List<Test> _tests = [];
  bool _running = false;

  void addDevice(Device device) {
    if (_running) {
      throw StateError('devices can only be added before run');
    }
    _devices.add(device);
  }

  void addTest(Test test) {
    if (_running) {
      throw StateError('tests can only be added before run');
    }
    _tests.add(test);
  }

  /// Runs all tests on all added devices.
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
    if (_tests.isEmpty) {
      throw StateError('no tests to run');
    }

    _running = true;

    final testRunsOnAllDevices = <Future<void>>[];
    for (final device in _devices) {
      Future<void> runTestsOnDevice() async {
        for (final test in _tests) {
          await test(device);
        }
      }

      testRunsOnAllDevices.add(runTestsOnDevice());
    }

    await Future.wait<void>(testRunsOnAllDevices);
    _running = false;
  }
}
