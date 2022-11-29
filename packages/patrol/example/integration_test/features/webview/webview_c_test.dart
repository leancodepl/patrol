import '../../common.dart';

Future<void> main() async {
  testWebViewC();
}

void testWebViewC() {
  patrol(
    'interacts with the StackOverflow website in a webview',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open webview screen C').scrollTo().tap();

      await $.native.tap(Selector(text: 'Accept all cookies'));
      await $.native.tap(Selector(text: 'Log in'));

      await $.pump(Duration(seconds: 2));

      // bug: using `Email` and `Password` selectors doesn't work
      await $.native.enterTextByIndex('test@leancode.pl', index: 0);

      // Got to hide keyboard on iOS
      await $.native.tap(Selector(text: 'Done'));

      await $.native.enterTextByIndex('ny4ncat', index: 1);
      await $.native.tap(Selector(text: 'Log in'));
    },
  );
}
