import 'package:patrol/src/native/native_automator.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;

/// This typedef help us to avoid breaking changes.
@Deprecated(
  '''
    PatrolTester will be accessible only in patrol_finders package.
    Use PatrolIntegrationTester in patrolTest callback
  ''',
)
typedef PatrolTester = PatrolIntegrationTester;

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
  /// TODO This field will not be nullable or will be removed
  final NativeAutomator? nativeAutomator;

  /// Shorthand for [nativeAutomator]. Throws if [nativeAutomator] is null,
  /// which is the case if it wasn't initialized.
  NativeAutomator get native {
    assert(
      nativeAutomator != null,
      'NativeAutomator is not initialized. Make sure you passed '
      "`nativeAutomation: true` to patrolTest(), and that you're *not* "
      'initializing any bindings in your test.',
    );
    return nativeAutomator!;
  }
}
