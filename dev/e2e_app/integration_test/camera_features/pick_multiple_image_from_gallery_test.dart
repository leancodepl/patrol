import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('pick multiple images from gallery', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);

    if (await $.native2.isVirtualDevice() && Platform.isAndroid) {
      await cameraHelpers.takePhotosAcceptDialogsAndOpenAppOnEmulator();
    } else if (Platform.isAndroid) {
      await cameraHelpers
          .takePhotosAcceptDialogsAndOpenAppOnRealDeviceAndroid();
    }
    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#pickMultiplePhotosButton).tap();
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
    await $.native.pickMultipleImagesFromGallery(imageIndexes: [0, 2]);

    await $.pumpAndSettle();
    await $(#selectedPhotosCount).$('2 photos selected').waitUntilVisible();
  });
}
