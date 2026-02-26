import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol(
    'pick multiple images from gallery',
    ($) async {
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
      await $(#pickMultiplePhotosButton).tap();
      await cameraHelpers.maybeAcceptPermissionDialog();
      await $.platform.mobile.pickMultipleImagesFromGallery(
        imageIndexes: [0, 2],
      );

      await $.pumpAndSettle();
      await $(#selectedPhotosCount).$('2 photos selected').waitUntilVisible();
    },
    tags: ['android', 'ios', 'emulator', 'simulator'],
  );
}
