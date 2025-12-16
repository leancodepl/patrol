// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'package:e2e_app/keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('denies various permissions', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    // Duplicated methods because we want to be sure that permission is denied
    await $.pumpAndSettle(duration: Duration(seconds: 12));
    await _requestAndDenyCameraPermission($);
    await _requestAndDenyCameraPermission($);

    await _requestAndDenyMicrophonePermission($);
    await _requestAndDenyMicrophonePermission($);

    await _requestAndDenyLocationPermission($);
    await _requestAndDenyLocationPermission($);

    await _requestAndDenyGalleryPermission($);
    await _requestAndDenyGalleryPermission($);
  }, tags: ['locale_testing_ios']);
}

Future<void> _requestAndDenyCameraPermission(PatrolIntegrationTester $) async {
  if (!await Permission.camera.isGranted) {
    expect($(K.cameraPermissionTile).$(#statusText).text, 'Not granted');
    await $(K.requestCameraPermissionButton).tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.denyPermission();
      await $.pump();
    }
  }

  expect($(K.cameraPermissionTile).$(#statusText).text, 'Not granted');
}

Future<void> _requestAndDenyMicrophonePermission(
  PatrolIntegrationTester $,
) async {
  if (!await Permission.microphone.isGranted) {
    expect($(K.microphonePermissionTile).$(#statusText).text, 'Not granted');
    await $(K.requestMicrophonePermissionButton).tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.denyPermission();
      await $.pump();
    }
  }

  expect($(K.microphonePermissionTile).$(#statusText).text, 'Not granted');
}

Future<void> _requestAndDenyLocationPermission(
  PatrolIntegrationTester $,
) async {
  if (!await Permission.location.isGranted) {
    expect($(K.locationPermissionTile).$(#statusText).text, 'Not granted');
    await $(K.requestLocationPermissionButton).tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.denyPermission();
      await $.pump();
    }
  }

  expect($(K.locationPermissionTile).$(#statusText).text, 'Not granted');
}

Future<void> _requestAndDenyGalleryPermission(PatrolIntegrationTester $) async {
  if (!await Permission.storage.isGranted) {
    expect($(K.galleryPermissionTile).$(#statusText).text, 'Not granted');
    await $(K.requestGalleryPermissionButton).tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.denyPermission();
      await $.pump();
    }
  }

  expect($(K.galleryPermissionTile).$(#statusText).text, 'Not granted');
}
