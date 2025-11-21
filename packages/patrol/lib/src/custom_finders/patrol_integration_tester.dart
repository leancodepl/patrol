// The following ignore directive is here because 'NativeAutomator' and 'NativeAutomator2' are marked as deprecated.
// Its usage is necessary to provide backward compatibility for users relying on 'nativeAutomator'.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:patrol/src/native/native.dart';
import 'package:patrol/src/platform/platform_automator.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;
import 'package:patrol_log/patrol_log.dart';

/// PatrolIntegrationTester extends the capabilities of [finders.PatrolTester]
/// with the ability to interact with native platform features via [native].
class PatrolIntegrationTester extends finders.PatrolTester {
  /// Creates a new [PatrolIntegrationTester] which wraps [tester].
  PatrolIntegrationTester({
    required super.tester,
    required super.config,
    required this.platformAutomator,
  }) : _patrolLog = PatrolLogWriter() {
    nativeAutomator = NativeAutomator(platformAutomator: platformAutomator);
    nativeAutomator2 = NativeAutomator2(platformAutomator: platformAutomator);
  }

  /// The log for the patrol.
  final PatrolLogWriter _patrolLog;

  /// Platform automator that allows for interaction with the platform.
  ///
  final PlatformAutomator platformAutomator;

  /// Native automator that allows for interaction with OS the app is running
  /// on.
  ///
  @Deprecated(
    'Use platformAutomator instead. This will be removed in a future release.',
  )
  late final NativeAutomator nativeAutomator;

  /// Native automator with new Selector api that allows for interaction
  /// with OS the app is running on.
  ///
  @Deprecated(
    'Use platformAutomator instead. This will be removed in a future release.',
  )
  late final NativeAutomator2 nativeAutomator2;

  /// Shorthand for [platformAutomator].
  PlatformAutomator get platform => platformAutomator;

  /// Shorthand for [nativeAutomator].
  @Deprecated(
    'Use platformAutomator instead. '
    'This will be removed in a future release.',
  )
  NativeAutomator get native => nativeAutomator;

  /// Shorthand for [nativeAutomator2].
  @Deprecated(
    'Use platformAutomator instead. '
    'This will be removed in a future release.',
  )
  NativeAutomator2 get native2 => nativeAutomator2;

  /// Logs a message to the patrol log.
  void log(String message) {
    _patrolLog.log(LogEntry(message: message));
  }
}
