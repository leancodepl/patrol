import 'common.dart';

/// Capture helper: navigate iOS Settings to the Display & Brightness pane
/// (physical-device path of enable/disableDarkMode) and hold for screenshot.
void main() {
  patrol(
    'navigate to display and brightness pane',
    ($) async {
      await createApp($);
      await $.platform.mobile.pressHome();
      await $.platform.mobile.openPlatformApp(
        androidAppId: 'com.android.settings',
        iosAppId: 'com.apple.Preferences',
      );

      // iOS 26: pane is below the fold — swipe up in Settings
      await $.platform.mobile.swipe(
        from: const Offset(0.5, 0.8),
        to: const Offset(0.5, 0.3),
      );
      await Future<void>.delayed(const Duration(seconds: 2));

      try {
        await $.platform.tap(
          Selector(text: '화면 및 밝기'),
          timeout: const Duration(seconds: 5),
        );
      } catch (_) {
        // pane name fallback (iOS 26 rename candidates)
        try {
          await $.platform.tap(
            Selector(textContains: '밝기'),
            timeout: const Duration(seconds: 5),
          );
        } catch (_) {}
      }

      // 옵션 화면 유지 — 외부 캡처
      await Future<void>.delayed(const Duration(seconds: 25));
    },
    tags: ['ios', 'simulator'],
  );
}
