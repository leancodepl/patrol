// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:e2e_app/keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('grants various permissions', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
    await _requestAndGrantMicrophonePermission($);
    await _requestAndDenyLocationPermission($);
    await _requestAndDenyGalleryPermission($);
  }, tags: ['locale_testing_ios']);
}

Future<void> _requestAndGrantCameraPermission(PatrolIntegrationTester $) async {
  if (!await Permission.camera.isGranted) {
    expect($(K.cameraPermissionTile).$(#statusText).text, 'Not granted');
    await $(K.requestCameraPermissionButton).tap();
    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.grantPermissionWhenInUse();
      await $.pump();
    }
  }

  expect($(K.cameraPermissionTile).$(#statusText).text, 'Granted');
}

Future<void> _requestAndGrantMicrophonePermission(
  PatrolIntegrationTester $,
) async {
  if (!await Permission.microphone.isGranted) {
    expect($(K.microphonePermissionTile).$(#statusText).text, 'Not granted');
    await $(K.requestMicrophonePermissionButton).tap();
    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.grantPermissionOnlyThisTime();
      await $.pump();
    }
  }

  expect($(K.microphonePermissionTile).$(#statusText).text, 'Granted');
}

Future<void> _requestAndDenyLocationPermission(
  PatrolIntegrationTester $,
) async {
  if (!await Permission.location.isGranted) {
    expect($(K.locationPermissionTile).$(#statusText).text, 'Not granted');
    await $(K.requestLocationPermissionButton).tap();
    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.denyPermission();
      await $.pump();
    }
  }

  expect($(K.locationPermissionTile).$(#statusText).text, 'Not granted');
}

Future<void> _requestAndDenyGalleryPermission(PatrolIntegrationTester $) async {
  if (Platform.isIOS) {
    if (!await Permission.photos.isGranted) {
      expect($(K.galleryPermissionTile).$(#statusText).text, 'Not granted');
      await $(K.requestGalleryPermissionButton).tap();
    }
  } else {
    if (!await Permission.storage.isGranted) {
      expect($(K.galleryPermissionTile).$(#statusText).text, 'Not granted');
      await $(K.requestGalleryPermissionButton).tap();
    }
  }
  if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
    await $.platform.mobile.denyPermission();
    await $.pump();
  }
  expect($(K.galleryPermissionTile).$(#statusText).text, 'Not granted');
}
