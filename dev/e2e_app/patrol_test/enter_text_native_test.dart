import 'common.dart';

void main() {
  patrol('enterText works with elementType selectors on iOS', ($) async {
    await createApp($);

    await $('Open webview (Hacker News)').scrollTo().tap();

    await $.pump(Duration(seconds: 5));

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
