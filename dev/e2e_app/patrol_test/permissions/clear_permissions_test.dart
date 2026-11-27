import 'package:e2e_app/keys.dart';
import 'package:flutter/widgets.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol(
    'grants various permissions',
    _grantVariousPermissions,
    tags: ['android', 'ios', 'physical_device', 'emulator', 'simulator'],
  );

  // Same body: whichever runs second fails if permissions aren't cleared.
  patrol(
    'grants various permissions 2',
    _grantVariousPermissions,
    tags: ['android', 'ios', 'physical_device', 'emulator', 'simulator'],
  );
}

Future<void> _grantVariousPermissions(PatrolIntegrationTester $) async {
  await createApp($);

  await $('Open permissions screen').scrollTo().tap();

  await _requestAndGrant(
    $,
    tile: K.cameraPermissionTile,
    button: K.requestCameraPermissionButton,
    grant: $.platform.mobile.grantPermissionWhenInUse,
  );
  await _requestAndGrant(
    $,
    tile: K.microphonePermissionTile,
    button: K.requestMicrophonePermissionButton,
    grant: $.platform.mobile.grantPermissionOnlyThisTime,
  );
  await _requestAndGrant(
    $,
    tile: K.locationPermissionTile,
    button: K.requestLocationPermissionButton,
    grant: $.platform.mobile.grantPermissionOnlyThisTime,
  );
  await _requestAndGrant(
    $,
    tile: K.galleryPermissionTile,
    button: K.requestGalleryPermissionButton,
    grant: $.platform.mobile.grantPermissionWhenInUse,
  );
}

// Wait for 'Granted' before the next request; permission_handler rejects a new
// request while the previous one is still in flight.
Future<void> _requestAndGrant(
  PatrolIntegrationTester $, {
  required Key tile,
  required Key button,
  required Future<void> Function() grant,
}) async {
  expect($(tile).$(K.statusText).text, 'Not granted');
  await $(button).tap();
  if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
    await grant();
    await $(tile).$('Granted').waitUntilVisible();
  }
}
