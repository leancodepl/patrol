import 'common.dart';

void main() {
  patrol('interacts with the contacts app', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $.native.openApp(appId: 'com.google.android.contacts');
    await $.native.tap(Selector(text: 'Andrzej', instance: 0));
    await $.native.pressBack();
    await $.native.tap(Selector(text: 'Andrzej', instance: 1));
    await $.native.pressBack();
  });
}
