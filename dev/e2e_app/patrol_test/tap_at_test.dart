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

      await $.platform.mobile.openApp(appId: appId);
      await $.platform.mobile.tapAt(Offset(0.5, 0.8), appId: appId);
    },
    tags: ['ios', 'simulator', 'emulator', 'physical_device', 'android'],
  );
}
