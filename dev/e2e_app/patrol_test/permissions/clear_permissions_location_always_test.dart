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
      await _tapChangeToAlwaysAllow($);
      // permission_handler completes the Always request before the user
      // answers, so read the status again instead of trusting the tile.
      expect(await _waitForLocationAlways(), isTrue);
    }, tags: ['ios', 'clear_permissions_location_always']);
  }
}

// Patrol has no API for the Always upgrade dialog; tap its button by label.
const _changeToAlwaysAllowLabels = [
  'Change to Always Allow',
  'Zmień na Zawsze pozwalaj',
];

Future<void> _tapChangeToAlwaysAllow(PatrolIntegrationTester $) async {
  final deadline = DateTime.now().add(_dialogTimeout);
  while (DateTime.now().isBefore(deadline)) {
    for (final label in _changeToAlwaysAllowLabels) {
      try {
        await $.platform.ios.tap(
          IOSSelector(label: label),
          appId: 'com.apple.springboard',
          timeout: const Duration(seconds: 1),
        );
        return;
      } on Exception {
        // Not this language, or the dialog isn't up yet.
      }
    }
  }
  fail('"Change to Always Allow" dialog not shown');
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
