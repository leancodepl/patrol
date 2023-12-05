import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:patrol/src/native/contracts/contracts.dart' as contracts;
import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/contracts/native_automator_client.dart';

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
      'PATROL_PORT',
      defaultValue: '8081',
    ),
    this.packageName = const String.fromEnvironment('PATROL_APP_PACKAGE_NAME'),
    this.iosInstalledApps = const String.fromEnvironment('PATROL_IOS_INSTALLED_APPS'),
    this.bundleId = const String.fromEnvironment('PATROL_APP_BUNDLE_ID'),
    this.androidAppName = const String.fromEnvironment('PATROL_ANDROID_APP_NAME'),
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
/// Communicates over gRPC with the native automation server running on the
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
  }

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

  Future<T> _wrapRequest<T>(String name, Future<T> Function() request) async {
    _config.logger('$name() started');
    try {
      final result = await request();
      _config.logger('$name() succeeded');
      return result;
    } on NativeAutomatorClientException catch (err) {
      _config.logger('$name() failed');
      final log = 'NativeAutomatorClientException: '
          '$name() failed with $err';
      throw PatrolActionException(log);
    } catch (err) {
      _config.logger('$name() failed');
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
    await _wrapRequest('initialize', _client.initialize);
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

  /// Taps on the [index]-th visible notification.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// See also:
  ///
  ///  * [tapOnNotificationBySelector], which allows for more precise
  ///    specification of the notification to tap on
  Future<void> tapOnNotificationByIndex(int index) async {
    await _wrapRequest(
      'tapOnNotificationByIndex',
      () => _client.tapOnNotification(TapOnNotificationRequest(index: index)),
    );
  }

  /// Taps on the visible notification using [selector].
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// On iOS, only [Selector.textContains] is taken into account.
  ///
  /// See also:
  ///
  /// * [tapOnNotificationByIndex], which is less flexible but also less verbose
  Future<void> tapOnNotificationBySelector(Selector selector) async {
    await _wrapRequest(
      'tapOnNotificationBySelector',
      () => _client.tapOnNotification(
        TapOnNotificationRequest(selector: selector),
      ),
    );
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
  Future<void> enableBluetooth() async {
    await _wrapRequest('enableBluetooth', _client.enableBluetooth);
  }

  /// Disables bluetooth.
  Future<void> disableBluetooth() async {
    await _wrapRequest('disableBluetooth', _client.disableBluetooth);
  }

  /// Taps on the native view specified by [selector].
  ///
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(Selector selector, {String? appId}) async {
    await _wrapRequest('tap', () async {
      await _client.tap(
        TapRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
        ),
      );
    });
  }

  /// Double taps on the native view specified by [selector].
  ///
  /// If the native view is not found, an exception is thrown.
  Future<void> doubleTap(Selector selector, {String? appId}) async {
    await _wrapRequest(
      'doubleTap',
      () => _client.doubleTap(
        TapRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
        ),
      ),
    );
  }

  /// Sends key pressed event to the native keyboard
  Future<void> sendKeyEvent(
    String keyEvent, {
    String? appId,
  }) async {
    await _wrapRequest(
      'sendKeyEvent',
      () => _client.sendKeyEvent(
        SendKeyEventRequest(
          data: keyEvent,
          appId: appId ?? resolvedAppId,
        ),
      ),
    );
  }

  /// Enters text to the native view specified by [selector].
  ///
  /// If the text field isn't visible immediately, this method waits for the
  /// view to become visible until [NativeAutomatorConfig.findTimeout] passes.
  /// If the text field isn't found within the timeout, an exception is thrown.
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
  }) async {
    await _wrapRequest(
      'enterText',
      () => _client.enterText(
        EnterTextRequest(
          data: text,
          appId: appId ?? resolvedAppId,
          selector: selector,
          keyboardBehavior: (keyboardBehavior ?? _config.keyboardBehavior).toContractsEnum,
        ),
      ),
    );
  }

  /// Enters text to the [index]-th visible text field.
  ///
  /// If the text field at [index] isn't visible immediately, this method waits
  /// for the view to become visible until [NativeAutomatorConfig.findTimeout]
  /// passes. If the text field isn't found within the timeout, an exception is
  /// thrown.
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
  }) async {
    await _wrapRequest(
      'enterTextByIndex',
      () => _client.enterText(
        EnterTextRequest(
          data: text,
          appId: appId ?? resolvedAppId,
          index: index,
          keyboardBehavior: (keyboardBehavior ?? _config.keyboardBehavior).toContractsEnum,
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

  /// Waits until the native view specified by [selector] becomes visible.
  Future<void> waitUntilVisible(Selector selector, {String? appId}) async {
    await _wrapRequest(
      'waitUntilVisible',
      () => _client.waitUntilVisible(
        WaitUntilVisibleRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
        ),
      ),
    );
  }

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  Future<List<NativeView>> getNativeViews(
    Selector selector, {
    String? appId,
  }) async {
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

  /// Tells the AndroidJUnitRunner that PatrolAppService is ready to answer
  /// requests about the structure of Dart tests.
  @internal
  Future<void> markPatrolAppServiceReady() async {
    await _wrapRequest(
      'markPatrolAppServiceReady',
      _client.markPatrolAppServiceReady,
    );
  }
}
