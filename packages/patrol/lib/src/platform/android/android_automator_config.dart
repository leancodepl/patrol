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
    bool? dontSuppressAccessibilityServices,
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
       keyboardBehavior = keyboardBehavior ?? KeyboardBehavior.showAndDismiss,
       dontSuppressAccessibilityServices =
           dontSuppressAccessibilityServices ??
           const bool.fromEnvironment(
             'PATROL_ANDROID_DONT_SUPPRESS_ACCESSIBILITY_SERVICES',
             defaultValue: true,
           );

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

  /// Whether other third-party `AccessibilityService`s (screen readers,
  /// accessibility-based tools) keep running while the test session is active.
  ///
  /// When `true` (the default) Patrol acquires `UiAutomation` with
  /// `FLAG_DONT_SUPPRESS_ACCESSIBILITY_SERVICES`; when `false` the platform
  /// suppresses them for the whole session. Can also be set with the
  /// `PATROL_ANDROID_DONT_SUPPRESS_ACCESSIBILITY_SERVICES` dart-define.
  ///
  /// See https://github.com/leancodepl/patrol/issues/3201.
  final bool dontSuppressAccessibilityServices;

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
    bool? dontSuppressAccessibilityServices,
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
      dontSuppressAccessibilityServices:
          dontSuppressAccessibilityServices ??
          this.dontSuppressAccessibilityServices,
      logger: logger ?? this.logger,
    );
  }
}
