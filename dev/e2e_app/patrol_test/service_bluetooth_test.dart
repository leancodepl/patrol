import 'common.dart';

void main() {
  patrol(
    'disables and enables bluetooth twice',
    ($) async {
      await createApp($);

      await $.platform.mobile.disableBluetooth();
      await $.platform.mobile.enableBluetooth();
      await $.platform.mobile.disableBluetooth();
      await $.platform.mobile.enableBluetooth();
    },
    // TODO(PAT-341): skipped on iOS — Control Center bluetooth toggle automation
    // is broken on iOS 18. https://leancode.atlassian.net/browse/PAT-341
    tags: ['android', 'emulator', 'physical_device']
  );
}
