import 'package:e2e_app/keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _dialogTimeout = Duration(seconds: 10);

// Run alone, from a fresh install, with `--clear-permissions`: the second case
// checks that the reset also clears a denied location permission.
void main() {
  patrol('denies location', ($) async {
    await createApp($);
    await $('Open permissions screen').scrollTo().tap();

    await $(K.requestLocationPermissionButton).scrollTo().tap();
    expect(
      await $.platform.mobile.isPermissionDialogVisible(
        timeout: _dialogTimeout,
      ),
      isTrue,
    );
    await $.platform.mobile.denyPermission();
    await $.pump();
    expect(
      await Permission.locationWhenInUse.status,
      PermissionStatus.permanentlyDenied,
    );
  }, tags: ['ios', 'clear_permissions_denied_location']);

  patrol('asks for location again after a denial', ($) async {
    final status = await Permission.locationWhenInUse.status;
    print('Location status after reset: $status');
    expect(status, PermissionStatus.denied);

    await createApp($);
    await $('Open permissions screen').scrollTo().tap();

    await $(K.requestLocationPermissionButton).scrollTo().tap();
    expect(
      await $.platform.mobile.isPermissionDialogVisible(
        timeout: _dialogTimeout,
      ),
      isTrue,
      reason: 'Location dialog not shown after a denial',
    );
    await $.platform.mobile.grantPermissionWhenInUse();
  }, tags: ['ios', 'clear_permissions_denied_location']);
}
