import 'common.dart';

void main() {
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();

    try {
      await $.native.tap(Selector(text: 'Accept cookies'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    await $.native.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.native.tap(Selector(text: 'Subscribe'));
  });
}
