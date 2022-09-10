import 'package:maestro_cli/src/features/drive/device.dart';

typedef Test = Future<void> Function(Device device);

/// Orchestrates running tests on devices.
class TestRunner {
  final List<Device> _devices = [];
  final List<Test> _tests = [];
  bool _running = false;

  void addDevice(Device device) {
    assert(_running == false, 'devices can only be added before run');
    _devices.add(device);
  }

  void addTest(Test test) {
    assert(_running == false, 'tests can only be added before run');
    _tests.add(test);
  }

  Future<void> run() async {
    _running = true;

    final testRunsOnAllDevices = <Future>[];
    for (final device in _devices) {
      testRunsOnAllDevices.add(() async {
        for (final test in _tests) {
          await test(device);
        }
      }());
    }

    await Future.wait<void>(testRunsOnAllDevices);
    _running = false;
  }
}
