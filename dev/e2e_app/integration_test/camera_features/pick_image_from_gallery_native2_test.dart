import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('pick image from gallery - native2', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);
    if (await $.native2.isVirtualDevice() && Platform.isAndroid) {
      await cameraHelpers.takePhotosAcceptDialogsAndOpenAppOnEmulator();
    } else if (Platform.isAndroid) {
      await cameraHelpers
          .takePhotosAcceptDialogsAndOpenAppOnRealDeviceAndroid();
    }
    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#chooseFromGalleryButton).tap();
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
    await $.native2.pickImageFromGallery(index: 1);
    await $.pumpAndSettle();

    await $(#smallImagePreview).waitUntilVisible();
  });
}
