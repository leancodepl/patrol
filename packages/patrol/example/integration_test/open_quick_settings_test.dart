import 'common.dart';

void main() {
  patrol('opens quick settings', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.openQuickSettings();
  });
}
