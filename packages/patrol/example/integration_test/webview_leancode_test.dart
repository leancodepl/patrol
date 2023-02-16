import 'common.dart';

Future<void> main() async {
  testWebViewA();
}

void testWebViewA() {
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $('Open webview screen A').scrollTo().tap();

    await $.native.enterTextByIndex('test@hey.com', index: 0);
    await $.native.enterTextByIndex('some pass', index: 1);
    await $.native.tap(Selector(text: 'Done'));
    await $.native.tap(
      Selector(
        text: 'Log in',
        instance: 1,
      ),
    );
    // await $.native.enterText(
    //   Selector(text: 'user_email'), // "you@example.com", "Email", etc..
    //   text: 'bartek@awesome.com',
    // );
  });
}
