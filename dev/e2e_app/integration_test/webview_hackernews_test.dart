import 'common.dart';

void main() {
  patrol('interacts with the orange website in a webview', ($) async {
    await createApp($);

    await $('Open webview (Hacker News)').scrollTo().tap();

    await $.native.tap(Selector(text: 'login'));
    await $.native.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.native.enterText(
      Selector(className: 'android.widget.EditText'),
      text: 'ny4ncat',
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
  });
}
