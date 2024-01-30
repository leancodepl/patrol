import 'common.dart';

void main() {
  patrol(
    'iOS waitUntilVisible',
    ($) async {
      await createApp($);

      await $.native.openApp(appId: 'com.apple.MobileSMS');

      await $.native
          .enterTextByIndex('Text', index: 0, appId: 'com.apple.MobileSMS');
      await $.native.waitUntilVisible(
        Selector(text: 'Text'),
        appId: 'com.apple.MobileSMS',
      );
    },
  );
}
