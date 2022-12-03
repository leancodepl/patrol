import '../../common.dart';

void main() {
  patrol('disables and enables wifi twice', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.disableWifi();
    await $.native.enableWifi();
    await $.native.disableWifi();
    await $.native.enableWifi();
  });
}
