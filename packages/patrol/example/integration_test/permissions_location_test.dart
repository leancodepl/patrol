import 'dart:async';

import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

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
        await $.native.grantPermissionWhenInUse();
      }
      await $.pump();

      // Firebase Test Lab pops out another dialog we need to handle
      var listWithOkText = <NativeView>[];
      final inactivityTimer = Timer(_timeout, () {});

      while (listWithOkText.isNotEmpty) {
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

    expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
    expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
  });
}
