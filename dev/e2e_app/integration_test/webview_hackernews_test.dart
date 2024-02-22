import 'common.dart';

void main() {
  patrol('interacts with the orange website in a webview', ($) async {
    await createApp($);

    await $('Open webview (Hacker News)').scrollTo().tap();

    await $.native.tap(
      androidSelector: AndroidSelector(text: 'login'),
      iosSelector: IOSSelector(label: 'login'),
    );
    await $.native.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.native.enterText(
      androidSelector: AndroidSelector(className: 'android.widget.EditText'),
      iosSelector: IOSSelector(elementType: IOSElementType.textField),
      text: 'ny4ncat',
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
  });
}
