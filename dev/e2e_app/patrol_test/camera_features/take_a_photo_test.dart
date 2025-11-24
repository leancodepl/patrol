import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('take a photo', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);
    await $(#cameraFeaturesButton).scrollTo().tap();
    if (await $.platform.mobile.isVirtualDevice() && Platform.isIOS) {
      throw Exception('Camera is not supported on iOS simulator');
    }
    await $(#takePhotoButton).tap();
    await cameraHelpers.maybeAcceptPermissionDialog();
    await cameraHelpers.maybeAcceptDialogAndroid();

    await $.platform.mobile.takeCameraPhoto();
    await $.pumpAndSettle();
    await $(#smallImagePreview).waitUntilVisible();
  });
}
