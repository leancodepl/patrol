import 'package:patrol/src/native/native_automator.dart';
import 'package:patrol/src/native/native_automator2.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;
import 'package:patrol_log/patrol_log.dart';

/// PatrolIntegrationTester extends the capabilities of [finders.PatrolTester]
/// with the ability to interact with native platform features via [native].
class PatrolIntegrationTester extends finders.PatrolTester {
  /// Creates a new [PatrolIntegrationTester] which wraps [tester].
  PatrolIntegrationTester({
    required super.tester,
    required super.config,
    required this.nativeAutomator,
    required this.nativeAutomator2,
    required PatrolLogWriter patrolLog,
  }) : _patrolLog = patrolLog;

  /// The log for the patrol.
  final PatrolLogWriter _patrolLog;

  /// Native automator that allows for interaction with OS the app is running
  /// on.
  ///
  final NativeAutomator nativeAutomator;

  /// Native automator with new Selector api that allows for interaction
  /// with OS the app is running on.
  ///
  final NativeAutomator2 nativeAutomator2;

  /// Shorthand for [nativeAutomator].
  NativeAutomator get native => nativeAutomator;

  /// Shorthand for [nativeAutomator2].
  NativeAutomator2 get native2 => nativeAutomator2;

  /// Logs a message to the patrol log.
  void log(String message) {
    _patrolLog.log(LogEntry(message: message));
  }
}
