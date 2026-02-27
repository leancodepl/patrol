import 'common.dart';

void main() {
  patrol(
    'PlatformSelector allows different selectors per platform',
    ($) async {
      await createApp($);

      await $('Open webview (Hacker News)').scrollTo().tap();
      await $.pump(Duration(seconds: 5));

      await $.platform.tap(
        PlatformSelector(
          android: AndroidSelector(text: 'login'),
          ios: IOSSelector(label: 'login'),
          web: WebSelector(text: 'login'),
        ),
      );
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );

  patrol(
    'MobileSelector allows different selectors for mobile platforms',
    ($) async {
      await createApp($);

      await $('Open webview (Hacker News)').scrollTo().tap();
      await $.pump(Duration(seconds: 5));

      await $.platform.mobile.tap(
        MobileSelector(
          android: AndroidSelector(text: 'login'),
          ios: IOSSelector(label: 'login'),
        ),
      );
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
