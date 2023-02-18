import 'common.dart';

void main() {
  patrol('opens quick settings', ($) async {
    await createApp($);

    await $.native.openQuickSettings();
  });
}
