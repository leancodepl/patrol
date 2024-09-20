import 'dart:io' as io;

import 'common.dart';

void main() {
  patrol('interacts with the LeanCode website in a webview native2', ($) async {
    await createApp($);

    await $('Open webview (LeanCode)').scrollTo().tap();
    await $.pump(Duration(seconds: 8));
    await $.pumpAndSettle();

    try {
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'ACCEPT ALL COOKIES'),
          ios: IOSSelector(label: 'ACCEPT ALL COOKIES'),
        ),
      );
    } on PatrolActionException catch (_) {
      // ignore
    }
    await $.pumpAndSettle();

    if (io.Platform.isIOS) {
      await $.native2.scrollTo(
        NativeSelector(
          ios: IOSSelector(placeholderValue: 'Type your email'),
        ),
        maxScrolls: 20,
      );
    }

    await $.pump(Duration(seconds: 5));

    await $.native2.enterText(
      NativeSelector(
        android: AndroidSelector(className: 'android.widget.EditText'),
        ios: IOSSelector(placeholderValue: 'Type your email'),
      ),
      text: 'test@leancode.pl',
      keyboardBehavior: KeyboardBehavior.showAndDismiss,
      tapLocation: Offset(0.5, 0.5),
    );

    await $.native2.tap(
      NativeSelector(
        android: AndroidSelector(text: 'Subscribe'),
        ios: IOSSelector(label: 'Subscribe'),
      ),
    );
  });
}
