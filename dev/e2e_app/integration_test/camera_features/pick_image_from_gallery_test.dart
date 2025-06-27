import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('pick image from gallery - native', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);
    if (await $.native.isVirtualDevice() && Platform.isAndroid) {
      await cameraHelpers.takePhotosAcceptDialogsAndOpenAppOnEmulator();
    } else if (Platform.isAndroid) {
      await cameraHelpers
          .takePhotosAcceptDialogsAndOpenAppOnRealDeviceAndroid();
    }
    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#chooseFromGalleryButton).tap();
    await cameraHelpers.maybeAcceptPermissionDialog();
    await $.native.pickImageFromGallery(index: 1);
    await $.pumpAndSettle();

    await $(#smallImagePreview).waitUntilVisible();
  });
}
