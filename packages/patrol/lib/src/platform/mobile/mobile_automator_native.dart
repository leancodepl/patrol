import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:patrol/patrol.dart' show PatrolActionException;
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/contracts/mobile_automator_client.dart';
import 'package:patrol/src/platform/mobile/mobile_automator.dart';
import 'package:patrol/src/platform/mobile/mobile_automator_config.dart';
import 'package:patrol_log/patrol_log.dart';

/// Provides functionality to interact with the OS that the app under test is
/// running on.
///
/// Communicates over http with the native automation server running on the
/// target device.
abstract class NativeMobileAutomator implements MobileAutomator {
  /// Creates a new [NativeMobileAutomator].
  NativeMobileAutomator({required MobileAutomatorConfig config})
    : assert(
        config.connectionTimeout > config.findTimeout,
        'find timeout is longer than connection timeout',
      ),
      _config = config {
    _client = MobileAutomatorClient(
      http.Client(),
      Uri.http('${_config.host}:${_config.port}'),
      timeout: _config.connectionTimeout,
    );
    _config.logger('MobileAutomatorClient created, port: ${_config.port}');
  }

  final _patrolLog = PatrolLogWriter();
  final MobileAutomatorConfig _config;

  late final MobileAutomatorClient _client;

  @protected
  /// Wraps a request with logging and error handling for native automator calls.
  ///
  /// Logs the start, success, and failure of the [name]d request. Catches known
  /// client exceptions and rethrows them as [PatrolActionException], while also
  /// logging the failure. Optionally logs to PatrolLog when [enablePatrolLog] is true.
  Future<T> wrapRequest<T>(
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
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.success),
        );
      }
      return result;
    } on MobileAutomatorClientException catch (err) {
      _config.logger('$name() failed');
      final log =
          'MobileAutomatorClientException: '
          '$name() failed with $err';

      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.failure),
        );
      }
      throw PatrolActionException(log);
    } catch (err) {
      _config.logger('$name() failed');

      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.failure),
        );
      }
      rethrow;
    }
  }

  /// Configures the native automator.
  ///
  /// Must be called before using any native features.
  @override
  Future<void> configure() async {
    const retries = 60;

    PatrolActionException? exception;
    for (var i = 0; i < retries; i++) {
      try {
        await wrapRequest(
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

  /// Presses the home button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/home>,
  ///   which is used on iOS
  @override
  Future<void> pressHome() async {
    await wrapRequest('pressHome', _client.pressHome);
  }

  /// Opens the app specified by [appId]. If [appId] is null, then the app under
  /// test is started (using [resolvedAppId]).
  ///
  /// On Android [appId] is the package name. On iOS [appId] is the bundle name.
  @override
  Future<void> openApp({String? appId}) async {
    await wrapRequest(
      'openApp',
      () => _client.openApp(OpenAppRequest(appId: appId ?? resolvedAppId)),
    );
  }

  /// Presses the recent apps button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>,
  ///    which is used on Android
  @override
  Future<void> pressRecentApps() async {
    await wrapRequest('pressRecentApps', _client.pressRecentApps);
  }

  /// Opens the notification shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  @override
  Future<void> openNotifications() async {
    await wrapRequest('openNotifications', _client.openNotifications);
  }

  /// Closes the notification shade.
  ///
  /// It must be visible, otherwise the behavior is undefined.
  @override
  Future<void> closeNotifications() async {
    await wrapRequest('closeNotifications', _client.closeNotifications);
  }

  /// Opens the quick settings shade on Android and Control Center on iOS.
  ///
  /// Doesn't work on iOS Simulator because Control Center is not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#openquicksettings>,
  ///    which is used on Android
  @override
  Future<void> openQuickSettings() async {
    await wrapRequest(
      'openQuickSettings',
      () => _client.openQuickSettings(OpenQuickSettingsRequest()),
    );
  }

  /// Opens the URL specified by [url].
  @override
  Future<void> openUrl(String url) async {
    await wrapRequest(
      'openUrl',
      () => _client.openUrl(OpenUrlRequest(url: url)),
    );
  }

  /// Returns the first, topmost visible notification.
  ///
  /// Notification shade has to be opened with [openNotifications].
  @override
  Future<Notification> getFirstNotification() async {
    final response = await wrapRequest(
      'getFirstNotification',
      () => _client.getNotifications(GetNotificationsRequest()),
    );

    return response.notifications.first;
  }

  /// Returns notifications that are visible in the notification shade.
  ///
  /// Notification shade has to be opened with [openNotifications].
  @override
  Future<List<Notification>> getNotifications() async {
    final response = await wrapRequest(
      'getNotifications',
      () => _client.getNotifications(GetNotificationsRequest()),
    );

    return response.notifications;
  }

  /// Press volume up
  ///
  /// Doesn't work on iOS Simulator because Volume buttons are not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressKeyCodes(int[])>,
  ///    which is used on Android
  @override
  Future<void> pressVolumeUp() async {
    await wrapRequest('pressVolumeUp', _client.pressVolumeUp);
  }

  /// Press volume down
  ///
  /// Doesn't work on iOS Simulator because Volume buttons are not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressKeyCodes(int[])>,
  ///    which is used on Android
  @override
  Future<void> pressVolumeDown() async {
    await wrapRequest('pressVolumeDown', _client.pressVolumeDown);
  }

  /// Enables dark mode.
  @override
  Future<void> enableDarkMode({String? appId}) async {
    await wrapRequest(
      'enableDarkMode',
      () => _client.enableDarkMode(
        DarkModeRequest(appId: appId ?? resolvedAppId),
      ),
    );
  }

  /// Disables dark mode.
  @override
  Future<void> disableDarkMode({String? appId}) async {
    await wrapRequest(
      'disableDarkMode',
      () => _client.disableDarkMode(
        DarkModeRequest(appId: appId ?? resolvedAppId),
      ),
    );
  }

  /// Enables airplane mode.
  @override
  Future<void> enableAirplaneMode() async {
    await wrapRequest('enableAirplaneMode', _client.enableAirplaneMode);
  }

  /// Enables airplane mode.
  @override
  Future<void> disableAirplaneMode() async {
    await wrapRequest('disableAirplaneMode', _client.disableAirplaneMode);
  }

  /// Enables cellular (aka mobile data connection).
  @override
  Future<void> enableCellular() async {
    await wrapRequest('enableCellular', _client.enableCellular);
  }

  /// Disables cellular (aka mobile data connection).
  @override
  Future<void> disableCellular() {
    return wrapRequest('disableCellular', _client.disableCellular);
  }

  /// Enables Wi-Fi.
  @override
  Future<void> enableWifi() async {
    await wrapRequest('enableWifi', _client.enableWiFi);
  }

  /// Disables Wi-Fi.
  @override
  Future<void> disableWifi() async {
    await wrapRequest('disableWifi', _client.disableWiFi);
  }

  /// Enables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  @override
  Future<void> enableBluetooth() async {
    await wrapRequest('enableBluetooth', _client.enableBluetooth);
  }

  /// Disables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  @override
  Future<void> disableBluetooth() async {
    await wrapRequest('disableBluetooth', _client.disableBluetooth);
  }

  /// Waits until a native permission request dialog becomes visible within
  /// [timeout].
  ///
  /// Returns true if the dialog became visible within timeout, false otherwise.
  @override
  Future<bool> isPermissionDialogVisible({
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final response = await wrapRequest(
      'isPermissionDialogVisible',
      () => _client.isPermissionDialogVisible(
        PermissionDialogVisibleRequest(timeoutMillis: timeout.inMilliseconds),
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
  @override
  Future<void> grantPermissionWhenInUse() async {
    await wrapRequest(
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
  @override
  Future<void> grantPermissionOnlyThisTime() async {
    await wrapRequest(
      'grantPermissionOnlyThisTime',
      () => _client.handlePermissionDialog(
        HandlePermissionRequest(code: HandlePermissionRequestCode.onlyThisTime),
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
  @override
  Future<void> denyPermission() async {
    await wrapRequest(
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
  @override
  Future<void> selectCoarseLocation() async {
    await wrapRequest(
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
  @override
  Future<void> selectFineLocation() async {
    await wrapRequest(
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
  @override
  Future<void> setMockLocation(
    double latitude,
    double longitude, {
    String? packageName,
  }) async {
    await wrapRequest(
      'setMockLocation latitude: $latitude, longitude: $longitude',
      () => _client.setMockLocation(
        SetMockLocationRequest(
          latitude: latitude,
          longitude: longitude,
          packageName: packageName ?? resolvedAppId,
        ),
      ),
    );
  }

  /// Tells the AndroidJUnitRunner that PatrolAppService is ready to answer
  /// requests about the structure of Dart tests.
  @override
  @internal
  Future<void> markPatrolAppServiceReady() async {
    await wrapRequest(
      'markPatrolAppServiceReady',
      _client.markPatrolAppServiceReady,
      enablePatrolLog: false,
    );
  }

  /// Checks if the app is running on a virtual device (simulator or emulator).
  ///
  /// Returns `true` if running on iOS simulator or Android emulator, `false` otherwise.
  /// On Android devices this method cannot be 100% accurate.
  ///
  /// This can be useful for conditional logic in tests that need to behave
  /// differently on physical devices vs simulators/emulators.
  @override
  Future<bool> isVirtualDevice() async {
    final response = await wrapRequest(
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
  @override
  Future<int> getOsVersion() async {
    final response = await wrapRequest(
      'getOsVersion',
      () => _client.getOsVersion(),
    );

    return response.osVersion;
  }
}
