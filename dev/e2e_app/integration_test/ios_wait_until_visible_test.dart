import 'common.dart';

void main() {
  patrol(
    'iOS waitUntilVisible',
    ($) async {
      await createApp($);

      await $.native.openApp(appId: 'com.apple.mobilesafari');

      await $.native.waitUntilVisible(Selector(text: 'Google', instance: 1));
    },
  );
}
