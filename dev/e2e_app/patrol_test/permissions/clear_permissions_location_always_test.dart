import 'package:e2e_app/keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _iterations = 3;
const _dialogTimeout = Duration(seconds: 10);

// Run alone, from a fresh install, with `--clear-permissions`: every case must
// see both location dialogs again.
void main() {
  for (var i = 1; i <= _iterations; i++) {
    patrol('grants location when in use, then always ($i of $_iterations)', (
      $,
    ) async {
      expect(await Permission.locationWhenInUse.isGranted, isFalse);
      expect(await Permission.locationAlways.isGranted, isFalse);

      await createApp($);
      await $('Open permissions screen').scrollTo().tap();

      await $(K.requestLocationPermissionButton).scrollTo().tap();
      expect(
        await $.platform.mobile.isPermissionDialogVisible(
          timeout: _dialogTimeout,
        ),
        isTrue,
        reason: 'When In Use dialog not shown',
      );
      await $.platform.mobile.grantPermissionWhenInUse();
      await $(
        K.locationPermissionTile,
      ).$(K.statusText).$('Granted').waitUntilVisible();

      await $(K.requestLocationAlwaysPermissionButton).scrollTo().tap();
      await $.platform.ios.tap(
        IOSSelector(label: 'Change to Always Allow'),
        appId: 'com.apple.springboard',
        timeout: _dialogTimeout,
      );
      // permission_handler completes the Always request before the user
      // answers, so read the status again instead of trusting the tile.
      expect(await _waitForLocationAlways(), isTrue);
    }, tags: ['ios', 'clear_permissions_location_always']);
  }
}

Future<bool> _waitForLocationAlways() async {
  final deadline = DateTime.now().add(_dialogTimeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await Permission.locationAlways.isGranted) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  return false;
}
