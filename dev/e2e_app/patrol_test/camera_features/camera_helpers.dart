import 'package:patrol/patrol.dart';

class CameraHelpers {
  CameraHelpers(this.$);
  final PatrolIntegrationTester $;

  Future<void> takePhotosAcceptDialogsAndOpenAppOnEmulator() async {
    await $.platform.mobile.openApp(appId: 'com.android.camera2');
    await maybeAcceptDialogAndroid();
    await maybeAcceptPermissionDialog();
    await maybeAcceptDialogAndroid();
    await $.platform.android.tap(
      AndroidSelector(resourceName: 'com.android.camera2:id/shutter_button'),
    );
    await $.platform.android.tap(
      AndroidSelector(resourceName: 'com.android.camera2:id/shutter_button'),
    );
    await $.platform.android.tap(
      AndroidSelector(resourceName: 'com.android.camera2:id/shutter_button'),
    );

    await Future.delayed(const Duration(seconds: 4), () {});
    await $.platform.mobile.openApp();
  }

  Future<void> takePhotosAcceptDialogsAndOpenAppOnRealDeviceIOS() async {
    await $.platform.mobile.openApp(appId: 'com.apple.camera');
    await maybeAcceptPermissionDialog();
    await $.platform.ios.tap(
      IOSSelector(identifier: 'PhotoCapture'),
      appId: 'com.apple.camera',
    );
    await $.platform.ios.tap(
      IOSSelector(identifier: 'PhotoCapture'),
      appId: 'com.apple.camera',
    );
    await $.platform.ios.tap(
      IOSSelector(identifier: 'PhotoCapture'),
      appId: 'com.apple.camera',
    );
    await $.platform.mobile.openApp(appId: 'pl.leancode.patrol.e2eApp');
  }

  Future<void> takePhotosAcceptDialogsAndOpenAppOnRealDeviceAndroid() async {
    await $.platform.mobile.openApp(appId: 'com.google.android.GoogleCamera');
    await maybeAcceptPermissionDialog();
    try {
      await $.platform.android.tap(AndroidSelector(text: 'Done'));
    } catch (_) {
      /* ignore */
    }
    try {
      await $.platform.android.tap(AndroidSelector(text: 'OK'));
    } catch (_) {
      /* ignore */
    }

    await $.platform.android.tap(
      AndroidSelector(
        resourceName: 'com.google.android.GoogleCamera:id/shutter_button',
      ),
    );
    await $.platform.android.tap(
      AndroidSelector(
        resourceName: 'com.google.android.GoogleCamera:id/shutter_button',
      ),
    );
    await $.platform.android.tap(
      AndroidSelector(
        resourceName: 'com.google.android.GoogleCamera:id/shutter_button',
      ),
    );
    await Future.delayed(const Duration(seconds: 4), () {});
    await $.platform.mobile.openApp(appId: 'pl.leancode.patrol.e2e_app');
  }

  /// Try to accept NEXT modal, if modal not found, do nothing
  Future<void> maybeAcceptDialogAndroid() async {
    try {
      await $.platform.android.tap(AndroidSelector(text: 'NEXT'));
    } on Exception {
      /* ignore */
    }
  }

  /// Try to accept Camera or Gallery permission dialog, if dialog not found, do nothing
  Future<void> maybeAcceptPermissionDialog() async {
    if (await $.platform.mobile.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }
  }
}
