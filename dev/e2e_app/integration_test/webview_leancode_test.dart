import 'common.dart';

void main() {
  patrol('interacts with the LeanCode website in a webview', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();
    await $.pump(Duration(seconds: 8));

    try {
      await $.native.tap(Selector(text: 'Accept cookies'));
    } on PatrolActionException catch (_) {
      // ignore
    }
    await $.pumpAndSettle();

    await $.native.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.native.tap(Selector(text: 'Subscribe'));
  });

  patrol('interacts with the LeanCode website in a webview native2', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();
    await $.pump(Duration(seconds: 8));
    await $.pumpAndSettle();

    try {
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'Accept cookies'),
          ios: IOSSelector(label: 'Accept cookies'),
        ),
      );
    } on PatrolActionException catch (_) {
      // ignore
    }
    await $.pumpAndSettle();

    await $.native2.enterTextByIndex(
      'test@leancode.pl',
      index: 0,
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
    );
    await $.native2.tap(
      NativeSelector(
        android: AndroidSelector(text: 'Subscribe'),
        ios: IOSSelector(label: 'Subscribe'),
      ),
    );
  });
}
