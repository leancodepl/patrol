import 'common.dart';

void main() {
  patrol(
    'interacts with the orange website in a webview',
    ($) async {
    await createApp($);

    await $('Open webview (Hacker News)').scrollTo().tap();

    await $.pump(Duration(seconds: 5));

    await $.platform.mobile.tap(Selector(text: 'login'));
    await $.platform.mobile.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.platform.mobile.enterTextByIndex(
      'ny4ncat',
      index: 1,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
  }, tags: ['webview', 'android', 'ios']);

  patrol(
    'interacts with the orange website in a webview native2',
    ($) async {
    await createApp($);

    await $('Open webview (Hacker News)').scrollTo().tap();

    await $.pump(Duration(seconds: 5));

    await $.platform.mobile.tap(Selector(text: 'login'));
    await $.platform.mobile.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.platform.action.mobile(
      android: () => $.platform.android.enterText(
        AndroidSelector(className: 'android.widget.EditText'),
        text: 'ny4ncat',
        keyboardBehavior: KeyboardBehavior.showAndDismiss,
      ),
      ios: () => $.platform.ios.enterText(
        IOSSelector(elementType: IOSElementType.secureTextField),
        text: 'ny4ncat',
        keyboardBehavior: KeyboardBehavior.showAndDismiss,
      ),
    );
  }, tags: ['webview', 'android', 'ios']);
}
