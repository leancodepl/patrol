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
    bool? retrieveInteractiveWindows,
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
           ),
       retrieveInteractiveWindows =
           retrieveInteractiveWindows ??
           const bool.fromEnvironment(
             'PATROL_ANDROID_RETRIEVE_INTERACTIVE_WINDOWS',
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

  /// Whether Patrol should keep third-party `AccessibilityService`s running
  /// during the test session.
  ///
  /// By default Patrol acquires `UiAutomation` with `flags=0`, which makes the
  /// platform suppress every other `AccessibilityService` (screen readers,
  /// accessibility-based automation tools, …) for the whole session. Set this
  /// to `true` to acquire it with `FLAG_DONT_SUPPRESS_ACCESSIBILITY_SERVICES`
  /// instead, so those services keep running alongside Patrol.
  ///
  /// Defaults to `false` (today's behavior). Can also be set with the
  /// `PATROL_ANDROID_DONT_SUPPRESS_ACCESSIBILITY_SERVICES` dart-define.
  ///
  /// See https://github.com/leancodepl/patrol/issues/3201.
  final bool dontSuppressAccessibilityServices;

  /// Whether Patrol keeps `FLAG_RETRIEVE_INTERACTIVE_WINDOWS` on its
  /// `UiAutomation` accessibility service.
  ///
  /// uiautomator 2.3.0 force-enables this flag, which prevents some WebViews
  /// (e.g. the Plaid Link SDK) from ever populating their accessibility tree,
  /// so `$.native` selectors targeting text inside them fail. Set this to
  /// `false` to clear the flag and restore the pre-2.3.0 behavior.
  ///
  /// Defaults to `true` (today's behavior). Can also be set with the
  /// `PATROL_ANDROID_RETRIEVE_INTERACTIVE_WINDOWS` dart-define.
  ///
  /// See https://github.com/leancodepl/patrol/issues/3178.
  final bool retrieveInteractiveWindows;

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
    bool? retrieveInteractiveWindows,
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
      retrieveInteractiveWindows:
          retrieveInteractiveWindows ?? this.retrieveInteractiveWindows,
      logger: logger ?? this.logger,
    );
  }
}
