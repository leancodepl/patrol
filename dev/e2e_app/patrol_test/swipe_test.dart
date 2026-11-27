import 'common.dart';

void main() {
  final appId = switch (patrolTargetPlatform) {
    PatrolTargetPlatform.iOS => 'com.apple.Preferences',
    PatrolTargetPlatform.android => 'com.android.settings',
    _ => throw UnsupportedError('Unsupported platform'),
  };

  patrol(
    'scrolls the Settings app',
    ($) async {
      await createApp($);

      await $.platform.mobile.openApp(appId: appId);
      await $.platform.mobile.swipe(
        from: Offset(0.5, 0.8),
        to: Offset(0.5, 0.2),
        appId: appId,
      );
    },
    tags: ['ios', 'simulator', 'emulator', 'physical_device', 'android'],
  );
}
