import 'common.dart';

void main() {
  patrol('opens quick settings', ($) async {
    await createApp($);

    await $.native.openQuickSettings();
    await $.native.pressBack();
    await $.native.pressBack();
  });
}
