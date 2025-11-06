import 'dart:collection';
import 'dart:io' as io;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:patrol/src/native/native_automator.dart' as native_automator;
import 'package:patrol/src/native/native_automator.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/platform_automator.dart';
import 'package:patrol_log/patrol_log.dart';

/// This class represents the result of [NativeAutomator.getNativeViews].
class GetNativeViewsResult {
  /// Creates a new [GetNativeViewsResult].
  const GetNativeViewsResult({
    required this.androidViews,
    required this.iosViews,
  });

  /// List of Android native views.
  final List<AndroidNativeView> androidViews;

  /// List of iOS native views.
  final List<IOSNativeView> iosViews;
}

/// This class aggregates native selectors.
class NativeSelector {
  /// Creates a new [NativeSelector]
  const NativeSelector({this.android, this.ios});

  /// Android selector.
  final AndroidSelector? android;

  /// iOS selector.
  final IOSSelector? ios;
}

/// Provides functionality to interact with the OS that the app under test is
/// running on.
///
/// Communicates over http with the native automation server running on the
/// target device.
@Deprecated(
  'NativeAutomator2 is deprecated and will be removed in a future release. '
  'Please use PlatformAutomator instead.',
)
class NativeAutomator2 {
  /// Creates a new [NativeAutomator2].
  @Deprecated(
    'NativeAutomator2 is deprecated and will be removed in a future release. '
    'Please use PlatformAutomator instead.',
  )
  NativeAutomator2({required PlatformAutomator platformAutomator})
    : _platform = platformAutomator;

  final PlatformAutomator _platform;

  /// Returns the platform-dependent unique identifier of the app under test.
  String get resolvedAppId => _platform.mobile.resolvedAppId;

  /// Presses the back button.
  ///
  /// This method throws on iOS, because there's no back button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressback>,
  ///    which is used on Android.
  Future<void> pressBack() =>
      _platform.action(android: _platform.android.pressBack);

  /// Presses the home button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/home>,
  ///   which is used on iOS
  Future<void> pressHome() => _platform.mobile.pressHome();

  /// Opens the app specified by [appId]. If [appId] is null, then the app under
  /// test is started (using [resolvedAppId]).
  ///
  /// On Android [appId] is the package name. On iOS [appId] is the bundle name.
  Future<void> openApp({String? appId}) =>
      _platform.mobile.openApp(appId: appId);

  /// Opens a platform-specific app.
  ///
  /// On Android, opens the app specified by [androidAppId] (package name).
  /// On iOS, opens the app specified by [iosAppId] (bundle identifier).
  ///
  /// You can pass a [GoogleApp] enum for common Android apps, an [AppleApp]
  /// enum for common iOS apps, or a custom app ID string.
  ///
  /// Example with enums:
  /// ```dart
  /// await $.native.openPlatformApp(
  ///   androidAppId: GoogleApp.chrome,
  ///   iosAppId: AppleApp.safari,
  /// );
  /// ```
  ///
  /// Example with custom app IDs:
  /// ```dart
  /// await $.native.openPlatformApp(
  ///   androidAppId: 'com.mycompany.myapp',
  ///   iosAppId: 'com.mycompany.myapp',
  /// );
  /// ```
  Future<void> openPlatformApp({Object? androidAppId, Object? iosAppId}) async {
    // Extract the actual app ID string from enum or string
    final androidId = switch (androidAppId) {
      final GoogleApp app => app.value,
      final String id => id,
      null => null,
      _ => throw ArgumentError(
        'androidAppId must be a GoogleApp enum or a String',
      ),
    };

    final iosId = switch (iosAppId) {
      final AppleApp app => app.value,
      final String id => id,
      null => null,
      _ => throw ArgumentError('iosAppId must be an AppleApp enum or a String'),
    };

    await _wrapRequest(
      'openPlatformApp',
      () => _client.openPlatformApp(
        OpenPlatformAppRequest(androidAppId: androidId, iosAppId: iosId),
      ),
    );
  }

  /// Presses the recent apps button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>,
  ///    which is used on Android
  Future<void> pressRecentApps() => _platform.mobile.pressRecentApps();

  /// Double presses the recent apps button.
  Future<void> pressDoubleRecentApps() =>
      _platform.action(android: _platform.android.pressDoubleRecentApps);

  /// Opens the notification shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  Future<void> openNotifications() => _platform.mobile.openNotifications();

  /// Closes the notification shade.
  ///
  /// It must be visible, otherwise the behavior is undefined.
  Future<void> closeNotifications() => _platform.mobile.closeNotifications();

  /// Opens the quick settings shade on Android and Control Center on iOS.
  ///
  /// Doesn't work on iOS Simulator because Control Center is not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#openquicksettings>,
  ///    which is used on Android
  Future<void> openQuickSettings() => _platform.mobile.openQuickSettings();

  /// Opens the URL specified by [url].
  Future<void> openUrl(String url) => _platform.mobile.openUrl(url);

  /// Returns the first, topmost visible notification.
  ///
  /// Notification shade has to be opened with [openNotifications].
  Future<Notification> getFirstNotification() =>
      _platform.mobile.getFirstNotification();

  /// Returns notifications that are visible in the notification shade.
  ///
  /// Notification shade has to be opened with [openNotifications].
  Future<List<Notification>> getNotifications() =>
      _platform.mobile.getNotifications();

  /// Closes the currently visible heads up notification (iOS only).
  ///
  /// If no heads up notification is visible, the behavior is undefined.
  Future<void> closeHeadsUpNotification() =>
      _platform.action(ios: _platform.ios.closeHeadsUpNotification);

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
  Future<void> tapOnNotificationByIndex(int index, {Duration? timeout}) =>
      _platform.mobile.tapOnNotificationByIndex(index, timeout: timeout);

  /// Taps on the visible notification using [selector].
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the [NativeAutomatorConfig.findTimeout] duration
  /// from the configuration.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// On iOS, only [IOSSelector.titleContains] is taken into account.
  ///
  /// See also:
  ///
  /// * [tapOnNotificationByIndex], which is less flexible but also less verbose
  Future<void> tapOnNotificationBySelector(
    NativeSelector selector, {
    Duration? timeout,
  }) => _platform.action(
    android: () => _platform.android.tapOnNotificationBySelector(
      _getSafeAndroidSelector(selector),
      timeout: timeout,
    ),
    ios: () => _platform.ios.tapOnNotificationBySelector(
      _getSafeIOSSelector(selector),
      timeout: timeout,
    ),
  );

  /// Press volume up
  ///
  /// Doesn't work on iOS Simulator because Volume buttons are not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressKeyCodes(int[])>,
  ///    which is used on Android
  Future<void> pressVolumeUp() => _platform.mobile.pressVolumeUp();

  /// Press volume down
  ///
  /// Doesn't work on iOS Simulator because Volume buttons are not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressKeyCodes(int[])>,
  ///    which is used on Android
  Future<void> pressVolumeDown() => _platform.mobile.pressVolumeDown();

  /// Enables dark mode.
  Future<void> enableDarkMode({String? appId}) =>
      _platform.mobile.enableDarkMode(appId: appId);

  /// Disables dark mode.
  Future<void> disableDarkMode({String? appId}) =>
      _platform.mobile.disableDarkMode(appId: appId);

  /// Enables airplane mode.
  Future<void> enableAirplaneMode() => _platform.mobile.enableAirplaneMode();

  /// Enables airplane mode.
  Future<void> disableAirplaneMode() => _platform.mobile.disableAirplaneMode();

  /// Enables cellular (aka mobile data connection).
  Future<void> enableCellular() => _platform.mobile.enableCellular();

  /// Disables cellular (aka mobile data connection).
  Future<void> disableCellular() => _platform.mobile.disableCellular();

  /// Enables Wi-Fi.
  Future<void> enableWifi() => _platform.mobile.enableWifi();

  /// Disables Wi-Fi.
  Future<void> disableWifi() => _platform.mobile.disableWifi();

  /// Enables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  Future<void> enableBluetooth() => _platform.mobile.enableBluetooth();

  /// Disables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  Future<void> disableBluetooth() => _platform.mobile.disableBluetooth();

  /// Enables location.
  ///
  /// On Android, opens the location settings screen and toggles the location
  /// switch to enable location.
  /// If the location already enabled, it does nothing.
  ///
  /// Doesn't work for iOS.
  Future<void> enableLocation() =>
      _platform.action(android: _platform.android.enableLocation);

  /// Disables location.
  ///
  /// On Android, opens the location settings screen and toggles the location
  /// switch to disable location.
  /// If the location already enabled, it does nothing.
  ///
  /// Doesn't work for iOS.
  Future<void> disableLocation() =>
      _platform.action(android: _platform.android.disableLocation);

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(
    NativeSelector selector, {
    String? appId,
    Duration? timeout,
  }) => _platform.action.mobile(
    android: () => _platform.android.tap(
      _getSafeAndroidSelector(selector),
      timeout: timeout,
    ),
    ios: () => _platform.ios.tap(
      _getSafeIOSSelector(selector),
      appId: appId,
      timeout: timeout,
    ),
  );

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
    NativeSelector selector, {
    String? appId,
    Duration? timeout,
    Duration? delayBetweenTaps,
  }) => _platform.action.mobile(
    android: () => _platform.android.doubleTap(
      _getSafeAndroidSelector(selector),
      timeout: timeout,
      delayBetweenTaps: delayBetweenTaps,
    ),
    ios: () => _platform.ios.doubleTap(
      _getSafeIOSSelector(selector),
      appId: appId,
      timeout: timeout,
    ),
  );

  /// Taps at a given [location].
  ///
  /// [location] must be in the inclusive 0-1 range.
  Future<void> tapAt(Offset location, {String? appId}) =>
      _platform.mobile.tapAt(location, appId: appId);

  /// Enters text to the native view specified by [selector].
  ///
  /// If the text field isn't immediately visible, this method waits for the
  /// view to become visible. It prioritizes the [timeout] duration provided
  /// in the method call. If [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// The native view specified by [selector] must be:
  ///  * EditText or AutoCompleteTextView on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterTextByIndex], which is less flexible but also less verbose
  Future<void> enterText(
    NativeSelector selector, {
    required String text,
    String? appId,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  }) => _platform.action.mobile(
    android: () => _platform.android.enterText(
      _getSafeAndroidSelector(selector),
      text: text,
      keyboardBehavior: keyboardBehavior,
      timeout: timeout,
      tapLocation: tapLocation,
    ),
    ios: () => _platform.ios.enterText(
      _getSafeIOSSelector(selector),
      text: text,
      keyboardBehavior: keyboardBehavior,
      timeout: timeout,
      tapLocation: tapLocation,
    ),
  );

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
    Offset? tapLocation,
  }) => _platform.mobile.enterTextByIndex(
    text,
    index: index,
    appId: appId,
    keyboardBehavior: keyboardBehavior,
    timeout: timeout,
    tapLocation: tapLocation,
  );

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
    bool enablePatrolLog = true,
  }) => _platform.action.mobile(
    android: () => _platform.android.swipe(
      from: from,
      to: to,
      steps: steps,
      enablePatrolLog: enablePatrolLog,
    ),
    ios: () => _platform.ios.swipe(
      from: from,
      to: to,
      appId: appId,
      enablePatrolLog: enablePatrolLog,
    ),
  );

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
  Future<void> swipeBack({double dy = 0.5, String? appId}) =>
      _platform.action.mobile(
        android: () => _platform.android.swipeBack(dy: dy),
        ios: () => _platform.ios.swipeBack(dy: dy, appId: appId),
      );

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
  }) => _platform.action.mobile(
    android: () =>
        _platform.android.pullToRefresh(from: from, to: to, steps: steps),
    ios: () => _platform.ios.pullToRefresh(from: from, to: to),
  );

  /// Waits until the native view specified by [selector] becomes visible.
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout].
  Future<void> waitUntilVisible(
    NativeSelector selector, {
    String? appId,
    Duration? timeout,
  }) => _platform.action.mobile(
    android: () => _platform.android.waitUntilVisible(
      _getSafeAndroidSelector(selector),
      timeout: timeout,
    ),
    ios: () => _platform.ios.waitUntilVisible(
      _getSafeIOSSelector(selector),
      appId: appId,
      timeout: timeout,
    ),
  );

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  ///
  /// If [selector] is null, returns the whole native UI tree.
  Future<GetNativeViewsResult> getNativeViews(
    NativeSelector selector, {
    String? appId,
  }) => _platform.action.mobile(
    android: () async => GetNativeViewsResult(
      androidViews: (await _platform.android.getNativeViews(
        _getSafeAndroidSelector(selector),
      )).roots,
      iosViews: [],
    ),
    ios: () async => GetNativeViewsResult(
      androidViews: [],
      iosViews: (await _platform.ios.getNativeViews(
        _getSafeIOSSelector(selector),
      )).roots,
    ),
  );

  /// Waits until a native permission request dialog becomes visible within
  /// [timeout].
  ///
  /// Returns true if the dialog became visible within timeout, false otherwise.
  Future<bool> isPermissionDialogVisible({
    Duration timeout = const Duration(seconds: 1),
  }) => _platform.mobile.isPermissionDialogVisible(timeout: timeout);

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
  Future<void> grantPermissionWhenInUse() =>
      _platform.mobile.grantPermissionWhenInUse();

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
  Future<void> grantPermissionOnlyThisTime() =>
      _platform.mobile.grantPermissionOnlyThisTime();

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
  Future<void> denyPermission() => _platform.mobile.denyPermission();

  /// Select the "coarse location" (aka "approximate") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws if no permission request dialog is present.
  Future<void> selectCoarseLocation() =>
      _platform.mobile.selectCoarseLocation();

  /// Select the "fine location" (aka "precise") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws if no permission request dialog is present.
  Future<void> selectFineLocation() => _platform.mobile.selectFineLocation();

  /// Set mock location
  ///
  /// Works on Android emulator, iOS simulator and iOS real device. Doesn't
  /// work on Android real device.
  Future<void> setMockLocation(
    double latitude,
    double longitude, {
    String? packageName,
  }) => _platform.mobile.setMockLocation(
    latitude,
    longitude,
    packageName: packageName,
  );

  /// Take and confirm the photo
  ///
  /// This method taps on the camera shutter button to take a photo, then taps
  /// on the confirmation button to accept it.
  ///
  /// You can provide custom selectors for both the shutter and confirmation buttons
  /// using [shutterButtonSelector] and [doneButtonSelector] parameters.
  /// If no custom selectors are provided, default selectors will be used.
  ///
  /// For different camera apps or device manufacturers, you may need to provide
  /// custom selectors with the appropriate resource identifiers for your specific app.
  Future<void> takeCameraPhoto({
    NativeSelector? shutterButtonSelector,
    NativeSelector? doneButtonSelector,
    Duration? timeout,
  }) => _platform.action.mobile(
    android: () => _platform.android.takeCameraPhoto(
      shutterButtonSelector: shutterButtonSelector?.android,
      doneButtonSelector: doneButtonSelector?.android,
      timeout: timeout,
    ),
    ios: () => _platform.ios.takeCameraPhoto(
      shutterButtonSelector: shutterButtonSelector?.ios,
      doneButtonSelector: doneButtonSelector?.ios,
      timeout: timeout,
    ),
  );

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
    NativeSelector? imageSelector,
    int? index,
    Duration? timeout,
  }) => _platform.action.mobile(
    android: () => _platform.android.pickImageFromGallery(
      imageSelector: imageSelector?.android,
      index: index,
      timeout: timeout,
    ),
    ios: () => _platform.ios.pickImageFromGallery(
      imageSelector: imageSelector?.ios,
      index: index,
      timeout: timeout,
    ),
  );

  /// Pick multiple images from the gallery
  ///
  /// This method opens the gallery and selects multiple images based on [imageIndexes].
  ///
  /// You can provide a custom selector for the images using [imageSelector].
  /// If no custom selector is provided, default selectors will be used.
  /// The method will automatically handle the selection confirmation process.
  Future<void> pickMultipleImagesFromGallery({
    required List<int> imageIndexes,
    NativeSelector? imageSelector,
    Duration? timeout,
  }) => _platform.action.mobile(
    android: () => _platform.android.pickMultipleImagesFromGallery(
      imageIndexes: imageIndexes,
      imageSelector: imageSelector?.android,
      timeout: timeout,
    ),
    ios: () => _platform.ios.pickMultipleImagesFromGallery(
      imageIndexes: imageIndexes,
      imageSelector: imageSelector?.ios,
      timeout: timeout,
    ),
  );

  /// Checks if the app is running on a virtual device (simulator or emulator).
  ///
  /// Returns `true` if running on iOS simulator or Android emulator, `false` otherwise.
  /// On Android devices this method cannot be 100% accurate.
  ///
  /// This can be useful for conditional logic in tests that need to behave
  /// differently on physical devices vs simulators/emulators.
  Future<bool> isVirtualDevice() => _platform.mobile.isVirtualDevice();

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
  Future<int> getOsVersion() => _platform.mobile.getOsVersion();

  AndroidSelector _getSafeAndroidSelector(NativeSelector selector) {
    if (selector.android == null) {
      throw ArgumentError(
        'AndroidSelector cannot be null when calling native2 action on Android',
      );
    }
    return selector.android!;
  }

  IOSSelector _getSafeIOSSelector(NativeSelector selector) {
    if (selector.ios == null) {
      throw ArgumentError(
        'IOSSelector cannot be null when calling native2 action on iOS',
      );
    }
    return selector.ios!;
  }
}
