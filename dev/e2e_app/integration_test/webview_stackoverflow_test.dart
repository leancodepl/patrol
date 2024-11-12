import 'common.dart';

void main() {
  patrol(
    'interacts with the StackOverflow website in a webview',
    ($) async {
      await createApp($);

      await $('Open webview (StackOverflow)').scrollTo().tap();

      await $.pump(Duration(seconds: 3));

      await $.native2.swipe(from: Offset(0.5, 0.7), to: Offset(0.5, 0.3));

      try {
        await $.native.tap(Selector(text: 'Accept all cookies'));
      } on PatrolActionException catch (_) {
        // ignore
      }
      await $.native.tap(Selector(text: 'Log in'));

      await $.pump(Duration(seconds: 2));

      // bug: using `Email` and `Password` selectors doesn't work (#1554)
      await $.native.enterTextByIndex(
        'test@leancode.pl',
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.swipe(from: Offset(0.5, 0.5), to: Offset(0.5, 0.3));

      await $.native.enterTextByIndex(
        'ny4ncat',
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
        tapLocation: Offset(0.5, 0.5),
      );
      await $.native.tap(Selector(text: 'Log in'));
    },
  );

  patrol(
    'interacts with the StackOverflow website in a webview native2',
    ($) async {
      await createApp($);

      await $('Open webview (StackOverflow)').scrollTo().tap();

      await $.pump(Duration(seconds: 3));

      await $.native2.swipe(from: Offset(0.5, 0.7), to: Offset(0.5, 0.3));

      try {
        await $.native2.tap(
          NativeSelector(
            android: AndroidSelector(text: 'Accept all cookies'),
            ios: IOSSelector(label: 'Accept all cookies'),
          ),
        );
      } on PatrolActionException catch (_) {
        // ignore
      }
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'Log in'),
          ios: IOSSelector(label: 'Log in'),
        ),
      );

      await $.pump(Duration(seconds: 2));

      // bug: using `Email` and `Password` selectors doesn't work (#1554)
      await $.native2.enterTextByIndex(
        'test@leancode.pl',
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.swipe(from: Offset(0.5, 0.5), to: Offset(0.5, 0.3));

      await $.native2.enterTextByIndex(
        'ny4ncat',
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
        tapLocation: Offset(0.5, 0.5),
      );
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'Log in'),
          ios: IOSSelector(label: 'Log in'),
        ),
      );
    },
  );
}
