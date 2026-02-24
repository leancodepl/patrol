import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/android/android_automator.dart';
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/android/android_automator_empty.dart'
    as empty_android_automator;
import 'package:patrol/src/platform/android/android_automator_empty.dart'
    if (dart.library.io) 'package:patrol/src/platform/android/android_automator_native.dart'
    as native_android_automator;
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/current.dart' as current_platform;
import 'package:patrol/src/platform/ios/ios_automator.dart';
import 'package:patrol/src/platform/ios/ios_automator_config.dart';
import 'package:patrol/src/platform/ios/ios_automator_empty.dart'
    as empty_ios_automator;
import 'package:patrol/src/platform/ios/ios_automator_empty.dart'
    if (dart.library.io) 'package:patrol/src/platform/ios/ios_automator_native.dart'
    as native_ios_automator;
import 'package:patrol/src/platform/selector.dart';
import 'package:patrol/src/platform/web/web_automator.dart';
import 'package:patrol/src/platform/web/web_automator_config.dart';
import 'package:patrol/src/platform/web/web_automator_empty.dart'
    as empty_web_automator;
import 'package:patrol/src/platform/web/web_automator_empty.dart'
    if (dart.library.html) 'package:patrol/src/platform/web/web_automator_native.dart'
    as native_web_automator;

/// Configuration for [PlatformAutomator].
class PlatformAutomatorConfig {
  /// Creates a new [PlatformAutomatorConfig].
  PlatformAutomatorConfig({this.androidConfig, this.iosConfig, this.webConfig});

  /// Creates a new [PlatformAutomatorConfig] from individual options.
  factory PlatformAutomatorConfig.fromOptions({
    /// Apps installed on the iOS simulator.
    ///
    /// This is needed for purpose of native view inspection in the Patrol
    /// DevTools extension.
    String? iosInstalledApps,

    /// Time after which the connection with the native automator will fail.
    ///
    /// It must be longer than `findTimeout`.
    Duration? connectionTimeout,

    /// Time to wait for native views to appear.
    Duration? findTimeout,

    /// How the keyboard should behave when entering text.
    ///
    /// See [KeyboardBehavior] to learn more.
    KeyboardBehavior? keyboardBehavior,

    /// Package name of the application under test.
    ///
    /// Android only.
    String? packageName,

    /// Bundle identifier name of the application under test.
    ///
    /// iOS only.
    String? bundleId,

    /// Name of the application under test on Android.
    String? androidAppName,

    /// Name of the application under test on iOS.
    String? iosAppName,

    /// Called when a native action is performed.
    void Function(String)? logger,
  }) {
    return PlatformAutomatorConfig(
      androidConfig: AndroidAutomatorConfig(
        packageName: packageName,
        appName: androidAppName,
        keyboardBehavior: keyboardBehavior,
        connectionTimeout: connectionTimeout,
        findTimeout: findTimeout,
        logger: logger,
      ),
      iosConfig: IOSAutomatorConfig(
        iosInstalledApps: iosInstalledApps,
        bundleId: bundleId,
        appName: iosAppName,
        keyboardBehavior: keyboardBehavior,
        connectionTimeout: connectionTimeout,
        findTimeout: findTimeout,
        logger: logger,
      ),
      webConfig: WebAutomatorConfig(logger: logger),
    );
  }

  /// Creates a new [PlatformAutomatorConfig] suitable for test setup.
  factory PlatformAutomatorConfig.defaultConfig() {
    return PlatformAutomatorConfig(
      androidConfig: const AndroidAutomatorConfig(),
      iosConfig: const IOSAutomatorConfig(),
      webConfig: const WebAutomatorConfig(),
    );
  }

  /// Configuration for Android platform.
  final AndroidAutomatorConfig? androidConfig;

  /// Configuration for iOS platform.
  final IOSAutomatorConfig? iosConfig;

  /// Configuration for Web platform.
  final WebAutomatorConfig? webConfig;

  /// Whether Android platform is enabled.
  bool get androidEnabled => androidConfig != null;

  /// Whether iOS platform is enabled.
  bool get iosEnabled => iosConfig != null;

  /// Whether Web platform is enabled.
  bool get webEnabled => webConfig != null;
}

/// Provides functionality to interact with the OS that the app under test is
/// running on.
class PlatformAutomator {
  /// Creates a new [PlatformAutomator].
  PlatformAutomator({PlatformAutomatorConfig? config}) {
    final androidConfig =
        config?.androidConfig ?? const AndroidAutomatorConfig();
    final iosConfig = config?.iosConfig ?? const IOSAutomatorConfig();
    final webConfig = config?.webConfig ?? const WebAutomatorConfig();

    android = action.fallback(
      android: (config?.androidEnabled ?? false)
          ? () =>
                native_android_automator.AndroidAutomator(config: androidConfig)
          : null,
      fallback: () =>
          empty_android_automator.AndroidAutomator(config: androidConfig),
    );

    ios = action.fallback(
      ios: (config?.iosEnabled ?? false)
          ? () => native_ios_automator.IOSAutomator(config: iosConfig)
          : null,
      // TODO: Create MacOSAutomator when such class will be implemented
      // For now we reuse the IOSAutomator for native communication on MacOS
      // The reason is that the only native interaction on MacOS is marking the app service ready
      macos: (config?.iosEnabled ?? false)
          ? () => native_ios_automator.IOSAutomator(config: iosConfig)
          : null,
      fallback: () => empty_ios_automator.IOSAutomator(config: iosConfig),
    );

    web = action.fallback(
      web: (config?.webEnabled ?? false)
          ? () => native_web_automator.WebAutomator(config: webConfig)
          : null,
      fallback: () => empty_web_automator.WebAutomator(config: webConfig),
    );

    mobile = MobileAutomator(platform: this);
  }

  /// Android-specific automator.
  late final AndroidAutomator android;

  /// Web-specific automator.
  late final WebAutomator web;

  /// iOS-specific automator.
  late final IOSAutomator ios;

  /// Mobile automator that works on both Android and iOS.
  late final MobileAutomator mobile;

  /// Platform-specific action router.
  final action = PlatformAction();

  /// Initializes the native automator.
  Future<void> initialize() async {
    await action.maybe(android: android.initialize, web: web.initialize);
  }

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration.
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(
    CompoundSelector selector, {
    String? appId,
    Duration? timeout,
  }) {
    return action.safe(
      android: () => android.tap(selector.android, timeout: timeout),
      ios: () => ios.tap(selector.ios, appId: appId, timeout: timeout),
      web: () => web.tap(selector.web),
      macos: _throwOnMacOS,
    );
  }

  /// Tells the AndroidJUnitRunner that PatrolAppService is ready to answer
  /// requests about the structure of Dart tests.
  Future<void> markPatrolAppServiceReady() async {
    await action.maybe(
      android: () async => {await android.markPatrolAppServiceReady()},
      ios: () async => {await ios.markPatrolAppServiceReady()},
      // TODO: Use MacOSAutomator when such class will be implemented
      // For now we reuse the IOSAutomator for native communication on MacOS
      // The reason is that the only native interaction on MacOS is marking the app service ready
      macos: () async => {await ios.markPatrolAppServiceReady()},
    );
  }

  /// Inject an image for BrowserStack Camera Image Injection (iOS only).
  ///
  /// Stages [imageName] so that the next camera capture returns this image
  /// instead of real camera input. Call [MobileAutomator.takeCameraPhoto]
  /// after this to trigger the actual capture.
  ///
  /// This only works on iOS when running on BrowserStack with the
  /// appropriate capabilities enabled.
  Future<void> injectCameraPhoto({required String imageName}) {
    return ios.injectCameraPhoto(imageName: imageName);
  }

  /// None of the native actions are supported on MacOS, so we will just always throw.
  static T _throwOnMacOS<T>() {
    throw UnsupportedError('MacOS native actions are not supported');
  }
}

/// Mobile-specific automator that works across Android and iOS.
class MobileAutomator {
  /// Creates a new [MobileAutomator].
  MobileAutomator({required this.platform});

  /// The parent platform automator.
  final PlatformAutomator platform;

  /// Opens a platform-specific app.
  ///
  /// On Android, opens the app specified by [androidAppId] (package name).
  /// On iOS, opens the app specified by [iosAppId] (bundle identifier).
  Future<void> openPlatformApp({Object? androidAppId, Object? iosAppId}) {
    return platform.action.mobile(
      android: () {
        if (androidAppId == null) {
          throw ArgumentError(
            'androidAppId cannot be null when calling openPlatformApp action on Android',
          );
        }
        return platform.android.openPlatformApp(androidAppId: androidAppId);
      },
      ios: () {
        if (iosAppId == null) {
          throw ArgumentError(
            'iosAppId cannot be null when calling openPlatformApp action on IOS',
          );
        }
        return platform.ios.openPlatformApp(iosAppId: iosAppId);
      },
    );
  }

  /// Returns the platform-dependent unique identifier of the app under test.
  String get resolvedAppId {
    return platform.action.mobile(
      android: () => platform.android.resolvedAppId,
      ios: () => platform.ios.resolvedAppId,
    );
  }

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration.
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(CompoundSelector selector, {Duration? timeout}) {
    return platform.action.mobile(
      android: () => platform.android.tap(selector.android, timeout: timeout),
      ios: () => platform.ios.tap(selector.ios, timeout: timeout),
    );
  }

  /// Double taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration.
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
    CompoundSelector selector, {
    Duration? timeout,
    Duration? delayBetweenTaps,
    String? appId,
  }) {
    return platform.action.mobile(
      android: () => platform.android.doubleTap(
        selector.android,
        timeout: timeout,
        delayBetweenTaps: delayBetweenTaps,
      ),
      ios: () =>
          platform.ios.doubleTap(selector.ios, timeout: timeout, appId: appId),
    );
  }

  /// Taps at a given [location].
  ///
  /// [location] must be in the inclusive 0-1 range.
  Future<void> tapAt(Offset location, {String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.tapAt(location),
      ios: () => platform.ios.tapAt(location, appId: appId),
    );
  }

  /// Enters text to the native view specified by [selector].
  ///
  /// If the text field isn't immediately visible, this method waits for the
  /// view to become visible. It prioritizes the [timeout] duration provided
  /// in the method call.
  ///
  /// The native view specified by [selector] must be:
  ///  * EditText or AutoCompleteTextView on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterTextByIndex], which is less flexible but also less verbose
  Future<void> enterText(
    CompoundSelector selector, {
    required String text,
    String? appId,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  }) {
    return platform.action.mobile(
      android: () => platform.android.enterText(
        selector.android,
        text: text,
        keyboardBehavior: keyboardBehavior,
        timeout: timeout,
        tapLocation: tapLocation,
      ),
      ios: () => platform.ios.enterText(
        selector.ios,
        text: text,
        keyboardBehavior: keyboardBehavior,
        timeout: timeout,
        tapLocation: tapLocation,
      ),
    );
  }

  /// Enters text to the [index]-th visible text field.
  ///
  /// If the text field at [index] isn't visible immediately, this method waits
  /// for the view to become visible. It prioritizes the [timeout] duration
  /// provided in the method call.
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
  }) {
    return platform.action.mobile(
      android: () => platform.android.enterTextByIndex(
        text,
        index: index,
        keyboardBehavior: keyboardBehavior,
        timeout: timeout,
        tapLocation: tapLocation,
      ),
      ios: () => platform.ios.enterTextByIndex(
        text,
        index: index,
        keyboardBehavior: keyboardBehavior,
        timeout: timeout,
        tapLocation: tapLocation,
      ),
    );
  }

  /// Presses the home button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#presshome>,
  ///    which is used on Android
  ///
  /// * <https://developer.apple.com/documentation/xctest/xcuidevice/button/home>,
  ///   which is used on iOS
  Future<void> pressHome() {
    return platform.action.mobile(
      android: platform.android.pressHome,
      ios: platform.ios.pressHome,
    );
  }

  /// Opens the app specified by [appId]. If [appId] is null, then the app under
  /// test is started (using [resolvedAppId]).
  ///
  /// On Android [appId] is the package name. On iOS [appId] is the bundle name.
  Future<void> openApp({String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.openApp(appId: appId),
      ios: () => platform.ios.openApp(appId: appId),
    );
  }

  /// Presses the recent apps button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressrecentapps>,
  ///    which is used on Android
  Future<void> pressRecentApps() {
    return platform.action.mobile(
      android: platform.android.pressRecentApps,
      ios: platform.ios.pressRecentApps,
    );
  }

  /// Opens the notification shade.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#opennotification>,
  ///    which is used on Android
  Future<void> openNotifications() {
    return platform.action.mobile(
      android: platform.android.openNotifications,
      ios: platform.ios.openNotifications,
    );
  }

  /// Closes the notification shade.
  ///
  /// It must be visible, otherwise the behavior is undefined.
  Future<void> closeNotifications() {
    return platform.action.mobile(
      android: platform.android.closeNotifications,
      ios: platform.ios.closeNotifications,
    );
  }

  /// Opens the quick settings shade on Android and Control Center on iOS.
  ///
  /// Doesn't work on iOS Simulator because Control Center is not available
  /// there.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#openquicksettings>,
  ///    which is used on Android
  Future<void> openQuickSettings() {
    return platform.action.mobile(
      android: platform.android.openQuickSettings,
      ios: platform.ios.openQuickSettings,
    );
  }

  /// Opens the URL specified by [url].
  Future<void> openUrl(String url) {
    return platform.action.mobile(
      android: () => platform.android.openUrl(url),
      ios: () => platform.ios.openUrl(url),
    );
  }

  /// Returns the first, topmost visible notification.
  ///
  /// Notification shade has to be opened with [openNotifications].
  Future<Notification> getFirstNotification() {
    return platform.action.mobile(
      android: platform.android.getFirstNotification,
      ios: platform.ios.getFirstNotification,
    );
  }

  /// Returns notifications that are visible in the notification shade.
  ///
  /// Notification shade has to be opened with [openNotifications].
  Future<List<Notification>> getNotifications() {
    return platform.action.mobile(
      android: platform.android.getNotifications,
      ios: platform.ios.getNotifications,
    );
  }

  /// Searches for the [index]-th visible notification and taps on it.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// See also:
  ///
  ///  * [tapOnNotificationBySelector], which allows for more precise
  ///    specification of the notification to tap on
  Future<void> tapOnNotificationByIndex(int index, {Duration? timeout}) {
    return platform.action.mobile(
      android: () =>
          platform.android.tapOnNotificationByIndex(index, timeout: timeout),
      ios: () => platform.ios.tapOnNotificationByIndex(index, timeout: timeout),
    );
  }

  /// Taps on the visible notification using [selector].
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// See also:
  ///
  /// * [tapOnNotificationByIndex], which is less flexible but also less verbose
  Future<void> tapOnNotificationBySelector(
    CompoundSelector selector, {
    Duration? timeout,
  }) {
    return platform.action.mobile(
      android: () => platform.android.tapOnNotificationBySelector(
        selector.android,
        timeout: timeout,
      ),
      ios: () => platform.ios.tapOnNotificationBySelector(
        selector.ios,
        timeout: timeout,
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
  Future<void> pressVolumeUp() {
    return platform.action.mobile(
      android: platform.android.pressVolumeUp,
      ios: platform.ios.pressVolumeUp,
    );
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
  Future<void> pressVolumeDown() {
    return platform.action.mobile(
      android: platform.android.pressVolumeDown,
      ios: platform.ios.pressVolumeDown,
    );
  }

  /// Enables dark mode.
  Future<void> enableDarkMode({String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.enableDarkMode(appId: appId),
      ios: () => platform.ios.enableDarkMode(appId: appId),
    );
  }

  /// Disables dark mode.
  Future<void> disableDarkMode({String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.disableDarkMode(appId: appId),
      ios: () => platform.ios.disableDarkMode(appId: appId),
    );
  }

  /// Enables airplane mode.
  Future<void> enableAirplaneMode() {
    return platform.action.mobile(
      android: platform.android.enableAirplaneMode,
      ios: platform.ios.enableAirplaneMode,
    );
  }

  /// Disables airplane mode.
  Future<void> disableAirplaneMode() {
    return platform.action.mobile(
      android: platform.android.disableAirplaneMode,
      ios: platform.ios.disableAirplaneMode,
    );
  }

  /// Enables cellular (aka mobile data connection).
  Future<void> enableCellular() {
    return platform.action.mobile(
      android: platform.android.enableCellular,
      ios: platform.ios.enableCellular,
    );
  }

  /// Disables cellular (aka mobile data connection).
  Future<void> disableCellular() {
    return platform.action.mobile(
      android: platform.android.disableCellular,
      ios: platform.ios.disableCellular,
    );
  }

  /// Enables Wi-Fi.
  Future<void> enableWifi() {
    return platform.action.mobile(
      android: platform.android.enableWifi,
      ios: platform.ios.enableWifi,
    );
  }

  /// Disables Wi-Fi.
  Future<void> disableWifi() {
    return platform.action.mobile(
      android: platform.android.disableWifi,
      ios: platform.ios.disableWifi,
    );
  }

  /// Enables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  Future<void> enableBluetooth() {
    return platform.action.mobile(
      android: platform.android.enableBluetooth,
      ios: platform.ios.enableBluetooth,
    );
  }

  /// Disables bluetooth.
  ///
  /// Doesn't work on Android versions lower than 12.
  Future<void> disableBluetooth() {
    return platform.action.mobile(
      android: platform.android.disableBluetooth,
      ios: platform.ios.disableBluetooth,
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
    bool enablePatrolLog = true,
  }) {
    return platform.action.mobile(
      android: () => platform.android.swipe(
        from: from,
        to: to,
        steps: steps,
        enablePatrolLog: enablePatrolLog,
      ),
      ios: () => platform.ios.swipe(
        from: from,
        to: to,
        appId: appId,
        enablePatrolLog: enablePatrolLog,
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
    return platform.action.mobile(
      android: () => platform.android.swipeBack(dy: dy),
      ios: () => platform.ios.swipeBack(dy: dy, appId: appId),
    );
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
  }) {
    return platform.action.mobile(
      android: () =>
          platform.android.pullToRefresh(from: from, to: to, steps: steps),
      ios: () => platform.ios.pullToRefresh(from: from, to: to),
    );
  }

  /// Waits until the native view specified by [selector] becomes visible.
  Future<void> waitUntilVisible(
    CompoundSelector selector, {
    String? appId,
    Duration? timeout,
  }) {
    return platform.action.mobile(
      android: () =>
          platform.android.waitUntilVisible(selector.android, timeout: timeout),
      ios: () => platform.ios.waitUntilVisible(
        selector.ios,
        appId: appId,
        timeout: timeout,
      ),
    );
  }

  /// Waits until a native permission request dialog becomes visible within
  /// [timeout].
  ///
  /// Returns true if the dialog became visible within timeout, false otherwise.
  Future<bool> isPermissionDialogVisible({
    Duration timeout = const Duration(seconds: 1),
  }) {
    return platform.action.mobile(
      android: () =>
          platform.android.isPermissionDialogVisible(timeout: timeout),
      ios: () => platform.ios.isPermissionDialogVisible(timeout: timeout),
    );
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
  Future<void> grantPermissionWhenInUse() {
    return platform.action.mobile(
      android: platform.android.grantPermissionWhenInUse,
      ios: platform.ios.grantPermissionWhenInUse,
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
  Future<void> grantPermissionOnlyThisTime() {
    return platform.action.mobile(
      android: platform.android.grantPermissionOnlyThisTime,
      ios: platform.ios.grantPermissionOnlyThisTime,
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
  Future<void> denyPermission() {
    return platform.action.mobile(
      android: platform.android.denyPermission,
      ios: platform.ios.denyPermission,
    );
  }

  /// Select the "coarse location" (aka "approximate") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws if no permission request dialog is present.
  Future<void> selectCoarseLocation() {
    return platform.action.mobile(
      android: platform.android.selectCoarseLocation,
      ios: platform.ios.selectCoarseLocation,
    );
  }

  /// Select the "fine location" (aka "precise") setting on the currently
  /// visible native permission request dialog.
  ///
  /// Throws if no permission request dialog is present.
  Future<void> selectFineLocation() {
    return platform.action.mobile(
      android: platform.android.selectFineLocation,
      ios: platform.ios.selectFineLocation,
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
  }) {
    return platform.action.mobile(
      android: () => platform.android.setMockLocation(
        latitude,
        longitude,
        packageName: packageName,
      ),
      ios: () => platform.ios.setMockLocation(
        latitude,
        longitude,
        packageName: packageName,
      ),
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
    CompoundSelector? shutterButtonSelector,
    CompoundSelector? doneButtonSelector,
    Duration? timeout,
  }) {
    return platform.action.mobile(
      android: () => platform.android.takeCameraPhoto(
        shutterButtonSelector: shutterButtonSelector?.android,
        doneButtonSelector: doneButtonSelector?.android,
        timeout: timeout,
      ),
      ios: () => platform.ios.takeCameraPhoto(
        shutterButtonSelector: shutterButtonSelector?.ios,
        doneButtonSelector: doneButtonSelector?.ios,
        timeout: timeout,
      ),
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
    CompoundSelector? imageSelector,
    int? index,
    Duration? timeout,
  }) {
    return platform.action.mobile(
      android: () => platform.android.pickImageFromGallery(
        imageSelector: imageSelector?.android,
        index: index,
        timeout: timeout,
      ),
      ios: () => platform.ios.pickImageFromGallery(
        imageSelector: imageSelector?.ios,
        index: index,
        timeout: timeout,
      ),
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
    CompoundSelector? imageSelector,
    Duration? timeout,
  }) {
    return platform.action.mobile(
      android: () => platform.android.pickMultipleImagesFromGallery(
        imageIndexes: imageIndexes,
        imageSelector: imageSelector?.android,
        timeout: timeout,
      ),
      ios: () => platform.ios.pickMultipleImagesFromGallery(
        imageIndexes: imageIndexes,
        imageSelector: imageSelector?.ios,
        timeout: timeout,
      ),
    );
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
  Future<int> getOsVersion() {
    return platform.action.mobile(
      android: platform.android.getOsVersion,
      ios: platform.ios.getOsVersion,
    );
  }

  /// Checks if the app is running on a virtual device (simulator or emulator).
  ///
  /// Returns `true` if running on iOS simulator or Android emulator, `false` otherwise.
  /// On Android devices this method cannot be 100% accurate.
  ///
  /// This can be useful for conditional logic in tests that need to behave
  /// differently on physical devices vs simulators/emulators.
  Future<bool> isVirtualDevice() {
    return platform.action.mobile(
      android: platform.android.isVirtualDevice,
      ios: platform.ios.isVirtualDevice,
    );
  }
}

/// Platform-specific action router.
class PlatformAction {
  /// Calls the platform-specific action.
  T call<T>({
    T Function()? android,
    T Function()? ios,
    T Function()? web,
    T Function()? macos,
    T Function()? mobile,
  }) {
    final value = maybe(
      android: android,
      ios: ios,
      web: web,
      macos: macos,
      mobile: mobile,
    );

    if (value == null) {
      throw UnsupportedError('Unsupported platform');
    }

    return value;
  }

  /// Maybe calls the platform-specific action, returns null if not supported.
  T? maybe<T>({
    T Function()? android,
    T Function()? ios,
    T Function()? web,
    T Function()? macos,
    T Function()? mobile,
  }) {
    T? empty() => null;

    return safe(
      android: android ?? mobile ?? empty,
      ios: ios ?? mobile ?? empty,
      web: web ?? empty,
      macos: macos ?? empty,
    );
  }

  /// Calls the platform-specific action or falls back to a default.
  T fallback<T>({
    T Function()? android,
    T Function()? ios,
    T Function()? web,
    T Function()? macos,
    T Function()? mobile,
    required T Function() fallback,
  }) {
    return maybe(
          android: android,
          ios: ios,
          web: web,
          macos: macos,
          mobile: mobile,
        ) ??
        fallback();
  }

  /// Safely calls the platform-specific action for current platform.
  T safe<T>({
    required T Function() android,
    required T Function() ios,
    required T Function() web,
    required T Function() macos,
  }) {
    if (current_platform.isAndroid) {
      return android();
    } else if (current_platform.isIOS) {
      return ios();
    } else if (current_platform.isMacOS) {
      return macos();
    } else if (current_platform.isWeb) {
      return web();
    }

    throw UnsupportedError('Unkown platform');
  }

  /// Calls the action for mobile platforms (Android or iOS).
  T mobile<T>({required T Function() android, required T Function() ios}) {
    T error() => throw UnsupportedError('Unsupported platform');

    return safe(android: android, ios: ios, web: error, macos: error);
  }
}
