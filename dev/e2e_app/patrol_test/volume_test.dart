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
    // TODO: causing errors of whole test run on android emulator.
  }, tags: ['android', 'physical_device', 'ios ']);
}
