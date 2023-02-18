import 'common.dart';

void main() async {
  patrol('interacts with the login form website in a webview', ($) async {
    await createApp($);

    await $('Open webview (login form)').scrollTo().tap();

    await $.native.enterTextByIndex('test@hey.com', index: 0);
    await $.native.enterTextByIndex('some pass', index: 1);
    await $.native.tap(Selector(text: 'Sign in'));
  });
}
