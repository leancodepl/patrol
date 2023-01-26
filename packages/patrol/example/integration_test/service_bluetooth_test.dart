import 'common.dart';

void main() {
  patrol('disables and enables bluetooth twice', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.disableBluetooth();
    await $.native.enableBluetooth();
    await $.native.disableBluetooth();
    await $.native.enableBluetooth();
  });
}
