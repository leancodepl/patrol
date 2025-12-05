// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'package:patrol/patrol.dart';

class CameraHelpers {
  CameraHelpers(this.$);
  final PatrolIntegrationTester $;

  Future<void> takePhotosAcceptDialogsAndOpenAppOnEmulator() async {
    await $.native2.openApp(appId: 'com.android.camera2');
    await maybeAcceptDialogAndroid();
    await maybeAcceptPermissionDialog();
    await maybeAcceptDialogAndroid();
    await $.native2.tap(
      NativeSelector(
        android: AndroidSelector(
          resourceName: 'com.android.camera2:id/shutter_button',
        ),
      ),
    );
    await $.native2.tap(
      NativeSelector(
        android: AndroidSelector(
          resourceName: 'com.android.camera2:id/shutter_button',
        ),
      ),
    );
    await $.native2.tap(
      NativeSelector(
        android: AndroidSelector(
          resourceName: 'com.android.camera2:id/shutter_button',
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 4), () {});
    await $.native2.openApp();
  }

  Future<void> takePhotosAcceptDialogsAndOpenAppOnRealDeviceIOS() async {
    await $.native2.openApp(appId: 'com.apple.camera');
    await maybeAcceptPermissionDialog();
    await $.native2.tap(
      appId: 'com.apple.camera',
      NativeSelector(ios: IOSSelector(identifier: 'PhotoCapture')),
    );
    await $.native2.tap(
      appId: 'com.apple.camera',
      NativeSelector(ios: IOSSelector(identifier: 'PhotoCapture')),
    );
    await $.native2.tap(
      appId: 'com.apple.camera',
      NativeSelector(ios: IOSSelector(identifier: 'PhotoCapture')),
    );
    await $.native2.openApp(appId: 'pl.leancode.patrol.e2eApp');
  }

  Future<void> takePhotosAcceptDialogsAndOpenAppOnRealDeviceAndroid() async {
    await $.native2.openApp(appId: 'com.google.android.GoogleCamera');
    await maybeAcceptPermissionDialog();
    await $.native2.tap(NativeSelector(android: AndroidSelector(text: 'Done')));
    await $.native2.tap(
      NativeSelector(
        android: AndroidSelector(
          resourceName: 'com.google.android.GoogleCamera:id/shutter_button',
        ),
      ),
    );
    await $.native2.tap(
      NativeSelector(
        android: AndroidSelector(
          resourceName: 'com.google.android.GoogleCamera:id/shutter_button',
        ),
      ),
    );
    await $.native2.tap(
      NativeSelector(
        android: AndroidSelector(
          resourceName: 'com.google.android.GoogleCamera:id/shutter_button',
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 4), () {});
    await $.native2.openApp(appId: 'pl.leancode.patrol.e2e_app');
  }

  /// Try to accept NEXT modal, if modal not found, do nothing
  Future<void> maybeAcceptDialogAndroid() async {
    try {
      await $.native2.tap(
        NativeSelector(android: AndroidSelector(text: 'NEXT')),
      );
    } on Exception {
      /* ignore */
    }
  }

  /// Try to accept Camera or Gallery permission dialog, if dialog not found, do nothing
  Future<void> maybeAcceptPermissionDialog() async {
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
  }
}
