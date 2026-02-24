import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('camera with injected image on BrowserStack', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    await $('Take a photo').tap();

    expect($(Placeholder), findsOneWidget);

    await $('Open camera').tap();

    if (!Platform.isMacOS && !kIsWeb) {
      if (await $.platform.mobile.isPermissionDialogVisible()) {
        await $.platform.mobile.grantPermissionWhenInUse();
      }

      // Inject the image before triggering the camera capture.
      // the image with the specified name must have been uploaded to BrowserStack
      // and included in the cameraInjectionMedia capability.
      await $.platform.ios.injectCameraPhoto(imageName: 'flower.jpg');

      // Take the camera photo as usual. The app will receive the
      // injected image instead of real camera input.
      await $.platform.mobile.takeCameraPhoto();

      await $.pumpAndSettle(duration: const Duration(seconds: 1));

      expect($(Placeholder), findsNothing);
      expect($(Image), findsOneWidget);
    }
  });
}
