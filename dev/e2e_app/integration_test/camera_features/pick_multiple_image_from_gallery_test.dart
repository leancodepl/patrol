import 'dart:io';

import 'package:flutter/material.dart';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('pick multiple images from gallery', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);
    // debugPrint('getNativeViews2: ${await $.native2.getNativeViews(null)}');
    debugPrint('getNativeViews: ${await $.native.getNativeViews(null)}');
    if (await $.native.isVirtualDevice() && Platform.isAndroid) {
      await cameraHelpers.takePhotosAcceptDialogsAndOpenAppOnEmulator();
    } else if (Platform.isAndroid) {
      await cameraHelpers
          .takePhotosAcceptDialogsAndOpenAppOnRealDeviceAndroid();
    }
    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#pickMultiplePhotosButton).tap();
    if (await $.native.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native.grantPermissionWhenInUse();
    }
    await $.native.pickMultipleImagesFromGallery(imageIndexes: [0, 2]);

    await $.pumpAndSettle();
    await $(#selectedPhotosCount).$('2 photos selected').waitUntilVisible();
  });
}
