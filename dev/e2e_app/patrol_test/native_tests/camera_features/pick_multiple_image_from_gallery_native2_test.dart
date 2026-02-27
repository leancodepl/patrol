// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('pick multiple images from gallery - native2', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);
    final isVirtualDevice = await $.native2.isVirtualDevice();
    if (await $.native2.isVirtualDevice() && Platform.isAndroid) {
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
    await $.native2.pickMultipleImagesFromGallery(imageIndexes: [0, 1]);

    await $.pumpAndSettle();
    await $(#selectedPhotosCount).$('2 photos selected').waitUntilVisible();
  }, tags: ['android', 'emulator', 'physical_device', 'ios']);
}
