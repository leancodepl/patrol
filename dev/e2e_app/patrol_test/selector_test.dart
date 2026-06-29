import 'common.dart';

void main() {
  patrol('PlatformSelector allows different selectors per platform', ($) async {
    await createApp($);

    await $('Open webview (Patrol docs)').scrollTo().tap();
    await $.pump(const Duration(seconds: 5));

    // Dismiss the cookie consent popup if it appears. The exact button label
    // can vary, so try the common variants and ignore if none are present.

    try {
      await $.platform.mobile.tap(
        Selector(text: 'ACCEPT ALL COOKIES'),
        timeout: const Duration(seconds: 10),
      );
    } on PatrolActionException catch (_) {
      // nothing
    }
    await Future<void>.delayed(const Duration(seconds: 5));
    // Open the search modal and type a query into its input field.
    await $.platform.mobile.tap(
      PlatformSelector(
        android: AndroidSelector(text: 'Open Search'),
        ios: IOSSelector(label: 'Open Search'),
        web: WebSelector(text: 'Search'),
      ),
    );
  });
}
