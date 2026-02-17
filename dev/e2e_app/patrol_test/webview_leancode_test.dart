import 'common.dart';

void main() {
  const acceptCookiesButtonText = 'ACCEPT ALL COOKIES';
  const contactUsButtonText = 'Contact us';

  patrol(
    'interacts with the LeanCode website in a webview',
    ($) async {
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

      await $.platform.mobile.tap(Selector(text: contactUsButtonText));
    },
    tags: ['webview', 'android', 'ios'],
  );
}
