import 'package:permission_handler/permission_handler.dart';

import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('accepts location permission', ($) async {
    await createApp($);

    await $('Open location screen').scrollTo().tap();

    expect(true, equals(false)); // FIXME: dummy assertion

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
    }

    expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
    expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
  });
}
