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
      await $.pump(Duration(seconds: 2));
      // Firebase Test Lab pops out another dialog we need to handle
      final listWithOkText =
          await $.native.getNativeViews(Selector(textContains: "OK"));
      if (listWithOkText.isNotEmpty) {
        await $.native.tap(Selector(text: "OK"));
      }
    }

    expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
    expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
  });
}
