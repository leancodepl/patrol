import 'common.dart';

void main() {
  patrol('change volume', ($) async {
    await createApp($);

    await $.pumpAndSettle();
    await $.native.pressVolumeUp();
    await $.pumpAndSettle();
    await $.native.pressVolumeDown();
    await $.pumpAndSettle();
    await $.native.pressVolumeUp();
    await $.pumpAndSettle();
  });
}
