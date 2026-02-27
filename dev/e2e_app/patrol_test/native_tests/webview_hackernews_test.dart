// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'common.dart';

void main() {
  patrol(
    'interacts with the orange website in a webview',
    ($) async {
      await createApp($);

      await $('Open webview (Hacker News)').scrollTo().tap();

      await $.pump(Duration(seconds: 5));

      await $.native.tap(Selector(text: 'login'));
      await $.native.enterTextByIndex(
        'test@leancode.pl',
        index: 0,
        keyboardBehavior: KeyboardBehavior.showAndDismiss,
      );
      await $.native.enterTextByIndex(
        'ny4ncat',
        index: 1,
        keyboardBehavior: KeyboardBehavior.showAndDismiss,
      );
    },
    tags: ['webview', 'android', 'ios'],
  );

  patrol(
    'interacts with the orange website in a webview native2',
    ($) async {
      await createApp($);

      await $('Open webview (Hacker News)').scrollTo().tap();

      await $.pump(Duration(seconds: 5));

      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'login'),
          ios: IOSSelector(label: 'login'),
        ),
      );
      await $.native2.enterTextByIndex(
        'test@leancode.pl',
        index: 0,
        keyboardBehavior: KeyboardBehavior.showAndDismiss,
      );
      await $.native2.enterText(
        NativeSelector(
          android: AndroidSelector(className: 'android.widget.EditText'),
          ios: IOSSelector(elementType: IOSElementType.secureTextField),
        ),
        text: 'ny4ncat',
        keyboardBehavior: KeyboardBehavior.showAndDismiss,
      );
    },
    tags: ['webview', 'android', 'ios'],
  );
}
