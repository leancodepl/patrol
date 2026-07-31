import 'common.dart';

void main() {
  // TODO: Add this test to Ci/CD to test PlatformSelector on web
  // https://leancode.atlassian.net/browse/PAT-304
  patrol('PlatformSelector allows different selectors per platform', ($) async {
    await createApp($);

    await $('Open webview (Patrol docs)').scrollTo().tap();
    await $.pump(const Duration(seconds: 5));

    // Dismiss the cookie consent popup if it appears
    try {
      await $.platform.tap(
        Selector(text: 'ACCEPT ALL COOKIES'),
        timeout: const Duration(seconds: 10),
      );
    } on PatrolActionException catch (_) {
      // nothing
    }
    await Future<void>.delayed(const Duration(seconds: 5));
    await $.platform.mobile.tap(
      PlatformSelector(
        android: AndroidSelector(text: 'Open Search'),
        ios: IOSSelector(label: 'Open Search'),
        web: WebSelector(text: 'Search'),
      ),
    );
  });
}
