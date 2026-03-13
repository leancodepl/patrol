import 'common.dart';

void main() {
  patrol(
    'disables and enables location twice',
    ($) async {
      await createApp($);

      await $.platform.android.disableLocation();
      await $.platform.android.enableLocation();
      await $.platform.android.disableLocation();
      await $.platform.android.enableLocation();
    },
    tags: ['locale_testing_android', 'android', 'emulator', 'ios', 'simulator'],
  );
}
