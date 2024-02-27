import 'dart:async';
import 'dart:io' as io;

import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

// Firebase Test Lab pops out another dialog we need to handle
Future<void> tapOkIfGoogleDialogAppears(PatrolIntegrationTester $) async {
  var listWithOkText = <NativeView>[];
  final inactivityTimer = Timer(Duration(seconds: 10), () {});

  while (listWithOkText.isEmpty && io.Platform.isAndroid) {
    listWithOkText =
        await $.native.getNativeViews(Selector(textContains: 'OK'));
    final timeoutReached = !inactivityTimer.isActive;
    if (timeoutReached) {
      inactivityTimer.cancel();
      break;
    }
  }
  if (listWithOkText.isNotEmpty) {
    await $.native.tap(Selector(text: 'OK'));
  }
}

Future<void> tapOkIfGoogleDialogAppearsV2(PatrolIntegrationTester $) async {
  var listWithOkText = <AndroidNativeView>[];
  final inactivityTimer = Timer(Duration(seconds: 10), () {});

  while (listWithOkText.isEmpty && io.Platform.isAndroid) {
    final nativeViews = await $.native2.getNativeViews(
      NativeSelector(android: AndroidSelector(textContains: 'OK')),
    );
    listWithOkText = nativeViews.androidViews;

    final timeoutReached = !inactivityTimer.isActive;
    if (timeoutReached) {
      inactivityTimer.cancel();
      break;
    }
  }
  if (listWithOkText.isNotEmpty) {
    await $.native2.tap(NativeSelector(android: AndroidSelector(text: 'OK')));
  }
}

void main() {
  patrol('accepts location permission', ($) async {
    await createApp($);

    await $('Open location screen').scrollTo().tap();

    if (!await Permission.location.isGranted) {
      expect($('Permission not granted'), findsOneWidget);
      await $('Grant permission').tap();
      if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
        await $.native.selectCoarseLocation();
        await $.native.selectFineLocation();
        await $.native.selectCoarseLocation();
        await $.native.selectFineLocation();
        await $.native.grantPermissionOnlyThisTime();
      }
      await $.pump();

      await tapOkIfGoogleDialogAppears($);
    }

    expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
    expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
  });

  patrol('accepts location permission native2', ($) async {
    await createApp($);

    await $('Open location screen').scrollTo().tap();

    if (!await Permission.location.isGranted) {
      expect($('Permission not granted'), findsOneWidget);
      await $('Grant permission').tap();
      if (await $.native2.isPermissionDialogVisible(timeout: _timeout)) {
        await $.native2.selectCoarseLocation();
        await $.native2.selectFineLocation();
        await $.native2.selectCoarseLocation();
        await $.native2.selectFineLocation();
        await $.native2.grantPermissionOnlyThisTime();
      }
      await $.pump();

      await tapOkIfGoogleDialogAppearsV2($);
    }

    expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
    expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
  });
}
