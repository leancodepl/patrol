import 'common.dart';

Future<void> main() async {
  testWebViewA();
}

void testWebViewA() {
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $('Open webview screen A').scrollTo().tap();

    await $.native.tap(Selector(text: 'Accept cookies'));
    await $.native.tap(Selector(text: 'What do you do in IT?', instance: 1));
    await $.native.tap(Selector(text: 'Developer'));
    await $.native.tap(Selector(text: '1 item selected'));
    await $.native.enterTextByIndex('test@leancode.pl', index: 0);
  });
}
