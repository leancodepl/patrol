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
  }, tags: ['android', 'emulator', 'ios', 'simulator']);

  patrol('grants various permissions 2', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
    await _requestAndGrantMicrophonePermission($);
    await _requestAndGrantLocationPermission($);
    await _requestAndGrantGalleryPermission($);
  }, tags: ['android', 'emulator', 'ios', 'simulator']);
}

// The permission_handler plugin keeps a single in-flight request, so requesting
// the next permission before the previous one finishes throws "a request is
// already running" (flaky on slower emulators, e.g. API 32). Pumping a single
// frame after granting isn't enough because the native result may not have
// propagated yet, so we wait until the tile reports 'Granted' before returning.
Future<void> _requestAndGrantCameraPermission(PatrolIntegrationTester $) async {
  expect($(K.cameraPermissionTile).$(K.statusText).text, 'Not granted');
  await $(K.requestCameraPermissionButton).tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionWhenInUse();
    await $(K.cameraPermissionTile).$('Granted').waitUntilVisible();
  }
}

Future<void> _requestAndGrantMicrophonePermission(
  PatrolIntegrationTester $,
) async {
  expect($(K.microphonePermissionTile).$(K.statusText).text, 'Not granted');
  await $(K.requestMicrophonePermissionButton).tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionOnlyThisTime();
    await $(K.microphonePermissionTile).$('Granted').waitUntilVisible();
  }
}

Future<void> _requestAndGrantLocationPermission(
  PatrolIntegrationTester $,
) async {
  expect($(K.locationPermissionTile).$(K.statusText).text, 'Not granted');
  await $(K.requestLocationPermissionButton).tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionOnlyThisTime();
    await $(K.locationPermissionTile).$('Granted').waitUntilVisible();
  }
}

Future<void> _requestAndGrantGalleryPermission(
  PatrolIntegrationTester $,
) async {
  expect($(K.galleryPermissionTile).$(K.statusText).text, 'Not granted');
  await $(K.requestGalleryPermissionButton).tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionWhenInUse();
    await $(K.galleryPermissionTile).$('Granted').waitUntilVisible();
  }
}
