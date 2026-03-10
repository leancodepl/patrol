import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('take a photo', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);

    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#takePhotoButton).tap();
    await cameraHelpers.maybeAcceptPermissionDialog();
    if (Platform.isAndroid) {
      await cameraHelpers.maybeAcceptDialogAndroid();
    }

    await $.platform.mobile.takeCameraPhoto();
    await $.pumpAndSettle();
    await $(#smallImagePreview).waitUntilVisible();
  }, tags: ['android', 'ios', 'emulator', 'physical_device']);
}
