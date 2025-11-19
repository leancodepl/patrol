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

class PlatformAutomatorConfig {
  PlatformAutomatorConfig({this.androidConfig, this.iosConfig, this.webConfig});

  factory PlatformAutomatorConfig.fromOptions({
    /// Apps installed on the iOS simulator.
    ///
    /// This is needed for purpose of native view inspection in the Patrol
    /// DevTools extension.
    String? iosInstalledApps,

    /// Time after which the connection with the native automator will fail.
    ///
    /// It must be longer than [findTimeout].
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

  factory PlatformAutomatorConfig.forTestSetup() {
    return PlatformAutomatorConfig(
      androidConfig: const AndroidAutomatorConfig(),
      iosConfig: const IOSAutomatorConfig(),
      webConfig: const WebAutomatorConfig(),
    );
  }

  final AndroidAutomatorConfig? androidConfig;
  final IOSAutomatorConfig? iosConfig;
  final WebAutomatorConfig? webConfig;

  bool get androidEnabled => androidConfig != null;
  bool get iosEnabled => iosConfig != null;
  bool get webEnabled => webConfig != null;
}

class PlatformAutomator {
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

  late final AndroidAutomator android;
  late final WebAutomator web;
  late final IOSAutomator ios;
  late final MobileAutomator mobile;

  final action = PlatformAction();

  Future<void> initialize() async {
    await action.maybe(android: android.initialize, web: web.initialize);
  }

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

  Future<void> markPatrolAppServiceReady() async {
    await action.maybe(
      android: () async => {await android.markPatrolAppServiceReady()},
      ios: () async => {await ios.markPatrolAppServiceReady()},
    );
  }

  /// None of the native actions are supported on MacOS, so we will just always throw.
  static T _throwOnMacOS<T>() {
    throw UnsupportedError('MacOS native actions are not supported');
  }
}

class MobileAutomator {
  MobileAutomator({required this.platform});

  final PlatformAutomator platform;

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

  String get resolvedAppId {
    return platform.action.mobile(
      android: () => platform.android.resolvedAppId,
      ios: () => platform.ios.resolvedAppId,
    );
  }

  Future<void> tap(CompoundSelector selector, {Duration? timeout}) {
    return platform.action.mobile(
      android: () => platform.android.tap(selector.android, timeout: timeout),
      ios: () => platform.ios.tap(selector.ios, timeout: timeout),
    );
  }

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

  Future<void> tapAt(Offset location, {String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.tapAt(location),
      ios: () => platform.ios.tapAt(location, appId: appId),
    );
  }

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

  Future<void> pressHome() {
    return platform.action.mobile(
      android: platform.android.pressHome,
      ios: platform.ios.pressHome,
    );
  }

  Future<void> openApp({String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.openApp(appId: appId),
      ios: () => platform.ios.openApp(appId: appId),
    );
  }

  Future<void> pressRecentApps() {
    return platform.action.mobile(
      android: platform.android.pressRecentApps,
      ios: platform.ios.pressRecentApps,
    );
  }

  Future<void> openNotifications() {
    return platform.action.mobile(
      android: platform.android.openNotifications,
      ios: platform.ios.openNotifications,
    );
  }

  Future<void> closeNotifications() {
    return platform.action.mobile(
      android: platform.android.closeNotifications,
      ios: platform.ios.closeNotifications,
    );
  }

  Future<void> openQuickSettings() {
    return platform.action.mobile(
      android: platform.android.openQuickSettings,
      ios: platform.ios.openQuickSettings,
    );
  }

  Future<void> openUrl(String url) {
    return platform.action.mobile(
      android: () => platform.android.openUrl(url),
      ios: () => platform.ios.openUrl(url),
    );
  }

  Future<Notification> getFirstNotification() {
    return platform.action.mobile(
      android: platform.android.getFirstNotification,
      ios: platform.ios.getFirstNotification,
    );
  }

  Future<List<Notification>> getNotifications() {
    return platform.action.mobile(
      android: platform.android.getNotifications,
      ios: platform.ios.getNotifications,
    );
  }

  Future<void> tapOnNotificationByIndex(int index, {Duration? timeout}) {
    return platform.action.mobile(
      android: () =>
          platform.android.tapOnNotificationByIndex(index, timeout: timeout),
      ios: () => platform.ios.tapOnNotificationByIndex(index, timeout: timeout),
    );
  }

  Future<void> tapOnNotificationBySelector(
    Selector selector, {
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

  Future<void> pressVolumeUp() {
    return platform.action.mobile(
      android: platform.android.pressVolumeUp,
      ios: platform.ios.pressVolumeUp,
    );
  }

  Future<void> pressVolumeDown() {
    return platform.action.mobile(
      android: platform.android.pressVolumeDown,
      ios: platform.ios.pressVolumeDown,
    );
  }

  Future<void> enableDarkMode({String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.enableDarkMode(appId: appId),
      ios: () => platform.ios.enableDarkMode(appId: appId),
    );
  }

  Future<void> disableDarkMode({String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.disableDarkMode(appId: appId),
      ios: () => platform.ios.disableDarkMode(appId: appId),
    );
  }

  Future<void> enableAirplaneMode() {
    return platform.action.mobile(
      android: platform.android.enableAirplaneMode,
      ios: platform.ios.enableAirplaneMode,
    );
  }

  Future<void> disableAirplaneMode() {
    return platform.action.mobile(
      android: platform.android.disableAirplaneMode,
      ios: platform.ios.disableAirplaneMode,
    );
  }

  Future<void> enableCellular() {
    return platform.action.mobile(
      android: platform.android.enableCellular,
      ios: platform.ios.enableCellular,
    );
  }

  Future<void> disableCellular() {
    return platform.action.mobile(
      android: platform.android.disableCellular,
      ios: platform.ios.disableCellular,
    );
  }

  Future<void> enableWifi() {
    return platform.action.mobile(
      android: platform.android.enableWifi,
      ios: platform.ios.enableWifi,
    );
  }

  Future<void> disableWifi() {
    return platform.action.mobile(
      android: platform.android.disableWifi,
      ios: platform.ios.disableWifi,
    );
  }

  Future<void> enableBluetooth() {
    return platform.action.mobile(
      android: platform.android.enableBluetooth,
      ios: platform.ios.enableBluetooth,
    );
  }

  Future<void> disableBluetooth() {
    return platform.action.mobile(
      android: platform.android.disableBluetooth,
      ios: platform.ios.disableBluetooth,
    );
  }

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

  Future<void> swipeBack({double dy = 0.5, String? appId}) {
    return platform.action.mobile(
      android: () => platform.android.swipeBack(dy: dy),
      ios: () => platform.ios.swipeBack(dy: dy, appId: appId),
    );
  }

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

  Future<bool> isPermissionDialogVisible({
    Duration timeout = const Duration(seconds: 1),
  }) {
    return platform.action.mobile(
      android: () =>
          platform.android.isPermissionDialogVisible(timeout: timeout),
      ios: () => platform.ios.isPermissionDialogVisible(timeout: timeout),
    );
  }

  Future<void> grantPermissionWhenInUse() {
    return platform.action.mobile(
      android: platform.android.grantPermissionWhenInUse,
      ios: platform.ios.grantPermissionWhenInUse,
    );
  }

  Future<void> grantPermissionOnlyThisTime() {
    return platform.action.mobile(
      android: platform.android.grantPermissionOnlyThisTime,
      ios: platform.ios.grantPermissionOnlyThisTime,
    );
  }

  Future<void> denyPermission() {
    return platform.action.mobile(
      android: platform.android.denyPermission,
      ios: platform.ios.denyPermission,
    );
  }

  Future<void> selectCoarseLocation() {
    return platform.action.mobile(
      android: platform.android.selectCoarseLocation,
      ios: platform.ios.selectCoarseLocation,
    );
  }

  Future<void> selectFineLocation() {
    return platform.action.mobile(
      android: platform.android.selectFineLocation,
      ios: platform.ios.selectFineLocation,
    );
  }

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

  Future<int> getOsVersion() {
    return platform.action.mobile(
      android: platform.android.getOsVersion,
      ios: platform.ios.getOsVersion,
    );
  }

  Future<bool> isVirtualDevice() {
    return platform.action.mobile(
      android: platform.android.isVirtualDevice,
      ios: platform.ios.isVirtualDevice,
    );
  }
}

class PlatformAction {
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

  T mobile<T>({required T Function() android, required T Function() ios}) {
    T error() => throw UnsupportedError('Unsupported platform');

    return safe(android: android, ios: ios, web: error, macos: error);
  }
}
