import 'common.dart';

void main() async {
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await createApp($);
    await $('Open webview (LeanCode)').scrollTo().tap();
    await $.native.tap(Selector(text: 'Accept cookies'));

    // open dropdown
    await $.native.tap(Selector(text: 'What do you do in IT?', instance: 1));

    // select option in dropdown
    await $.native.tap(Selector(text: 'Developer'));

    // close dropdown
    await $.native.tap(Selector(text: 'What do you do in IT?', instance: 1));

    await $.native.enterTextByIndex('test@leancode.pl', index: 0);
  });
}
