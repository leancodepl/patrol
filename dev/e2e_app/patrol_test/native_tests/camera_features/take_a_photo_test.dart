// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import '../common.dart';
import 'camera_helpers.dart';

void main() {
  patrol('take a photo', ($) async {
    await createApp($);
    final cameraHelpers = CameraHelpers($);
    await $(#cameraFeaturesButton).scrollTo().tap();
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      throw Exception('Camera is not supported on iOS simulator');
    }
    await $(#takePhotoButton).tap();
    await cameraHelpers.maybeAcceptPermissionDialog();
    await cameraHelpers.maybeAcceptDialogAndroid();

    await $.native.takeCameraPhoto();
    await $.pumpAndSettle();
    await $(#smallImagePreview).waitUntilVisible();
  }, tags: ['android', 'emulator', 'physical_device', 'ios']);
}
