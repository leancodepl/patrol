import 'common.dart';

void main() {
  const app1 = 'com.apple.MobileAddressBook';
  const app2 = 'pl.baftek.Landmarks';
  patrol(
    'interacts with the contacts app',
    skip: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());
      await $.native.openApp(appId: 'com.google.android.contacts');
      await $.native.tap(Selector(text: 'Andrzej', instance: 0));
      await $.native.pressBack();
      await $.native.tap(Selector(text: 'Andrzej', instance: 1));
      await $.native.pressBack();
    },
  );

  patrol(
    'interacts with the contacts app on iOS',
    skip: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());
      await $.native.openApp(appId: app1);
      await $.native.tap(Selector(text: 'Andrzej', instance: 0), appId: app1);
      await $.native.tap(Selector(text: 'Back'), appId: app1);
      await $.native.tap(Selector(text: 'Andrzej', instance: 1), appId: app1);
      await $.native.tap(Selector(text: 'Contacts'), appId: app1);
    },
  );

  patrol('interacts with the Landmarks app', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $.native.openApp(appId: app2);
    //await $.native.tap(Selector(text: 'Andrzej', instance: 0), appId: app2);
    //await $.native.tap(Selector(text: 'Edit'), appId: app2);
    await $.native.enterTextByIndex('BaftekPro', index: 0, appId: app2);
    await $.native.enterTextByIndex('LeanCode', index: 1, appId: app2);
    await $.native.enterTextByIndex('bartek@lncd.pl', index: 2, appId: app2);
    await $.native.tap(Selector(text: 'Landmarks'), appId: app2);
    await $.native.tap(Selector(text: 'Landmarks', instance: 1), appId: app2);
    await $.native.tap(Selector(text: 'Landmarks', instance: 1), appId: app2);
    await $.native.tap(Selector(text: 'Landmarks', instance: 1), appId: app2);
    await $.native.tap(Selector(text: 'Landmarks', instance: 1), appId: app2);
  });
}
