import 'dart:io';

import 'common.dart';

final platformAutomator = PlatformAutomator(
  config: PlatformAutomatorConfig.defaultConfig(),
);

void main() {
  patrolTearDown(() async {
    await platformAutomator.mobile.disableAirplaneMode();
  });
  patrol(
    'disables and enables airplane mode twice',
    ($) async {
      await createApp($);
      if (await $.platform.mobile.isVirtualDevice() && Platform.isIOS) {
        $.log('Test will be skipped because of iOS simulator limitations');
        return;
      } else {
        await $.platform.mobile.disableAirplaneMode();
        await $.platform.mobile.enableAirplaneMode();
        await $.platform.mobile.disableAirplaneMode();
        await $.platform.mobile.enableAirplaneMode();
      }
    },
    tags: [
      'locale_testing_android',
      'android',
      'ios',
      'physical_device',
      'not_on_ios_simulator',
    ],
  );
}
