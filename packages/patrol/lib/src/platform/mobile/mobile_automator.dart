import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';

/// Provides functionality to interact with the OS that the app under test is
/// running on.
///
/// Communicates over http with the native automation server running on the
/// target device.
abstract interface class MobileAutomator {
  /// Returns the platform-dependent unique identifier of the app under test.
  String get resolvedAppId;

  /// Configures the native automator.
  ///
  /// Must be called before using any native features.
  Future<void> configure();

  /// Presses the home button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/home>,
  ///   which is used on iOS
  Future<void> pressHome();

  /// Opens the app specified by [appId]. If [appId] is null, then the app under
  /// test is started (using [resolvedAppId]).
  ///
  /// On Android [appId] is the package name. On iOS [appId] is the bundle name.
  Future<void> openApp({String? appId});

  /// Presses the recent apps button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>,
  ///    which is used on Android
  Future<void> pressRecentApps();

  /// Opens the notification shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  Future<void> openNotifications();

  /// Closes the notification shade.
  ///
  /// It must be visible, otherwise the behavior is undefined.
  Future<void> closeNotifications();

  /// Opens the quick settings shade on Android and Control Center on iOS.
  ///
  /// Doesn't work on iOS Simulator because Control Center is not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#openquicksettings>,
  ///    which is used on Android
  Future<void> openQuickSettings();

  /// Opens the URL specified by [url].
  Future<void> openUrl(String url);

  /// Returns the first, topmost visible notification.
  ///
  /// Notification shade has to be opened with [openNotifications].
  Future<Notification> getFirstNotification();

  /// Returns notifications that are visible in the notification shade.
  ///
  /// Notification shade has to be opened with [openNotifications].
  Future<List<Notification>> getNotifications();

  /// Press volume up
  ///
  /// Doesn't work on iOS Simulator because Volume buttons are not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressKeyCodes(int[])>,
  ///    which is used on Android
  Future<void> pressVolumeUp();

  /// Press volume down
  ///
  /// Doesn't work on iOS Simulator because Volume buttons are not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressKeyCodes(int[])>,
  ///    which is used on Android
  Future<void> pressVolumeDown();

  /// Enables dark mode.
  Future<void> enableDarkMode({String? appId});

  /// Disables dark mode.
  Future<void> disableDarkMode({String? appId});

  /// Enables airplane mode.
  Future<void> enableAirplaneMode();

  /// Enables airplane mode.
  Future<void> disableAirplaneMode();

  /// Enables cellular (aka mobile data connection).
  Future<void> enableCellular();

  /// Disables cellular (aka mobile data connection).
  Future<void> disableCellular();

  /// Enables Wi-Fi.
  Future<void> enableWifi();

  /// Disables Wi-Fi.
  Future<void> disableWifi();

  /// Enables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  Future<void> enableBluetooth();

  /// Disables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  Future<void> disableBluetooth();

  /// Waits until a native permission request dialog becomes visible within
  /// [timeout].
  ///
  /// Returns true if the dialog became visible within timeout, false otherwise.
  Future<bool> isPermissionDialogVisible({
    Duration timeout = const Duration(seconds: 1),
  });

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
  Future<void> grantPermissionWhenInUse();

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
  Future<void> grantPermissionOnlyThisTime();

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
  Future<void> denyPermission();

  /// Select the "coarse location" (aka "approximate") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws if no permission request dialog is present.
  Future<void> selectCoarseLocation();

  /// Select the "fine location" (aka "precise") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws if no permission request dialog is present.
  Future<void> selectFineLocation();

  /// Set mock location
  ///
  /// Works on Android emulator, iOS simulator and iOS real device. Doesn't
  /// work on Android real device.
  Future<void> setMockLocation(
    double latitude,
    double longitude, {
    String? packageName,
  });

  /// Tells the AndroidJUnitRunner that PatrolAppService is ready to answer
  /// requests about the structure of Dart tests.
  @internal
  Future<void> markPatrolAppServiceReady();

  /// Checks if the app is running on a virtual device (simulator or emulator).
  ///
  /// Returns `true` if running on iOS simulator or Android emulator, `false` otherwise.
  /// On Android devices this method cannot be 100% accurate.
  ///
  /// This can be useful for conditional logic in tests that need to behave
  /// differently on physical devices vs simulators/emulators.
  Future<bool> isVirtualDevice();

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
  Future<int> getOsVersion();
}
