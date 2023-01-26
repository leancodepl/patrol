import 'common.dart';

void main() {
  patrol('disables and enables dark mode twice', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.disableDarkMode();
    await $.native.enableDarkMode();
    await $.native.disableDarkMode();
    await $.native.enableDarkMode();
  });
}
