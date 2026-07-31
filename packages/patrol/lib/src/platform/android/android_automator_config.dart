import 'package:patrol/src/platform/android/android_automator.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/mobile/mobile_automator_config.dart';

/// Configuration for [AndroidAutomator].
class AndroidAutomatorConfig extends MobileAutomatorConfig {
  /// Creates a new [AndroidAutomatorConfig].
  const AndroidAutomatorConfig({
    String? packageName,
    String? appName,
    KeyboardBehavior? keyboardBehavior,
    super.host,
    super.port,
    super.connectionTimeout,
    super.findTimeout,
    super.logger,
  }) : packageName =
           packageName ??
           const String.fromEnvironment('PATROL_APP_PACKAGE_NAME'),
       appName =
           appName ?? const String.fromEnvironment('PATROL_ANDROID_APP_NAME'),
       keyboardBehavior = keyboardBehavior ?? KeyboardBehavior.showAndDismiss;

  /// How the keyboard should behave when entering text.
  ///
  /// See [KeyboardBehavior] to learn more.
  final KeyboardBehavior keyboardBehavior;

  /// Package name of the application under test.
  ///
  /// Android only.
  final String packageName;

  /// Name of the application under test on Android.
  final String appName;

  /// Creates a copy of this config but with the given fields replaced with the
  /// new values.
  AndroidAutomatorConfig copyWith({
    String? host,
    String? port,
    String? packageName,
    String? appName,
    Duration? connectionTimeout,
    Duration? findTimeout,
    KeyboardBehavior? keyboardBehavior,
    void Function(String)? logger,
  }) {
    return AndroidAutomatorConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      findTimeout: findTimeout ?? this.findTimeout,
      keyboardBehavior: keyboardBehavior ?? this.keyboardBehavior,
      logger: logger ?? this.logger,
    );
  }
}
