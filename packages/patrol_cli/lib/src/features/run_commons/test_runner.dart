import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/run_commons/result.dart';

/// Orchestrates running tests on devices.
///
/// It maps running T test targets on D devices, resulting in T * D test runs.
/// Every test target can also be repeated R times, resulting in T * R * D test
/// runs.
///
/// Tests targets are run sequentially in the context of a single device.
abstract class TestRunner {
  /// Sets the numbes of times each test target should be repeated.
  set repeats(int newValue);

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
