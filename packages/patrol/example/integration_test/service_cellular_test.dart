import 'common.dart';

void main() {
  patrol('disables and enables cellular twice', ($) async {
    await createApp($);

    await $.native.disableCellular();
    await $.native.enableCellular();
    await $.native.disableCellular();
    await $.native.enableCellular();
  });
}
