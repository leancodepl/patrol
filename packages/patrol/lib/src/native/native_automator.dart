import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:patrol/src/native/contracts/contracts.dart' as contracts;
import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/contracts/native_automator_client.dart';
import 'package:patrol_log/patrol_log.dart';

/// Thrown when a native action fails.
class PatrolActionException implements Exception {
  /// Creates a new [PatrolActionException].
  PatrolActionException(this.message);

  /// Message that the native part returned.
  String message;

  @override
  String toString() => 'Patrol action failed: $message';
}

/// Specifies how the OS keyboard should behave when using
/// [NativeAutomator.enterText] and [NativeAutomator.enterTextByIndex].
enum KeyboardBehavior {
  /// The default keyboard behavior.
  ///
  /// Keyboard will be shown when entering text starts, and will be
  /// automatically dismissed afterwards.
  showAndDismiss,

  /// The alternative keyboard behavior.
  ///
  /// On Android, no keyboard will be shown at all. The text will simply appear
  /// inside the TextField.
  ///
  /// On iOS, the keyboard will not be dismissed after entering text.
  alternative,
}

extension on KeyboardBehavior {
  contracts.KeyboardBehavior get toContractsEnum {
    switch (this) {
      case KeyboardBehavior.showAndDismiss:
        return contracts.KeyboardBehavior.showAndDismiss;
      case KeyboardBehavior.alternative:
        return contracts.KeyboardBehavior.alternative;
    }
  }
}

void _defaultPrintLogger(String message) {
  // TODO: Use a logger instead of print
  // ignore: avoid_print
  print('Patrol (native): $message');
}

/// Configuration for [NativeAutomator].
class NativeAutomatorConfig {
  /// Creates a new [NativeAutomatorConfig].
  const NativeAutomatorConfig({
    this.host = const String.fromEnvironment(
      'PATROL_HOST',
      defaultValue: 'localhost',
    ),
    this.port = const String.fromEnvironment(
      'PATROL_TEST_SERVER_PORT',
      defaultValue: '8081',
    ),
    this.packageName = const String.fromEnvironment('PATROL_APP_PACKAGE_NAME'),
    this.iosInstalledApps =
        const String.fromEnvironment('PATROL_IOS_INSTALLED_APPS'),
    this.bundleId = const String.fromEnvironment('PATROL_APP_BUNDLE_ID'),
    this.androidAppName =
        const String.fromEnvironment('PATROL_ANDROID_APP_NAME'),
    this.iosAppName = const String.fromEnvironment('PATROL_IOS_APP_NAME'),
    this.connectionTimeout = const Duration(seconds: 60),
    this.findTimeout = const Duration(seconds: 10),
    this.keyboardBehavior = KeyboardBehavior.showAndDismiss,
    this.logger = _defaultPrintLogger,
  });

  /// Apps installed on the iOS simulator.
  ///
  /// This is needed for purpose of native view inspection in the Patrol
  /// DevTools extension.
  final String iosInstalledApps;

  /// Host on which Patrol server instrumentation is running.
  final String host;

  /// Port on [host] on which Patrol server instrumentation is running.
  final String port;

  /// Time after which the connection with the native automator will fail.
  ///
  /// It must be longer than [findTimeout].
  final Duration connectionTimeout;

  /// Time to wait for native views to appear.
  final Duration findTimeout;

  /// How the keyboard should behave when entering text.
  ///
  /// See [KeyboardBehavior] to learn more.
  final KeyboardBehavior keyboardBehavior;

  /// Package name of the application under test.
  ///
  /// Android only.
  final String packageName;

  /// Bundle identifier name of the application under test.
  ///
  /// iOS only.
  final String bundleId;

  /// Name of the application under test on Android.
  final String androidAppName;

  /// Name of the application under test on iOS.
  final String iosAppName;

  /// Name of the application under test.
  ///
  /// Returns [androidAppName] on Android and [iosAppName] on iOS.
  String get appName {
    if (io.Platform.isAndroid) {
      return androidAppName;
    } else if (io.Platform.isIOS) {
      return iosAppName;
    } else {
      throw StateError('Unsupported platform');
    }
  }

  /// Called when a native action is performed.
  final void Function(String) logger;

  /// Creates a copy of this config but with the given fields replaced with the
  /// new values.
  NativeAutomatorConfig copyWith({
    String? host,
    String? port,
    String? packageName,
    String? bundleId,
    String? androidAppName,
    String? iosAppName,
    Duration? connectionTimeout,
    Duration? findTimeout,
    KeyboardBehavior? keyboardBehavior,
    void Function(String)? logger,
  }) {
    return NativeAutomatorConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      packageName: packageName ?? this.packageName,
      bundleId: bundleId ?? this.bundleId,
      androidAppName: androidAppName ?? this.androidAppName,
      iosAppName: iosAppName ?? this.iosAppName,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      findTimeout: findTimeout ?? this.findTimeout,
      keyboardBehavior: keyboardBehavior ?? this.keyboardBehavior,
      logger: logger ?? this.logger,
    );
  }
}

/// Provides functionality to interact with the OS that the app under test is
/// running on.
///
/// Communicates over http with the native automation server running on the
/// target device.
// TODO: Rename to NativeAutomatorClient
class NativeAutomator {
  /// Creates a new [NativeAutomator].
  NativeAutomator({required NativeAutomatorConfig config})
      : assert(
          config.connectionTimeout > config.findTimeout,
          'find timeout is longer than connection timeout',
        ),
        _config = config {
    if (_config.packageName.isEmpty && io.Platform.isAndroid) {
      _config.logger("packageName is not set. It's recommended to set it.");
    }
    if (_config.bundleId.isEmpty && io.Platform.isIOS) {
      _config.logger("bundleId is not set. It's recommended to set it.");
    }

    // _config.logger('Android app name: ${_config.androidAppName}');
    // _config.logger('iOS app name: ${_config.iosAppName}');
    // _config.logger('Android package name: ${_config.packageName}');
    // _config.logger('iOS bundle identifier: ${_config.bundleId}');

    _client = NativeAutomatorClient(
      http.Client(),
      Uri.http('${_config.host}:${_config.port}'),
      timeout: _config.connectionTimeout,
    );
    _config.logger('NativeAutomatorClient created, port: ${_config.port}');
  }

  final PatrolLogWriter _patrolLog = PatrolLogWriter();
  final NativeAutomatorConfig _config;

  late final NativeAutomatorClient _client;

  /// Returns the platform-dependent unique identifier of the app under test.
  String get resolvedAppId {
    if (io.Platform.isAndroid) {
      return _config.packageName;
    } else if (io.Platform.isIOS) {
      return _config.bundleId;
    }

    throw StateError('unsupported platform');
  }

  Future<T> _wrapRequest<T>(
    String name,
    Future<T> Function() request, {
    bool enablePatrolLog = true,
  }) async {
    _config.logger('$name() started');
    final text =
        '${AnsiCodes.lightBlue}$name${AnsiCodes.reset} ${AnsiCodes.gray}(native)${AnsiCodes.reset}';

    if (enablePatrolLog) {
      _patrolLog.log(StepEntry(action: text, status: StepEntryStatus.start));
    }
    try {
      final result = await request();
      _config.logger('$name() succeeded');
      if (enablePatrolLog) {
        _patrolLog
            .log(StepEntry(action: text, status: StepEntryStatus.success));
      }
      return result;
    } on NativeAutomatorClientException catch (err) {
      _config.logger('$name() failed');
      final log = 'NativeAutomatorClientException: '
          '$name() failed with $err';

      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(
            action: text,
            status: StepEntryStatus.failure,
          ),
        );
      }
      throw PatrolActionException(log);
    } catch (err) {
      _config.logger('$name() failed');

      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(
            action: text,
            status: StepEntryStatus.failure,
          ),
        );
      }
      rethrow;
    }
  }

  /// Initializes the native automator.
  ///
  /// It's used to initialize `android.app.UiAutomation` before Flutter tests
  /// start running. It's idempotent.
  ///
  /// It's a no-op on iOS.
  ///
  /// See also:
  ///  * https://github.com/flutter/flutter/issues/129231
  Future<void> initialize() async {
    await _wrapRequest(
      'initialize',
      _client.initialize,
      enablePatrolLog: false,
    );
  }

  /// Configures the native automator.
  ///
  /// Must be called before using any native features.
  Future<void> configure() async {
    const retries = 60;

    PatrolActionException? exception;
    for (var i = 0; i < retries; i++) {
      try {
        await _wrapRequest(
          'configure',
          () => _client.configure(
            ConfigureRequest(
              findTimeoutMillis: _config.findTimeout.inMilliseconds,
            ),
          ),
          enablePatrolLog: false,
        );
        exception = null;
        break;
      } on PatrolActionException catch (err) {
        _config.logger('configure() failed: (${err.message})');
        exception = err;
      }

      _config.logger('trying to configure() again in 1 second');
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    if (exception != null) {
      throw PatrolActionException(
        'configure() failed after $retries retries (${exception.message}',
      );
    }
  }

  /// Presses the back button.
  ///
  /// This method throws on iOS, because there's no back button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressback>,
  ///    which is used on Android.
  Future<void> pressBack() async {
    await _wrapRequest('pressBack', _client.pressBack);
  }

  /// Presses the home button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/home>,
  ///   which is used on iOS
  Future<void> pressHome() async {
    await _wrapRequest('pressHome', _client.pressHome);
  }

  /// Opens the app specified by [appId]. If [appId] is null, then the app under
  /// test is started (using [resolvedAppId]).
  ///
  /// On Android [appId] is the package name. On iOS [appId] is the bundle name.
  Future<void> openApp({String? appId}) async {
    await _wrapRequest(
      'openApp',
      () => _client.openApp(OpenAppRequest(appId: appId ?? resolvedAppId)),
    );
  }

  /// Presses the recent apps button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>,
  ///    which is used on Android
  Future<void> pressRecentApps() async {
    await _wrapRequest('pressRecentApps', _client.pressRecentApps);
  }

  /// Double presses the recent apps button.
  Future<void> pressDoubleRecentApps() async {
    await _wrapRequest('pressDoubleRecentApps', _client.doublePressRecentApps);
  }

  /// Opens the notification shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  Future<void> openNotifications() async {
    await _wrapRequest('openNotifications', _client.openNotifications);
  }

  /// Closes the notification shade.
  ///
  /// It must be visible, otherwise the behavior is undefined.
  Future<void> closeNotifications() async {
    await _wrapRequest('closeNotifications', _client.closeNotifications);
  }

  /// Opens the quick settings shade on Android and Control Center on iOS.
  ///
  /// Doesn't work on iOS Simulator because Control Center is not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#openquicksettings>,
  ///    which is used on Android
  Future<void> openQuickSettings() async {
    await _wrapRequest(
      'openQuickSettings',
      () => _client.openQuickSettings(OpenQuickSettingsRequest()),
    );
  }

  /// Opens the URL specified by [url].
  Future<void> openUrl(String url) async {
    await _wrapRequest(
      'openUrl',
      () => _client.openUrl(OpenUrlRequest(url: url)),
    );
  }

  /// Returns the first, topmost visible notification.
  ///
  /// Notification shade has to be opened with [openNotifications].
  Future<Notification> getFirstNotification() async {
    final response = await _wrapRequest(
      'getFirstNotification',
      () => _client.getNotifications(
        GetNotificationsRequest(),
      ),
    );

    return response.notifications.first;
  }

  /// Returns notifications that are visible in the notification shade.
  ///
  /// Notification shade has to be opened with [openNotifications].
  Future<List<Notification>> getNotifications() async {
    final response = await _wrapRequest(
      'getNotifications',
      () => _client.getNotifications(
        GetNotificationsRequest(),
      ),
    );

    return response.notifications;
  }

  /// Closes the currently visible heads up notification (iOS only).
  ///
  /// If no heads up notification is visible, the behavior is undefined.
  Future<void> closeHeadsUpNotification() async {
    await _wrapRequest(
      'closeHeadsUpNotification',
      _client.closeHeadsUpNotification,
    );
  }

  /// Searches for the [index]-th visible notification and taps on it.
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the [NativeAutomatorConfig.findTimeout] duration
  /// from the configuration.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// See also:
  ///
  ///  * [tapOnNotificationBySelector], which allows for more precise
  ///    specification of the notification to tap on
  Future<void> tapOnNotificationByIndex(
    int index, {
    Duration? timeout,
  }) async {
    await _wrapRequest(
      'tapOnNotificationByIndex',
      () => _client.tapOnNotification(
        TapOnNotificationRequest(
          index: index,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Taps on the visible notification using [selector].
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the [NativeAutomatorConfig.findTimeout] duration
  /// from the configuration.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// On iOS, only [Selector.textContains] is taken into account.
  ///
  /// See also:
  ///
  /// * [tapOnNotificationByIndex], which is less flexible but also less verbose
  Future<void> tapOnNotificationBySelector(
    Selector selector, {
    Duration? timeout,
  }) async {
    await _wrapRequest(
      'tapOnNotificationBySelector',
      () => _client.tapOnNotification(
        TapOnNotificationRequest(
          selector: selector,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Press volume up
  ///
  /// Doesn't work on iOS Simulator because Volume buttons are not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressKeyCodes(int[])>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/volumeup>,
  ///   which is used on iOS
  Future<void> pressVolumeUp() async {
    await _wrapRequest('pressVolumeUp', _client.pressVolumeUp);
  }

  /// Press volume down
  ///
  /// Doesn't work on iOS Simulator because Volume buttons are not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressKeyCodes(int[])>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/volumedown>,
  ///   which is used on iOS
  Future<void> pressVolumeDown() async {
    await _wrapRequest('pressVolumeDown', _client.pressVolumeDown);
  }

  /// Enables dark mode.
  Future<void> enableDarkMode({String? appId}) async {
    await _wrapRequest(
      'enableDarkMode',
      () => _client.enableDarkMode(
        DarkModeRequest(appId: appId ?? resolvedAppId),
      ),
    );
  }

  /// Disables dark mode.
  Future<void> disableDarkMode({String? appId}) async {
    await _wrapRequest(
      'disableDarkMode',
      () => _client.disableDarkMode(
        DarkModeRequest(appId: appId ?? resolvedAppId),
      ),
    );
  }

  /// Enables airplane mode.
  Future<void> enableAirplaneMode() async {
    await _wrapRequest('enableAirplaneMode', _client.enableAirplaneMode);
  }

  /// Enables airplane mode.
  Future<void> disableAirplaneMode() async {
    await _wrapRequest('disableAirplaneMode', _client.disableAirplaneMode);
  }

  /// Enables cellular (aka mobile data connection).
  Future<void> enableCellular() async {
    await _wrapRequest('enableCellular', _client.enableCellular);
  }

  /// Disables cellular (aka mobile data connection).
  Future<void> disableCellular() {
    return _wrapRequest('disableCellular', _client.disableCellular);
  }

  /// Enables Wi-Fi.
  Future<void> enableWifi() async {
    await _wrapRequest('enableWifi', _client.enableWiFi);
  }

  /// Disables Wi-Fi.
  Future<void> disableWifi() async {
    await _wrapRequest('disableWifi', _client.disableWiFi);
  }

  /// Enables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  Future<void> enableBluetooth() async {
    await _wrapRequest('enableBluetooth', _client.enableBluetooth);
  }

  /// Disables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  Future<void> disableBluetooth() async {
    await _wrapRequest('disableBluetooth', _client.disableBluetooth);
  }

  /// Enables location.
  ///
  /// On Android, opens the location settings screen and toggles the location
  /// switch to enable location.
  /// If the location already enabled, it does nothing.
  ///
  /// Doesn't work for iOS.
  Future<void> enableLocation() async {
    await _wrapRequest('enableLocation', _client.enableLocation);
  }

  /// Disables location.
  ///
  /// On Android, opens the location settings screen and toggles the location
  /// switch to disable location.
  /// If the location already enabled, it does nothing.
  ///
  /// Doesn't work for iOS.
  Future<void> disableLocation() async {
    await _wrapRequest('disableLocation', _client.disableLocation);
  }

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(
    Selector selector, {
    String? appId,
    Duration? timeout,
  }) async {
    await _wrapRequest('tap', () async {
      await _client.tap(
        TapRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      );
    });
  }

  /// Double taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  ///
  /// The [delayBetweenTaps] parameter allows you to specify the duration
  /// between consecutive taps in milliseconds. This can be useful in scenarios
  /// where the target view requires a certain delay between taps to register
  /// the action correctly, such as in cases of UI responsiveness or animations.
  /// The default delay between taps is 300 milliseconds.
  ///
  /// Note: The [delayBetweenTaps] parameter is currently respected only
  /// for Android.
  Future<void> doubleTap(
    Selector selector, {
    String? appId,
    Duration? timeout,
    Duration? delayBetweenTaps,
  }) async {
    await _wrapRequest(
      'doubleTap',
      () => _client.doubleTap(
        TapRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          timeoutMillis: timeout?.inMilliseconds,
          delayBetweenTapsMillis: delayBetweenTaps?.inMilliseconds,
        ),
      ),
    );
  }

  /// Taps at a given [location].
  ///
  /// [location] must be in the inclusive 0-1 range.
  Future<void> tapAt(Offset location, {String? appId}) async {
    assert(location.dx >= 0 && location.dx <= 1);
    assert(location.dy >= 0 && location.dy <= 1);

    // Needed for an edge case observed on Android where if a newly opened app
    // updates its layout right after being launched, tapping without delay fails
    await Future<void>.delayed(const Duration(milliseconds: 5));

    await _wrapRequest('tapAt', () async {
      await _client.tapAt(
        TapAtRequest(
          x: location.dx,
          y: location.dy,
          appId: appId ?? resolvedAppId,
        ),
      );
    });
  }

  /// Enters text to the native view specified by [selector].
  ///
  /// If the text field isn't immediately visible, this method waits for the
  /// view to become visible. It prioritizes the [timeout] duration provided
  /// in the method call. If [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// The native view specified by [selector] must be:
  ///  * EditText on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterTextByIndex], which is less flexible but also less verbose
  Future<void> enterText(
    Selector selector, {
    required String text,
    String? appId,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset tapLocation = const Offset(0.9, 0.9),
  }) async {
    assert(tapLocation.dx >= 0.0 && tapLocation.dx <= 1.0);
    assert(tapLocation.dy >= 0.0 && tapLocation.dy <= 1.0);

    await _wrapRequest(
      'enterText',
      () => _client.enterText(
        EnterTextRequest(
          data: text,
          appId: appId ?? resolvedAppId,
          selector: selector,
          keyboardBehavior:
              (keyboardBehavior ?? _config.keyboardBehavior).toContractsEnum,
          timeoutMillis: timeout?.inMilliseconds,
          dx: tapLocation.dx,
          dy: tapLocation.dy,
        ),
      ),
    );
  }

  /// Enters text to the [index]-th visible text field.
  ///
  /// If the text field at [index] isn't visible immediately, this method waits
  /// for the view to become visible. It prioritizes the [timeout] duration
  /// provided in the method call. If [timeout] is not specified, it utilizes
  /// the [NativeAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// Native views considered to be texts fields are:
  ///  * EditText on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterText], which allows for more precise specification of the text
  ///    field to enter text into
  Future<void> enterTextByIndex(
    String text, {
    required int index,
    String? appId,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset tapLocation = const Offset(0.9, 0.9),
  }) async {
    assert(tapLocation.dx >= 0.0 && tapLocation.dx <= 1.0);
    assert(tapLocation.dy >= 0.0 && tapLocation.dy <= 1.0);

    await _wrapRequest(
      'enterTextByIndex',
      () => _client.enterText(
        EnterTextRequest(
          data: text,
          appId: appId ?? resolvedAppId,
          index: index,
          keyboardBehavior:
              (keyboardBehavior ?? _config.keyboardBehavior).toContractsEnum,
          timeoutMillis: timeout?.inMilliseconds,
          dx: tapLocation.dx,
          dy: tapLocation.dy,
        ),
      ),
    );
  }

  /// Swipes from [from] to [to].
  ///
  /// [from] and [to] must be in the inclusive 0-1 range.
  ///
  /// On Android, [steps] controls speed and smoothness. One unit of [steps] is
  /// equivalent to 5 ms. If you want to slow down the swipe time, increase
  /// [steps]. If [swipe] doesn't work, try increasing [steps].
  Future<void> swipe({
    required Offset from,
    required Offset to,
    int steps = 12,
    String? appId,
  }) async {
    assert(from.dx >= 0 && from.dx <= 1);
    assert(from.dy >= 0 && from.dy <= 1);
    assert(to.dx >= 0 && to.dx <= 1);
    assert(to.dy >= 0 && to.dy <= 1);

    await _wrapRequest(
      'swipe',
      () => _client.swipe(
        SwipeRequest(
          startX: from.dx,
          startY: from.dy,
          endX: to.dx,
          endY: to.dy,
          steps: steps,
          appId: appId ?? resolvedAppId,
        ),
      ),
    );
  }

  /// Mimics the swipe back (left to right) gesture.
  ///
  /// [dy] determines the vertical offset of the swipe. It must be in the inclusive 0-1 range.
  ///
  /// [appId] optionally specifies the application ID to target.
  ///
  /// This is equivalent to:
  /// $.native.swipe(
  ///    from: Offset(0, dy),
  ///    to: Offset(1, dy),
  ///    appId: appId,
  ///  );
  ///
  /// On Android, navigation with gestures might have to be turned on in devices settings.
  ///
  /// Example usage:
  /// ```dart
  /// await tester.swipeBack(dy: 0.8); // Swipe back at 1/5 height of the screen
  /// await tester.swipeBack(); // Swipe back at the center of the screen
  /// ```
  Future<void> swipeBack({double dy = 0.5, String? appId}) {
    assert(dy >= 0.0 && dy <= 1.0, 'dy must be between 0.0 and 1.0');
    return swipe(from: Offset(0, dy), to: Offset(1, dy), appId: appId);
  }

  /// Simulates pull-to-refresh gesture.
  ///
  /// It swipes from [from] to [to] with the specified number of [steps].
  ///
  /// [from] and [to] must be in the inclusive 0-1 range.
  ///
  /// [steps] controls the speed and smoothness of the swipe. More steps equals
  /// slower gesture.
  ///
  /// The default values simulate a typical pull-to-refresh gesture:
  /// * [from]: Center of the screen (0.5, 0.5)
  /// * [to]: Bottom center of the screen (0.5, 0.9)
  /// * [steps]: 50
  /// You can override these if scrollable content is not at the center of the
  /// screen or if the direction of the gesture is different.
  Future<void> pullToRefresh({
    Offset from = const Offset(0.5, 0.5),
    Offset to = const Offset(0.5, 0.9),
    int steps = 50,
  }) async {
    assert(from.dx >= 0 && from.dx <= 1);
    assert(from.dy >= 0 && from.dy <= 1);
    assert(to.dx >= 0 && to.dx <= 1);
    assert(to.dy >= 0 && to.dy <= 1);

    return swipe(
      from: Offset(from.dx, from.dy),
      to: Offset(to.dx, to.dy),
      steps: steps,
    );
  }

  /// Waits until the native view specified by [selector] becomes visible.
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout].
  Future<void> waitUntilVisible(
    Selector selector, {
    String? appId,
    Duration? timeout,
  }) async {
    await _wrapRequest(
      'waitUntilVisible',
      () => _client.waitUntilVisible(
        WaitUntilVisibleRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  ///
  /// If [selector] is null, returns the whole native UI tree.
  Future<List<NativeView>> getNativeViews(
    Selector? selector, {
    String? appId,
  }) async {
    if (selector == null) {
      final treeResponse = await _wrapRequest(
        'getNativeUITree',
        () => _client.getNativeUITree(
          GetNativeUITreeRequest(
            useNativeViewHierarchy: true,
          ),
        ),
      );
      return treeResponse.roots;
    }

    final response = await _wrapRequest(
      'getNativeViews',
      () => _client.getNativeViews(
        GetNativeViewsRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
        ),
      ),
    );

    return response.nativeViews;
  }

  /// Waits until a native permission request dialog becomes visible within
  /// [timeout].
  ///
  /// Returns true if the dialog became visible within timeout, false otherwise.
  Future<bool> isPermissionDialogVisible({
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final response = await _wrapRequest(
      'isPermissionDialogVisible',
      () => _client.isPermissionDialogVisible(
        PermissionDialogVisibleRequest(
          timeoutMillis: timeout.inMilliseconds,
        ),
      ),
    );

    return response.visible;
  }

  /// Grants the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws if no permission request dialog is present.
  ///
  /// See also:
  ///
  ///  * [grantPermissionOnlyThisTime] and [denyPermission]
  ///
  ///  * [isPermissionDialogVisible], which should guard calls to this method
  ///
  ///  * [selectFineLocation] and [selectCoarseLocation], which works only for
  ///    location permission request dialogs
  Future<void> grantPermissionWhenInUse() async {
    await _wrapRequest(
      'grantPermissionWhenInUse',
      () => _client.handlePermissionDialog(
        HandlePermissionRequest(code: HandlePermissionRequestCode.whileUsing),
      ),
    );
  }

  /// Grants the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws if no permission request dialog is present.
  ///
  /// On iOS, this is the same as [grantPermissionWhenInUse] except for the
  /// location permission.
  ///
  /// On Android versions older than 11 (R, API level 30), the concept of
  /// "one-time permissions" doesn't exist. In this case, this method is the
  /// same as [grantPermissionWhenInUse].
  ///
  /// See also:
  ///
  ///  * [grantPermissionWhenInUse] and [denyPermission]
  ///
  ///  * [isPermissionDialogVisible], which should guard calls to this method
  ///
  ///  * [selectFineLocation] and [selectCoarseLocation], which works only for
  ///    location permission request dialogs
  Future<void> grantPermissionOnlyThisTime() async {
    await _wrapRequest(
      'grantPermissionOnlyThisTime',
      () => _client.handlePermissionDialog(
        HandlePermissionRequest(
          code: HandlePermissionRequestCode.onlyThisTime,
        ),
      ),
    );
  }

  /// Denies the permission that the currently visible native permission request
  /// dialog is asking for.
  ///
  /// Throws if no permission request dialog is present.
  ///
  /// See also:
  ///
  ///  * [grantPermissionWhenInUse] and [grantPermissionOnlyThisTime]
  ///
  ///  * [isPermissionDialogVisible], which should guard calls to this method
  ///
  ///  * [selectFineLocation] and [selectCoarseLocation], which works only for
  ///    location permission request dialogs
  Future<void> denyPermission() async {
    await _wrapRequest(
      'denyPermission',
      () => _client.handlePermissionDialog(
        HandlePermissionRequest(code: HandlePermissionRequestCode.denied),
      ),
    );
  }

  /// Select the "coarse location" (aka "approximate") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws if no permission request dialog is present.
  Future<void> selectCoarseLocation() async {
    await _wrapRequest(
      'selectCoarseLocation',
      () => _client.setLocationAccuracy(
        SetLocationAccuracyRequest(
          locationAccuracy: SetLocationAccuracyRequestLocationAccuracy.coarse,
        ),
      ),
    );
  }

  /// Select the "fine location" (aka "precise") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws if no permission request dialog is present.
  Future<void> selectFineLocation() async {
    await _wrapRequest(
      'selectFineLocation',
      () => _client.setLocationAccuracy(
        SetLocationAccuracyRequest(
          locationAccuracy: SetLocationAccuracyRequestLocationAccuracy.fine,
        ),
      ),
    );
  }

  /// Set mock location
  ///
  /// Works on Android emulator, iOS simulator and iOS real device. Doesn't
  /// work on Android real device.
  Future<void> setMockLocation(
    double latitude,
    double longitude, {
    String? packageName,
  }) async {
    await _wrapRequest(
      'setMockLocation latitude: $latitude, longitude: $longitude',
      () => _client.setMockLocation(
        SetMockLocationRequest(
          latitude: latitude,
          longitude: longitude,
          packageName: packageName ?? _config.packageName,
        ),
      ),
    );
  }

  /// Tells the AndroidJUnitRunner that PatrolAppService is ready to answer
  /// requests about the structure of Dart tests.
  @internal
  Future<void> markPatrolAppServiceReady() async {
    await _wrapRequest(
      'markPatrolAppServiceReady',
      _client.markPatrolAppServiceReady,
      enablePatrolLog: false,
    );
  }

  /// Take and confirm the photo
  ///
  /// This method taps on the camera shutter button to take a photo, then taps
  /// on the confirmation button to accept it.
  ///
  /// You can provide custom selectors for both the shutter and confirmation buttons
  /// using [shutterButtonSelector] and [doneButtonSelector] parameters.
  /// If no custom selectors are provided, default selectors will be used.
  Future<void> takeCameraPhoto({
    Selector? shutterButtonSelector,
    Selector? doneButtonSelector,
    Duration? timeout,
  }) async {
    await _wrapRequest(
      'takeCameraPhoto',
      () async {
        await _client.takeCameraPhoto(
          TakeCameraPhotoRequest(
            shutterButtonSelector: shutterButtonSelector,
            doneButtonSelector: doneButtonSelector,
            appId: resolvedAppId,
            isNative2: false,
            timeoutMillis: timeout?.inMilliseconds,
          ),
        );
      },
    );
  }

  /// Pick an image from the gallery
  ///
  /// This method opens the gallery and selects a single image.
  ///
  /// You can provide a custom selector for the image using [imageSelector].
  /// If no custom selector is provided, default selectors will be used.
  /// Alternatively, you can specify an [index] to select the nth image
  /// when using default selectors.
  ///
  /// Note: If you provide [imageSelector], the [index] parameter will be overwritten.
  Future<void> pickImageFromGallery({
    Selector? imageSelector,
    int? index,
    Duration? timeout,
  }) async {
    await _wrapRequest(
      'pickImageFromGallery',
      () async {
        await _client.pickImageFromGallery(
          PickImageFromGalleryRequest(
            imageSelector: imageSelector,
            appId: resolvedAppId,
            isNative2: false,
            timeoutMillis: timeout?.inMilliseconds,
            imageIndex: index,
          ),
        );
      },
    );
  }

  /// Pick multiple images from the gallery
  ///
  /// This method opens the gallery and selects multiple images based on [imageIndexes].
  ///
  /// You can provide a custom selector for the images using [imageSelector].
  /// If no custom selector is provided, default selectors will be used.
  /// The method will automatically handle the selection confirmation process.
  Future<void> pickMultipleImagesFromGallery({
    required List<int> imageIndexes,
    Selector? imageSelector,
    Duration? timeout,
  }) async {
    await _wrapRequest(
      'pickMultipleImagesFromGallery',
      () async {
        await _client.pickMultipleImagesFromGallery(
          PickMultipleImagesFromGalleryRequest(
            imageSelector: imageSelector,
            appId: resolvedAppId,
            isNative2: false,
            imageIndexes: imageIndexes,
            timeoutMillis: timeout?.inMilliseconds,
          ),
        );
      },
    );
  }

  /// Checks if the app is running on a virtual device (simulator or emulator).
  ///
  /// Returns `true` if running on iOS simulator or Android emulator, `false` otherwise.
  /// On Android devices this method cannot be 100% accurate.
  ///
  /// This can be useful for conditional logic in tests that need to behave
  /// differently on physical devices vs simulators/emulators.
  Future<bool> isVirtualDevice() async {
    final response = await _wrapRequest(
      'isVirtualDevice',
      () => _client.isVirtualDevice(),
    );

    return response.isVirtualDevice;
  }

  /// Gets the OS version.
  ///
  /// Returns the OS version as an integer (e.g., 30 for Android 11).
  ///
  /// This can be useful for conditional logic in tests that need to behave
  /// differently based on the OS version.
  ///
  /// Example:
  /// ```dart
  /// final osVersion = await $.native.getOsVersion();
  /// if (osVersion >= 30) {
  ///   // Android 11+ specific behavior
  /// }
  /// ```
  Future<int> getOsVersion() async {
    final response = await _wrapRequest(
      'getOsVersion',
      () => _client.getOsVersion(),
    );

    return response.osVersion;
  }
}
