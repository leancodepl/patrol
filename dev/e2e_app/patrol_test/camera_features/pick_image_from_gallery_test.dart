import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('pick image from gallery - native', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);
    final isVirtualDevice = await $.platform.mobile.isVirtualDevice();
    if (isVirtualDevice && Platform.isAndroid) {
      await cameraHelpers.takePhotosAcceptDialogsAndOpenAppOnEmulator();
    } else if (Platform.isAndroid) {
      await cameraHelpers
          .takePhotosAcceptDialogsAndOpenAppOnRealDeviceAndroid();
    } else if (Platform.isIOS && !isVirtualDevice) {
      await cameraHelpers.takePhotosAcceptDialogsAndOpenAppOnRealDeviceIOS();
    }
    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#chooseFromGalleryButton).tap();
    await cameraHelpers.maybeAcceptPermissionDialog();
    await $.platform.mobile.pickImageFromGallery(index: 1);
    await $.pumpAndSettle();

    await $(#smallImagePreview).waitUntilVisible();
  });
}
