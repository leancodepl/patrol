import 'common.dart';

void main() {
  patrol('Open url', ($) async {
    await createApp($);

    await $.native.openUrl(url: 'https://leancode.co');
  });
}
