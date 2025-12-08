import 'common.dart';

void main() {
  const acceptCookiesButtonText = 'ACCEPT ALL COOKIES';
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();
    await $.pump(Duration(seconds: 8));

    try {
      await $.platform.mobile.tap(Selector(text: acceptCookiesButtonText));
    } on PatrolActionException catch (_) {
      // ignore
    }
    await $.pumpAndSettle();
    // TODO: Does not work need to investigate.
    await $.platform.mobile.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.platform.mobile.tap(Selector(text: 'Subscribe'));
  });

  patrol('interacts with the LeanCode website in a webview native2', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();
    await $.pump(Duration(seconds: 8));
    await $.pumpAndSettle();

    try {
      await $.platform.mobile.tap(Selector(text: acceptCookiesButtonText));
    } on PatrolActionException catch (_) {
      // ignore
    }
    await $.pumpAndSettle();

    await $.platform.mobile.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.platform.mobile.tap(Selector(text: 'Subscribe'));
  });
}
