import 'dart:io';

/// Configuration for BrowserStack commands.
///
/// Configuration is loaded in order (later overrides earlier):
/// 1. Built-in defaults
/// 2. Environment variables (PATROL_BS_*)
/// 3. Command-line arguments
class BrowserStackConfig {
  BrowserStackConfig({
    String? credentials,
    String? androidDevices,
    String? iosDevices,
    String? androidApiParams,
    String? iosApiParams,
  }) : credentials =
           credentials ?? Platform.environment['PATROL_BS_CREDENTIALS'] ?? '',
       androidDevices =
           androidDevices ??
           Platform.environment['PATROL_BS_ANDROID_DEVICES'] ??
           defaultAndroidDevices,
       iosDevices =
           iosDevices ??
           Platform.environment['PATROL_BS_IOS_DEVICES'] ??
           defaultIosDevices,
       androidApiParams =
           androidApiParams ??
           Platform.environment['PATROL_BS_ANDROID_API_PARAMS'],
       iosApiParams =
           iosApiParams ?? Platform.environment['PATROL_BS_IOS_API_PARAMS'];

  /// Default Android devices for testing (any Pixel, latest OS).
  static const defaultAndroidDevices = '[{"device": "Google Pixel.*"}]';

  /// Default iOS devices for testing (any iPhone, latest OS).
  static const defaultIosDevices = '[{"device": "iPhone.*"}]';

  /// BrowserStack credentials (username:access_key).
  final String credentials;

  /// Android devices JSON array.
  final String androidDevices;

  /// iOS devices JSON array.
  final String iosDevices;

  /// Android API parameters (JSON).
  final String? androidApiParams;

  /// iOS API parameters (JSON).
  final String? iosApiParams;

  /// Validate that credentials are set.
  void requireCredentials() {
    if (credentials.isEmpty) {
      throw BrowserStackConfigException(
        'BrowserStack credentials not set.\n'
        'Set via: --credentials or PATROL_BS_CREDENTIALS env var',
      );
    }
  }
}

/// Exception thrown for configuration errors.
class BrowserStackConfigException implements Exception {
  BrowserStackConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
