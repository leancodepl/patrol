// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'common.dart';

void main() {
  const acceptCookiesButtonText = 'ACCEPT ALL COOKIES';
  const contactUsButtonText = 'Contact us';
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();
    await $.pump(Duration(seconds: 8));

    try {
      await $.native.tap(Selector(text: acceptCookiesButtonText));
    } on PatrolActionException catch (_) {
      // ignore
    }

    await $.native.waitUntilVisible(Selector(text: contactUsButtonText));
  });

  patrol('interacts with the LeanCode website in a webview native2', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();
    await $.pump(Duration(seconds: 8));
    await $.pumpAndSettle();

    try {
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: acceptCookiesButtonText),
          ios: IOSSelector(label: acceptCookiesButtonText),
        ),
      );
    } on PatrolActionException catch (_) {
      // ignore
    }
    await $.pumpAndSettle();

    await $.native2.waitUntilVisible(
      NativeSelector(
        android: AndroidSelector(text: contactUsButtonText),
        ios: IOSSelector(label: contactUsButtonText),
      ),
    );
  });
}
