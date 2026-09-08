import 'package:e2e_app/keys.dart';
import 'common.dart';

/// Capture helper for Korean system dialogs (proof for PR adding `ko`).
///
/// Requests permissions one by one and pauses with the system dialog
/// on screen, so an external `xcrun simctl io screenshot` loop can
/// capture each dialog, then native automation resolves the dialog.
///
/// Korean strings verified in this sequence:
/// allow / dont_allow / limit_access / allow_full_access /
/// allow_once / allow_while_using_app (+ precise location toggle).
void main() {
  patrol(
    'korean dialog capture sequence',
    ($) async {
      await createApp($);
      await $('Open permissions screen').scrollTo().tap();

      // 1) Camera — 허용 / 허용 안 함
      await $(K.requestCameraPermissionButton).tap();
      await Future<void>.delayed(const Duration(seconds: 12));
      try {
        await $.platform.mobile.grantPermissionWhenInUse();
      } catch (_) {}

      // 2) Microphone — 허용 안 함 (deny)
      await $(K.requestMicrophonePermissionButton).tap();
      await Future<void>.delayed(const Duration(seconds: 12));
      try {
        await $.platform.mobile.denyPermission();
      } catch (_) {}

      // 3) Photos — 접근 제한… / 전체 접근 허용 / 허용 안 함
      await $(K.requestGalleryPermissionButton).tap();
      await Future<void>.delayed(const Duration(seconds: 12));
      try {
        await $.platform.mobile.denyPermission();
      } catch (_) {}

      // 4) Location — 한 번 허용 / 앱을 사용하는 동안 허용 / 허용 안 함 + 정확한 위치
      await $(K.requestLocationPermissionButton).tap();
      await Future<void>.delayed(const Duration(seconds: 12));
      try {
        await $.platform.mobile.grantPermissionWhenInUse();
      } catch (_) {}
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
