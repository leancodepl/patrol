import 'common.dart';

void main() {
  patrol(
    'interacts with the Patrol docs website in a webview',
    ($) async {
      await createApp($);

      await $('Open webview (Patrol docs)').scrollTo().tap();
      await $.pump(Duration(seconds: 8));
      await $.pumpAndSettle();

      // The docs navigation is collapsed on mobile, so open the sidebar first.
      // The hamburger is an icon-only button, so it has no visible text - match
      // it by its aria-label, which the WebView exposes as the accessibility
      // content description on Android and the accessibility label on iOS.
      await $.platform.mobile.tap(
        MobileSelector(
          android: AndroidSelector(contentDescription: 'Open Sidebar'),
          ios: IOSSelector(label: 'Open Sidebar'),
        ),
      );

      // Navigate to the Getting started page from the sidebar.
      await $.platform.mobile.tap(Selector(text: 'Getting started'));
      await $.pump(Duration(seconds: 3));
      await $.pumpAndSettle();

      // Open the search modal and type a query into its input field.
      await $.platform.mobile.tap(
        MobileSelector(
          android: AndroidSelector(contentDescription: 'Open Search'),
          ios: IOSSelector(label: 'Open Search'),
        ),
      );
      await $.platform.mobile.enterTextByIndex(
        'patrol',
        index: 0,
        keyboardBehavior: KeyboardBehavior.showAndDismiss,
      );
    },
    tags: ['webview', 'android', 'ios'],
  );
}
