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

      await $.platform.mobile.disableAirplaneMode();
      await $.platform.mobile.enableAirplaneMode();
      await $.platform.mobile.disableAirplaneMode();
      await $.platform.mobile.enableAirplaneMode();
    },
    tags: [
      'locale_testing_android',
      'android',
      'emulator',
      'ios',
      'physical_device',
    ],
  );
}
