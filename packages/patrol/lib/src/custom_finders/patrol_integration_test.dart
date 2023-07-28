import 'package:patrol/src/native/native_automator.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;

typedef PatrolTester = PatrolIntegrationTester;

class PatrolIntegrationTester extends finders.PatrolTester {
  /// Creates a new [PatrolIntegrationTester] which wraps [tester].
  const PatrolIntegrationTester({
    required super.tester,
    required super.config,
    required this.nativeAutomator,
  });

  /// Native automator that allows for interaction with OS the app is running
  /// on.
  /// TODO null 3.0
  final NativeAutomator? nativeAutomator;

  /// Shorthand for [nativeAutomator]. Throws if [nativeAutomator] is null,
  /// which is the case if it wasn't initialized.
  NativeAutomator get native {
    assert(nativeAutomator != null, 'TODO');
    return nativeAutomator!;
  }
}
