import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('pick multiple images from gallery - native2', ($) async {
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
    // Works on API LVL 33
    await $.native2.pickMultipleImagesFromGallery(imageIndexes: [0, 1]);

    await $.pumpAndSettle();
    await $(#selectedPhotosCount).$('2 photos selected').waitUntilVisible();
  });
}
