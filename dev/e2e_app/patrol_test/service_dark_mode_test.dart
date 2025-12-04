import 'common.dart';

void main() {
  patrol('disables and enables dark mode twice', ($) async {
    await createApp($);
    await $.platform.mobile.disableDarkMode();
    await $.platform.mobile.enableDarkMode();
    await $.platform.mobile.disableDarkMode();
    await $.platform.mobile.enableDarkMode();
  }, tags: ['locale_testing_ios']);
}
