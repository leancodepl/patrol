import 'package:patrol/src/platform/android/android_automator.dart';
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/android/android_automator_empty.dart'
    as empty_android_automator;
import 'package:patrol/src/platform/android/android_automator_empty.dart'
    if (dart.library.io) 'package:patrol/src/platform/android/android_automator_native.dart'
    as native_android_automator;
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/current.dart';
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
import 'package:patrol/src/platform/web/web_automator_native.dart'
    as native_web_automator;

class PlatformAutomator {
  PlatformAutomator() {
    final androidConfig = AndroidAutomatorConfig();
    final iosConfig = IOSAutomatorConfig();
    final webConfig = WebAutomatorConfig();

    android = action.fallback(
      android: () =>
          native_android_automator.AndroidAutomator(config: androidConfig),
      fallback: () =>
          empty_android_automator.AndroidAutomator(config: androidConfig),
    );

    ios = action.fallback(
      ios: () => native_ios_automator.IOSAutomator(config: iosConfig),
      fallback: () => empty_ios_automator.IOSAutomator(config: iosConfig),
    );

    web = action.fallback(
      web: () => native_web_automator.WebAutomator(config: webConfig),
      fallback: () => empty_web_automator.WebAutomator(config: webConfig),
    );

    mobile = MobileAutomator(platform: this);
  }

  late final AndroidAutomator android;
  late final WebAutomator web;
  late final IOSAutomator ios;
  late final MobileAutomator mobile;

  final action = PlatformAction();

  Future<void> tap(
    CompoundSelector selector, {
    String? appId,
    Duration? timeout,
  }) {
    return action.safe(
      android: () => android.tap(selector.android, timeout: timeout),
      ios: () => ios.tap(selector.ios, appId: appId, timeout: timeout),
      web: () => web.tap(selector.web, appId: appId, timeout: timeout),
      macos: _throwOnMacOS,
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

  Future<void> doubleTap(CompoundSelector selector, {Duration? timeout}) {
    return platform.action.mobile(
      android: () =>
          platform.android.doubleTap(selector.android, timeout: timeout),
      ios: () => platform.ios.doubleTap(selector.ios, timeout: timeout),
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
    if (isAndroid) {
      return android();
    } else if (isIOS) {
      return ios();
    } else if (isMacOS) {
      return macos();
    } else if (isWeb) {
      return web();
    }

    throw UnsupportedError('Unkown platform');
  }

  T mobile<T>({required T Function() android, required T Function() ios}) {
    T error() => throw UnsupportedError('Unsupported platform');

    return safe(android: android, ios: ios, web: error, macos: error);
  }
}
