// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io' as io;

import 'package:e2e_app/keys.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

// Firebase Test Lab pops out another dialog we need to handle
Future<void> tapOkIfGoogleDialogAppears(PatrolIntegrationTester $) async {
  await $.pump(Duration(seconds: 10));

  var listWithOkText = <NativeView>[];
  final inactivityTimer = Timer(Duration(seconds: 10), () {});

  while (listWithOkText.isEmpty && io.Platform.isAndroid) {
    listWithOkText = await $.platform.action.mobile(
      android: () async => (await $.platform.android.getNativeViews(
        AndroidSelector(textContains: 'OK'),
      )).roots.map(NativeView.fromAndroid).toList(),
      ios: () async => (await $.platform.ios.getNativeViews(
        IOSSelector(labelContains: 'OK'),
      )).roots.map(NativeView.fromIOS).toList(),
    );
    final timeoutReached = !inactivityTimer.isActive;
    if (timeoutReached) {
      inactivityTimer.cancel();
      break;
    }
  }
  if (listWithOkText.isNotEmpty) {
    await $.platform.mobile.tap(Selector(text: 'OK'));
  }
}

Future<void> tapOkIfGoogleDialogAppearsV2(PatrolIntegrationTester $) async {
  var listWithOkText = <AndroidNativeView>[];
  final inactivityTimer = Timer(Duration(seconds: 10), () {});

  while (listWithOkText.isEmpty && io.Platform.isAndroid) {
    final androidViews = await $.platform.android.getNativeViews(
      AndroidSelector(textContains: 'OK'),
    );
    listWithOkText = androidViews.roots;

    final timeoutReached = !inactivityTimer.isActive;
    if (timeoutReached) {
      inactivityTimer.cancel();
      break;
    }
  }
  if (listWithOkText.isNotEmpty) {
    await $.platform.android.tap(AndroidSelector(text: 'OK'));
  }
}

void main() {
  patrol('accepts location permission', ($) async {
    await createApp($);

    await $('Open location screen').scrollTo().tap();

    if (!await Permission.location.isGranted) {
      expect($('Permission not granted'), findsOneWidget);
      await $(K.grantLocationPermissionButton).tap();
      if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
        await $.platform.mobile.selectCoarseLocation();
        await $.platform.mobile.selectFineLocation();
        await $.platform.mobile.selectCoarseLocation();
        await $.platform.mobile.selectFineLocation();
        await $.platform.mobile.grantPermissionOnlyThisTime();
      }

      await tapOkIfGoogleDialogAppears($);
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
      if (await $.platform.mobile.isPermissionDialogVisible(timeout: _timeout)) {
        await $.platform.mobile.selectCoarseLocation();
        await $.platform.mobile.selectFineLocation();
        await $.platform.mobile.selectCoarseLocation();
        await $.platform.mobile.selectFineLocation();
        await $.platform.mobile.grantPermissionOnlyThisTime();
      }
      await tapOkIfGoogleDialogAppearsV2($);
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
