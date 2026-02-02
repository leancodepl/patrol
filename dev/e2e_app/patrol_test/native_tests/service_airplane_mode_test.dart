// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'common.dart';

final nativeAutomator = NativeAutomator(
  platformAutomator: PlatformAutomator(
    config: PlatformAutomatorConfig.defaultConfig(),
  ),
);

void main() {
  patrolTearDown(() async {
    await nativeAutomator.disableAirplaneMode();
  });
  patrol('disables and enables airplane mode twice', ($) async {
    await createApp($);
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log('Test will be skipped because of iOS simulator limitations');
      return;
    } else {
      await $.native.disableAirplaneMode();
      await $.native.enableAirplaneMode();
      await $.native.disableAirplaneMode();
      await $.native.enableAirplaneMode();
    }
  }, tags: ['locale_testing_android']);
}
