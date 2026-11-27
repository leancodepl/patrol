// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'common.dart';

void main() {
  final appId = switch (patrolTargetPlatform) {
    PatrolTargetPlatform.iOS => 'com.apple.Preferences',
    PatrolTargetPlatform.android => 'com.android.settings',
    _ => throw UnsupportedError('Unsupported platform'),
  };

  patrol(
    'taps at the lower middle of the screen in the Settings app',
    ($) async {
      await createApp($);

      await $.native.openApp(appId: appId);
      await $.native.tapAt(Offset(0.5, 0.8), appId: appId);
    },
    tags: ['ios', 'simulator', 'emulator', 'physical_device', 'android'],
  );
}
