import 'common.dart';

Future<void> main() async {
  testWebViewB();
}

void testWebViewB() {
  patrol('interacts with the orange website in a webview', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $('Open webview (Hacker News').scrollTo().tap();

    await $.native.tap(Selector(text: 'login'));
    await $.native.enterTextByIndex('test@leancode.pl', index: 0);
    await $.native.enterTextByIndex('ny4ncat', index: 1);
  });
}
