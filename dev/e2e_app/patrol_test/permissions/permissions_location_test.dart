import 'dart:io' as io;

import 'package:e2e_app/keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol(
    'accepts location permission',
    ($) async {
      await createApp($);

      await $('Open location screen').scrollTo().tap();

      if (!await Permission.location.isGranted) {
        expect($('Permission not granted'), findsOneWidget);
        await $(K.grantLocationPermissionButton).tap();
        if (await $.platform.mobile.isPermissionDialogVisible(
          timeout: _timeout,
        )) {
          if (io.Platform.isAndroid) {
            await $.platform.mobile.selectCoarseLocation();
            await $.platform.mobile.selectFineLocation();
            await $.platform.mobile.selectCoarseLocation();
            await $.platform.mobile.selectFineLocation();
          }
          await $.platform.mobile.grantPermissionOnlyThisTime();
        }

        try {
          await $.platform.mobile.tap(Selector(text: 'Turn on'));
        } catch (_) {
          // ignore
        }
      }

      expect(
        // timeout duration is increased here as the location service on CI
        await $(RegExp('lat')).waitUntilVisible(timeout: Duration(seconds: 30)),
        findsOneWidget,
      );
      expect(
        // timeout duration is increased here as the location service on CI
        // needs more time to start up
        await $(RegExp('lng')).waitUntilVisible(timeout: Duration(seconds: 30)),
        findsOneWidget,
      );
    },
    tags: [
      'android',
      'ios',
      'emulator',
      'simulator',
      'not_on_ios_physical_device',
    ],
  );
}
