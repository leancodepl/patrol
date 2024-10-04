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

    final emailInputSelector = NativeSelector(
      android: AndroidSelector(className: 'android.widget.EditText'),
      ios: IOSSelector(placeholderValue: 'Type your email'),
    );

    await $.native2.scrollTo(emailInputSelector, maxScrolls: 20);

    await $.pump(Duration(seconds: 2));

    await $.native2.enterText(
      emailInputSelector,
      text: 'test@leancode.pl',
      keyboardBehavior: KeyboardBehavior.alternative,
      tapLocation: Offset(0.5, 0.5),
    );

    final subscribeButtonSelector = NativeSelector(
      android: AndroidSelector(text: 'Subscribe'),
      ios: IOSSelector(label: 'Subscribe'),
    );

    await $.native2.scrollTo(subscribeButtonSelector);
    await $.native2.tap(subscribeButtonSelector);
  });
}
