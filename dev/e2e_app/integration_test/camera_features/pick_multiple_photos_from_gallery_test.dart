import 'package:flutter/material.dart';

import '../common.dart';

void main() {
  patrol('pick multiple images from gallery', ($) async {
    await createApp($);
    if (await $.native2.isSimulator()) {
      await $.native.openApp(appId: 'com.android.camera2');
      await $.native.tap(Selector(text: "NEXT"));
      if (await $.native2.isPermissionDialogVisible(
        timeout: const Duration(seconds: 4),
      )) {
        await $.native2.grantPermissionWhenInUse();
      }
      await $.native
          .tap(Selector(resourceId: 'com.android.camera2:id/shutter_button'));
      await $.native
          .tap(Selector(resourceId: 'com.android.camera2:id/shutter_button'));

      await Future.delayed(const Duration(seconds: 8));

      await $.native.openApp(appId: 'pl.leancode.patrol.e2e_app');
    } else {
      await $.native.openApp(appId: 'com.google.android.GoogleCamera');
      if (await $.native2.isPermissionDialogVisible(
        timeout: const Duration(seconds: 4),
      )) {
        await $.native2.grantPermissionWhenInUse();
      }
      await $.native.tap(Selector(text: "Done"));
      await $.native.tap(Selector(
          resourceId: 'com.google.android.GoogleCamera:id/shutter_button'));
      await $.native.tap(Selector(
          resourceId: 'com.google.android.GoogleCamera:id/shutter_button'));
      await $.native.tap(Selector(
          resourceId: 'com.google.android.GoogleCamera:id/shutter_button'));
      await Future.delayed(const Duration(seconds: 8));
      await $.native.openApp(appId: 'pl.leancode.patrol.e2e_app');
    }
    await $(#cameraFeaturesButton).scrollTo().tap();
    await $(#pickMultiplePhotosButton).tap();
    if (await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 4),
    )) {
      await $.native2.grantPermissionWhenInUse();
    }
    final nativeViews = await $.native.getNativeViews(null);
    $.log('nativeViews: $nativeViews');
    debugPrint('nativeViews: $nativeViews', wrapWidth: 1000);
    await $.native2.pickMultipleImagesFromGallery(2);

    await $.pumpAndSettle();
    await $(#selectedPhotosCount).$('2 photos selected').waitUntilVisible();
  });
}
