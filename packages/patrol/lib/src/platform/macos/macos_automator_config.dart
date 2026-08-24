import 'package:patrol/src/platform/ios/ios_automator_config.dart';
import 'package:patrol/src/platform/macos/macos_automator.dart';
import 'package:patrol/src/platform/mobile/mobile_automator_config.dart';

/// Configuration for [MacOSAutomator].
class MacOSAutomatorConfig extends MobileAutomatorConfig {
  /// Creates a new [MacOSAutomatorConfig].
  const MacOSAutomatorConfig({
    String? bundleId,
    String? appName,
    super.host,
    super.port,
    super.connectionTimeout,
    super.findTimeout,
    super.logger,
  }) : bundleId =
           bundleId ??
           const String.fromEnvironment('PATROL_MACOS_APP_BUNDLE_ID'),
       appName =
           appName ?? const String.fromEnvironment('PATROL_MACOS_APP_NAME');

  /// Creates a [MacOSAutomatorConfig] that talks to the same automation server
  /// as [ios].
  ///
  /// Used when callers enable native automation with only `iosConfig`, which is
  /// how macOS was configured before a dedicated macOS automator existed.
  ///
  /// [bundleId] and [appName] are deliberately not inherited: the CLI passes a
  /// separate bundle id for macOS, so they must resolve from the macOS
  /// dart-defines.
  factory MacOSAutomatorConfig.fromIOSTransport(IOSAutomatorConfig ios) {
    return MacOSAutomatorConfig(
      host: ios.host,
      port: ios.portOverride,
      connectionTimeout: ios.connectionTimeout,
      findTimeout: ios.findTimeout,
      logger: ios.logger,
    );
  }

  /// Bundle identifier of the application under test.
  final String bundleId;

  /// Name of the application under test on macOS.
  final String appName;

  /// Creates a copy of this config but with the given fields replaced with the
  /// new values.
  MacOSAutomatorConfig copyWith({
    String? host,
    String? port,
    String? bundleId,
    String? appName,
    Duration? connectionTimeout,
    Duration? findTimeout,
    void Function(String)? logger,
  }) {
    return MacOSAutomatorConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      bundleId: bundleId ?? this.bundleId,
      appName: appName ?? this.appName,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      findTimeout: findTimeout ?? this.findTimeout,
      logger: logger ?? this.logger,
    );
  }
}
