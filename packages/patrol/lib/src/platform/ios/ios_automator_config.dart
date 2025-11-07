import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/ios/ios_automator.dart';
import 'package:patrol/src/platform/mobile/mobile_automator_config.dart';

/// Configuration for [IOSAutomator].
class IOSAutomatorConfig extends MobileAutomatorConfig {
  /// Creates a new [IOSAutomatorConfig].
  const IOSAutomatorConfig({
    this.iosInstalledApps = const String.fromEnvironment(
      'PATROL_IOS_INSTALLED_APPS',
    ),
    this.bundleId = const String.fromEnvironment('PATROL_APP_BUNDLE_ID'),
    this.appName = const String.fromEnvironment('PATROL_IOS_APP_NAME'),
    this.keyboardBehavior = KeyboardBehavior.showAndDismiss,
    super.host,
    super.port,
    super.connectionTimeout,
    super.findTimeout,
    super.logger,
  });

  /// Apps installed on the iOS simulator.
  ///
  /// This is needed for purpose of native view inspection in the Patrol
  /// DevTools extension.
  final String iosInstalledApps;

  /// How the keyboard should behave when entering text.
  ///
  /// See [KeyboardBehavior] to learn more.
  final KeyboardBehavior keyboardBehavior;

  /// Package name of the application under test.
  final String bundleId;

  /// Name of the application under test on Android.
  final String appName;

  /// Creates a copy of this config but with the given fields replaced with the
  /// new values.
  IOSAutomatorConfig copyWith({
    String? host,
    String? port,
    String? packageName,
    String? appName,
    Duration? connectionTimeout,
    Duration? findTimeout,
    KeyboardBehavior? keyboardBehavior,
    void Function(String)? logger,
  }) {
    return IOSAutomatorConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      appName: appName ?? this.appName,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      findTimeout: findTimeout ?? this.findTimeout,
      keyboardBehavior: keyboardBehavior ?? this.keyboardBehavior,
      logger: logger ?? this.logger,
    );
  }
}
