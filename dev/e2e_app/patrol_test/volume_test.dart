import 'common.dart';

void main() {
  patrol('change volume', ($) async {
    await createApp($);

    await $.pumpAndSettle();
    await $.platform.mobile.pressVolumeUp();
    await $.pumpAndSettle();
    await $.platform.mobile.pressVolumeDown();
    await $.pumpAndSettle();
    await $.platform.mobile.pressVolumeUp();
    await $.pumpAndSettle();
  }, tags: ['android', 'emulator', 'physical_device', 'ios ']);
}
