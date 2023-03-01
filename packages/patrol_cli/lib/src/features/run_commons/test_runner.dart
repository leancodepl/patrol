import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/features/devices/device.dart';
import 'package:patrol_cli/src/features/run_commons/result.dart';

typedef TestRunCallback = Future<void> Function(String target, Device device);

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
abstract class TestRunner implements Disposable {
  /// Sets the numbes of times each test target should be repeated.
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
