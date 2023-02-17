import 'common.dart';

void main() {
  patrol('interacts with the orange website in a webview', ($) async {
    await createApp($);

    await $('Open webview (Hacker News)').scrollTo().tap();

    await $.native.tap(Selector(text: 'login'));
    await $.native.enterTextByIndex('charlie@root.me', index: 0);
    await $.native.enterTextByIndex('ny4ncat', index: 1);
    await $.native.tap(Selector(text: 'login'));
  });
}
