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

    await $.native2.openApp();
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
    await $.native2.openApp();
  }

  /// Try to accept NEXT modal, if modal not found, do nothing
  Future<void> maybeAcceptDialogAndroid() async {
    try {
      await $.native2
          .tap(NativeSelector(android: AndroidSelector(text: 'NEXT')));
    } on Exception {/* ignore */}
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
