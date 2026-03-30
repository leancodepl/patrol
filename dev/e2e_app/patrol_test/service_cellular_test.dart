import 'common.dart';

void main() {
  patrol(
    'disables and enables cellular twice',
    ($) async {
      await createApp($);

      await $.platform.mobile.disableCellular();
      await $.platform.mobile.enableCellular();
      await $.platform.mobile.disableCellular();
      await $.platform.mobile.enableCellular();
    },
    tags: ['android', 'emulator', 'ios', 'physical_device'],
  );
}
