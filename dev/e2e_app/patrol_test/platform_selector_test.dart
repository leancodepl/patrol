import 'common.dart';

void main() {
  patrol('PlatformSelector allows different selectors per platform', ($) async {
    await createApp($);

    await $('Open webview (Hacker News)').scrollTo().tap();
    await $.pump(Duration(seconds: 5));

    // Use PlatformSelector when iOS and Android need different selectors
    await $.platform.tap(
      PlatformSelector(
        android: AndroidSelector(text: 'login'),
        ios: IOSSelector(label: 'login'),
        web: WebSelector(text: 'login'),
      ),
    );
  });
}
