import 'package:e2e_app/keys.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('grants various permissions', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    expect($(K.cameraPermissionTile).$(K.statusText).text, 'Not granted');
    await $(K.requestCameraPermissionButton).tap();
    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.grantPermissionWhenInUse();
      await $.pump();
    }

    expect($(K.microphonePermissionTile).$(K.statusText).text, 'Not granted');
    await $(K.requestMicrophonePermissionButton).tap();
    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.grantPermissionOnlyThisTime();
      await $.pump();
    }

    expect($(K.locationPermissionTile).$(K.statusText).text, 'Not granted');
    await $(K.requestLocationPermissionButton).tap();
    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.grantPermissionOnlyThisTime();
      await $.pump();
    }

    expect($(K.galleryPermissionTile).$(K.statusText).text, 'Not granted');
    await $(K.requestGalleryPermissionButton).tap();
    if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
      await $.platform.mobile.grantPermissionOnlyThisTime();
      await $.pump();
    }
  });
}
