import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('take a photo', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);
    await $(#cameraFeaturesButton).scrollTo().tap();
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      throw Exception('Camera is not supported on iOS simulator');
    }
    await $(#takePhotoButton).tap();
    if (await $.native.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native.grantPermissionWhenInUse();
    }
    await cameraHelpers.maybeAcceptDialogAndroid();

    await $.native.takeCameraPhoto();
    await $.pumpAndSettle();
    await $(#smallImagePreview).waitUntilVisible();
  });
}
