import 'package:patrol/src/native/native_automator.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/platform_automator.dart';

/// Configuration for [NativeAutomator].
@Deprecated(
  'NativeAutomatorConfig is deprecated and left only for backwards compatibility of patrolTest.'
  ' Do not use it in new code.',
)
class NativeAutomatorConfig {
  /// Creates a new [NativeAutomatorConfig].
  @Deprecated(
    'NativeAutomatorConfig is deprecated and left only for backwards compatibility of patrolTest.'
    ' Do not use it in new code.',
  )
  NativeAutomatorConfig({
    String? host,
    String? port,
    this.packageName,
    this.iosInstalledApps,
    this.bundleId,
    this.androidAppName,
    this.iosAppName,
    this.connectionTimeout,
    this.findTimeout,
    this.keyboardBehavior,
    this.logger,
  }) {
    if (host != null) {
      throw StateError('host is not supported');
    }
    if (port != null) {
      throw StateError('port is not supported');
    }
  }

  /// Apps installed on the iOS simulator.
  ///
  /// This is needed for purpose of native view inspection in the Patrol
  /// DevTools extension.
  final String? iosInstalledApps;

  /// Time after which the connection with the native automator will fail.
  ///
  /// It must be longer than [findTimeout].
  final Duration? connectionTimeout;

  /// Time to wait for native views to appear.
  final Duration? findTimeout;

  /// How the keyboard should behave when entering text.
  ///
  /// See [KeyboardBehavior] to learn more.
  final KeyboardBehavior? keyboardBehavior;

  /// Package name of the application under test.
  ///
  /// Android only.
  final String? packageName;

  /// Bundle identifier name of the application under test.
  ///
  /// iOS only.
  final String? bundleId;

  /// Name of the application under test on Android.
  final String? androidAppName;

  /// Name of the application under test on iOS.
  final String? iosAppName;

  /// Called when a native action is performed.
  final void Function(String)? logger;

  /// Converts this configuration to a [PlatformAutomatorConfig].
  PlatformAutomatorConfig toPlatformAutomatorConfig() {
    return PlatformAutomatorConfig.fromOptions(
      iosInstalledApps: iosInstalledApps,
      connectionTimeout: connectionTimeout,
      findTimeout: findTimeout,
      keyboardBehavior: keyboardBehavior,
      packageName: packageName,
      bundleId: bundleId,
    );
  }
}
