import 'common.dart';

void main() {
  patrol('disables and enables bluetooth twice', ($) async {
    await createApp($);

    await $.native.disableBluetooth();
    await $.native.enableBluetooth();
    await $.native.disableBluetooth();
    await $.native.enableBluetooth();
  });
}
