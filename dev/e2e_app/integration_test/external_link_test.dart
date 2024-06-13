import 'common.dart';

void main() {
  patrol('Open external url', ($) async {
    await createApp($);

    await $.native.openUrl('https://leancode.co');

    await $.native.waitUntilVisible(Selector(text: 'Subscribe'));
  });
}
