import 'common.dart';

void main() {
  patrol(
    'interacts with the StackOverflow website in a webview',
    ($) async {
      await createApp($);

      await $('Open webview (StackOverflow)').scrollTo().tap();

      try {
        await $.native.tap(Selector.create()..text = 'Accept all cookies');
      } on PatrolActionException catch (_) {
        // ignore
      }
      await $.native.tap(Selector.create()..text = 'Log in');

      await $.pump(Duration(seconds: 2));

      // bug: using `Email` and `Password` selectors doesn't work
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
      await $.native.tap(Selector.create()..text = 'Log in');
    },
  );
}
