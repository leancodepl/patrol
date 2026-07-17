import 'common.dart';

void main() {
  patrol('enterText works with elementType selectors on iOS', ($) async {
    await createApp($);

    await $('Open webview (Hacker News)').scrollTo().tap();

    // The Hacker News page is loaded into the webview over the network. Wait
    // for its content to actually render instead of racing a fixed delay,
    // which is flaky on CI when the page is slow to load.
    await $.platform.mobile.waitUntilVisible(Selector(text: 'login'));
    await $.platform.mobile.tap(Selector(text: 'login'));
    await $.platform.ios.enterText(
      IOSSelector(elementType: IOSElementType.textField),
      text: 'test@leancode.pl',
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.platform.ios.enterText(
      IOSSelector(elementType: IOSElementType.secureTextField),
      text: 'ny4ncat',
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
  }, tags: ['webview', 'ios']);
}
