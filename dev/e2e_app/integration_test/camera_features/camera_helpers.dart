import 'package:patrol/patrol.dart';

class CameraHelpers {
  CameraHelpers(this.$);
  final PatrolIntegrationTester $;

  Future<void> takePhotosAcceptDialogsAndOpenAppOnEmulator() async {
    await $.native.openApp(appId: 'com.android.camera2');
    try {
      await $.native.tap(Selector(text: 'NEXT'));
    } on Exception {/* ignore */}
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
    try {
      await $.native.tap(Selector(text: 'NEXT'));
    } on Exception {/* ignore */}
    await $.native
        .tap(Selector(resourceId: 'com.android.camera2:id/shutter_button'));
    await $.native
        .tap(Selector(resourceId: 'com.android.camera2:id/shutter_button'));
    await $.native
        .tap(Selector(resourceId: 'com.android.camera2:id/shutter_button'));

    await $.native.openApp(appId: 'pl.leancode.patrol.e2e_app');
  }

  Future<void> takePhotosAcceptDialogsAndOpenAppOnRealDeviceAndroid() async {
    await $.native.openApp(appId: 'com.google.android.GoogleCamera');
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
    await $.native.tap(Selector(text: 'Done'));
    await $.native.tap(
      Selector(
        resourceId: 'com.google.android.GoogleCamera:id/shutter_button',
      ),
    );
    await $.native.tap(
      Selector(
        resourceId: 'com.google.android.GoogleCamera:id/shutter_button',
      ),
    );
    await $.native.tap(
      Selector(
        resourceId: 'com.google.android.GoogleCamera:id/shutter_button',
      ),
    );
    await Future.delayed(const Duration(microseconds: 4), () {});
    await $.native.openApp(appId: 'pl.leancode.patrol.e2e_app');
  }

  Future<void> maybeAcceptDialogAndroid() async {
    try {
      await $.native.tap(Selector(text: 'NEXT'));
    } on Exception {/* ignore */}
  }
}
