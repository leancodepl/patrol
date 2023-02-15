import 'common.dart';

Future<void> main() async {
  testWebViewA();
}

void testWebViewA() {
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $('Open webview screen A').scrollTo().tap();

    print('AAAAAA');

    for (var i = 0; i < 300; i++) {
      await $.pump();
    }
    print('BBBBBB');

    await $.native.enterTextByIndex(
      'barpac02@gmail.com',
      index: 0,
    );
    await $.native.enterTextByIndex(
      'ny4ncat',
      index: 1,
    );
    await $.native.tap(Selector(text: 'Log in'));
  });
}
