import 'dart:io' show Platform;

import 'common.dart';

Future<void> main() async {
  late String contactsAppId;
  if (Platform.isIOS) {
    contactsAppId = 'com.apple.MobileAddressBook';
  } else if (Platform.isAndroid) {
    contactsAppId = 'com.android.contacts';
  }

  patrol('taps on contacts', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.pressHome();
    await $.native.openApp(appId: contactsAppId);
    await $.native.tap(
      Selector(text: 'Andrzej', instance: 0),
      appId: contactsAppId,
    );
    if (Platform.isIOS) {
      await $.native.tap(Selector(text: 'iPhone'), appId: contactsAppId);
    } else {
      await $.native.pressBack();
    }
    await $.native.tap(
      Selector(text: 'Andrzej', instance: 1),
      appId: contactsAppId,
    );
    if (Platform.isIOS) {
      await $.native.tap(
        Selector(text: 'iPhone'),
        appId: contactsAppId,
      );
    } else {
      await $.native.pressBack();
    }
  });
}
