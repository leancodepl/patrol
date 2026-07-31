// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io' as io;
import 'package:e2e_app/keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('accepts location permission', ($) async {
    await createApp($);

    await $('Open location screen').scrollTo().tap();

    if (!await Permission.location.isGranted) {
      expect($('Permission not granted'), findsOneWidget);
      await $(K.grantLocationPermissionButton).tap();
      if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
        if (io.Platform.isAndroid) {
          await $.native.selectCoarseLocation();
          await $.native.selectFineLocation();
          await $.native.selectCoarseLocation();
          await $.native.selectFineLocation();
        }
        await $.native.grantPermissionOnlyThisTime();
      }

      try {
        await $.native.tap(Selector(text: 'Turn on'));
      } catch (_) {
        // ignore
      }
    }

    expect(
      // timeout duration is increased here as the location service on CI
      // needs more time to start up
      await $(RegExp('lat')).waitUntilVisible(timeout: Duration(seconds: 20)),
      findsOneWidget,
    );
    expect(
      // timeout duration is increased here as the location service on CI
      // needs more time to start up
      await $(RegExp('lng')).waitUntilVisible(timeout: Duration(seconds: 20)),
      findsOneWidget,
    );
  });

  patrol('accepts location permission native2', ($) async {
    await createApp($);

    await $('Open location screen').scrollTo().tap();

    if (!await Permission.location.isGranted) {
      expect($('Permission not granted'), findsOneWidget);
      await $(K.grantLocationPermissionButton).tap();
      if (await $.native2.isPermissionDialogVisible(timeout: _timeout)) {
        if (io.Platform.isAndroid) {
          await $.native2.selectCoarseLocation();
          await $.native2.selectFineLocation();
          await $.native2.selectCoarseLocation();
          await $.native2.selectFineLocation();
        }
        await $.native2.grantPermissionOnlyThisTime();
      }

      try {
        await $.native2.tap(
          NativeSelector(android: AndroidSelector(text: 'Turn on')),
        );
      } catch (_) {
        // ignore
      }
    }

    expect(
      // timeout duration is increased here as the location service on CI
      // needs more time to start up
      await $(RegExp('lat')).waitUntilVisible(timeout: Duration(seconds: 30)),
      findsOneWidget,
    );
    expect(
      // timeout duration is increased here as the location service on CI
      // needs more time to start up
      await $(RegExp('lng')).waitUntilVisible(timeout: Duration(seconds: 30)),
      findsOneWidget,
    );
  }, tags: ['locale_testing_ios']);
}
