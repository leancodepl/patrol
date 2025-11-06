import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:patrol/src/platform/android/android_automator.dart';
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/android/android_automator_empty.dart'
    as empty_android_automator;
import 'package:patrol/src/platform/android/android_automator_empty.dart'
    if (dart.library.io) 'package:patrol/src/platform/android/android_automator_native.dart'
    as native_android_automator;
import 'package:patrol/src/platform/android/contracts/contracts.dart'
    hide Selector;
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
  late final MacOSAutomator macos;
  late final MobileAutomator mobile;

  final action = PlatformAction();

  Future<void> tap(Selector selector, {String? appId, Duration? timeout}) {
    return action.safe(
      android: () =>
          android.tap(selector.android, appId: appId, timeout: timeout),
      ios: () => ios.tap(selector.ios, appId: appId, timeout: timeout),
      web: () => web.tap(selector.web, appId: appId, timeout: timeout),
      macos: () => macos.tap(selector.macos, appId: appId, timeout: timeout),
    );
  }
}

class MobileAutomator {
  MobileAutomator({required this.platform});

  final PlatformAutomator platform;

  Future<void> tap(Selector selector, {String? appId, Duration? timeout}) {
    return platform.action.mobile(
      android: () => platform.android.tap(
        selector.android,
        appId: appId,
        timeout: timeout,
      ),
      ios: () => platform.ios.tap(selector.ios, appId: appId, timeout: timeout),
    );
  }

  Future<void> doubleTap(
    Selector selector, {
    String? appId,
    Duration? timeout,
    Duration? delayBetweenTaps,
  }) {
    return platform.action.mobile(
      android: () => platform.android.doubleTap(
        selector.android,
        appId: appId,
        timeout: timeout,
        delayBetweenTaps: delayBetweenTaps,
      ),
      ios: () => platform.ios.doubleTap(
        selector.ios,
        appId: appId,
        timeout: timeout,
        delayBetweenTaps: delayBetweenTaps,
      ),
    );
  }

  Future<void> pressHome() {
    return platform.action.mobile(
      android: platform.android.pressHome,
      ios: platform.ios.pressHome,
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
    if (io.Platform.isAndroid) {
      return android();
    } else if (io.Platform.isIOS) {
      return ios();
    } else if (io.Platform.isMacOS) {
      return macos();
    } else if (kIsWeb) {
      return web();
    }

    throw UnsupportedError('Unkown platform');
  }

  T mobile<T>({required T Function() android, required T Function() ios}) {
    T error() => throw UnsupportedError('Unsupported platform');

    return safe(android: android, ios: ios, web: error, macos: error);
  }
}
