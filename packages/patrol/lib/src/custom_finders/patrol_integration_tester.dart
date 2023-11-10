import 'package:patrol/src/native/native_automator.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;

/// PatrolIntegrationTester extends the capabilities of [finders.PatrolTester]
/// with the ability to interact with native platform features via [native].
class PatrolIntegrationTester extends finders.PatrolTester {
  /// Creates a new [PatrolIntegrationTester] which wraps [tester].
  const PatrolIntegrationTester({
    required super.tester,
    required super.config,
    required this.nativeAutomator,
  });

  /// Native automator that allows for interaction with OS the app is running
  /// on.
  ///
  final NativeAutomator nativeAutomator;

  /// Shorthand for [nativeAutomator].
  NativeAutomator get native => nativeAutomator;
}
