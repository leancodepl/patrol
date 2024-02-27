import 'common.dart';

void main() {
  patrol(
    'interacts with the StackOverflow website in a webview',
    ($) async {
      await createApp($);

      await $('Open webview (StackOverflow)').scrollTo().tap();

      try {
        await $.native.tap(Selector(text: 'Accept all cookies'));
      } on PatrolActionException catch (_) {
        // ignore
      }
      await $.native.tap(Selector(text: 'Log in'));

      await $.pump(Duration(seconds: 2));

      // bug: using `Email` and `Password` selectors doesn't work (#1554)
      await $.native.enterTextByIndex('test@leancode.pl', index: 0);
      await $.native.enterTextByIndex('ny4ncat', index: 1);
      await $.native.tap(Selector(text: 'Log in'));
    },
  );

  patrol(
    'interacts with the StackOverflow website in a webview',
    ($) async {
      await createApp($);

      await $('Open webview (StackOverflow)').scrollTo().tap();

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
      await $.native2.enterTextByIndex('test@leancode.pl', index: 0);
      await $.native2.enterTextByIndex('ny4ncat', index: 1);
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'Log in'),
          ios: IOSSelector(label: 'Log in'),
        ),
      );
    },
  );
}
