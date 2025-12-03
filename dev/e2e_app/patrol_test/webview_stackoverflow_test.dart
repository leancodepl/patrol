import 'common.dart';

void main() {
  patrol('interacts with the StackOverflow website in a webview', ($) async {
    await createApp($);

    await $('Open webview (StackOverflow)').scrollTo().tap();

    await $.pump(Duration(seconds: 3));

    await $.platform.mobile.swipe(from: Offset(0.5, 0.7), to: Offset(0.5, 0.3));

    try {
      await $.platform.mobile.tap(Selector(text: 'Accept all cookies'));
    } on PatrolActionException catch (_) {
      // ignore
    }
    await $.platform.mobile.tap(Selector(text: 'Log in'));

    await $.pump(Duration(seconds: 2));

    // bug: using `Email` and `Password` selectors doesn't work (#1554)
    await $.platform.mobile.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.alternative,
    );

    await $.platform.mobile.swipe(from: Offset(0.5, 0.5), to: Offset(0.5, 0.3));

    await $.platform.mobile.enterTextByIndex(
      'ny4ncat',
      index: 1,
      keyboardBehavior: KeyboardBehavior.alternative,
      tapLocation: Offset(0.5, 0.5),
    );
    await $.platform.mobile.tap(Selector(text: 'Log in'));
  });

  patrol('interacts with the StackOverflow website in a webview native2', (
    $,
  ) async {
    await createApp($);

    await $('Open webview (StackOverflow)').scrollTo().tap();

    await $.pump(Duration(seconds: 3));

    await $.platform.mobile.swipe(from: Offset(0.5, 0.7), to: Offset(0.5, 0.3));

    try {
      await $.platform.mobile.tap(Selector(text: 'Accept all cookies'));
    } on PatrolActionException catch (_) {
      // ignore
    }
    await $.platform.mobile.tap(Selector(text: 'Log in'));

    await $.pump(Duration(seconds: 2));

    // bug: using `Email` and `Password` selectors doesn't work (#1554)
    await $.platform.mobile.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.alternative,
    );

    await $.platform.mobile.swipe(from: Offset(0.5, 0.5), to: Offset(0.5, 0.3));

    await $.platform.mobile.enterTextByIndex(
      'ny4ncat',
      index: 1,
      keyboardBehavior: KeyboardBehavior.alternative,
      tapLocation: Offset(0.5, 0.5),
    );
    await $.platform.mobile.tap(Selector(text: 'Log in'));
  });
}
