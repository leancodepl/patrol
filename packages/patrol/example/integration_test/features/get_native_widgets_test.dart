import '../common.dart';

void main() {
  patrol('prints native widgets', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.pressHome();
    await $.native.getNativeViews(Selector(textContains: 'a'));
  });
}
