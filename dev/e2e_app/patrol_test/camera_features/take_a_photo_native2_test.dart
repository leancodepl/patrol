import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('take a photo - native2', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);

    await $(#cameraFeaturesButton).scrollTo().tap();
    if (await $.native2.isVirtualDevice() && Platform.isIOS) {
      throw Exception('Camera is not supported on iOS simulator');
    }
    await $(#takePhotoButton).tap();
    await cameraHelpers.maybeAcceptPermissionDialog();
    await cameraHelpers.maybeAcceptDialogAndroid();

    await $.native2.takeCameraPhoto();
    await $.pumpAndSettle();
    await $(#smallImagePreview).waitUntilVisible();
  });
}
