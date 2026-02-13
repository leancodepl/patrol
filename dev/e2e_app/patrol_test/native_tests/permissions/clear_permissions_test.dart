// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'package:e2e_app/keys.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('grants various permissions', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
    await _requestAndGrantMicrophonePermission($);
    await _requestAndGrantLocationPermission($);
    await _requestAndGrantGalleryPermission($);
  });

  patrol('grants various permissions 2', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
    await _requestAndGrantMicrophonePermission($);
    await _requestAndGrantLocationPermission($);
    await _requestAndGrantGalleryPermission($);
  });
}

Future<void> _requestAndGrantCameraPermission(PatrolIntegrationTester $) async {
  expect($(K.cameraPermissionTile).$(K.statusText).text, 'Not granted');
  await $(K.requestCameraPermissionButton).tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionWhenInUse();
    await $.pump();
  }
}

Future<void> _requestAndGrantMicrophonePermission(
  PatrolIntegrationTester $,
) async {
  expect($(K.microphonePermissionTile).$(K.statusText).text, 'Not granted');
  await $(K.requestMicrophonePermissionButton).tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionOnlyThisTime();
    await $.pump();
  }
}

Future<void> _requestAndGrantLocationPermission(
  PatrolIntegrationTester $,
) async {
  expect($(K.locationPermissionTile).$(K.statusText).text, 'Not granted');
  await $(K.requestLocationPermissionButton).tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionOnlyThisTime();
    await $.pump();
  }
}

Future<void> _requestAndGrantGalleryPermission(
  PatrolIntegrationTester $,
) async {
  expect($(K.galleryPermissionTile).$(K.statusText).text, 'Not granted');
  await $(K.requestGalleryPermissionButton).tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionWhenInUse();
    await $.pump();
  }
}
