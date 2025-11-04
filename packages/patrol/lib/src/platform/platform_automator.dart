import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:patrol/src/platform/android/android_automator.dart';
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/android/contracts/contracts.dart'
    hide Selector;
import 'package:patrol/src/platform/android/empty_android_automator.dart'
    as empty_android_automator;
import 'package:patrol/src/platform/android/empty_android_automator.dart'
    if (dart.library.io) 'package:patrol/src/platform/android/native_android_automator.dart'
    as native_android_automator;
import 'package:patrol/src/platform/selector.dart';
import 'package:patrol/src/platform/web/web_automator.dart';

class PlatformAutomator {
  PlatformAutomator() {
    final config = AndroidAutomatorConfig();

    android = action.fallback(
      android: () => native_android_automator.AndroidAutomator(config: config),
      fallback: () => empty_android_automator.AndroidAutomator(config: config),
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
