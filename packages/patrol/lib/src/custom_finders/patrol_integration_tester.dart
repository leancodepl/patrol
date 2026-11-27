import 'package:patrol/src/platform/platform_automator.dart';
import 'package:patrol_finders/patrol_finders.dart' as finders;
import 'package:patrol_log/patrol_log.dart';

/// PatrolIntegrationTester extends the capabilities of [finders.PatrolTester]
/// with the ability to interact with native platform features via [platform].
class PatrolIntegrationTester extends finders.PatrolTester {
  /// Creates a new [PatrolIntegrationTester] which wraps [tester].
  PatrolIntegrationTester({
    required super.tester,
    required super.config,
    required this.platformAutomator,
    List<String> entrypointArgs = const [],
  }) : entrypointArgs = List.unmodifiable(entrypointArgs),
       _patrolLog = PatrolLogWriter();

  /// The log for the patrol.
  final PatrolLogWriter _patrolLog;

  /// Platform automator that allows for interaction with the platform.
  ///
  final PlatformAutomator platformAutomator;

  /// Dart entrypoint arguments passed by the native side of the app
  /// (`dartEntrypointArgs` on Android, `entrypointArgs` on iOS and macOS).
  /// Empty if none were passed.
  final List<String> entrypointArgs;

  /// Shorthand for [platformAutomator].
  PlatformAutomator get platform => platformAutomator;

  /// Logs a message to the patrol log.
  void log(String message) {
    _patrolLog.log(LogEntry(message: message));
  }

  /// Captures a native screenshot ([tag] is added to the file name) for a device
  /// farm to collect. Android and web only (a no-op elsewhere); never throws.
  Future<void> takeNativeScreenshot(String tag) async {
    try {
      await platformAutomator.takeNativeScreenshot(tag);
    } catch (err) {
      _patrolLog.log(
        LogEntry(message: 'takeNativeScreenshot("$tag") failed: $err'),
      );
    }
  }
}
