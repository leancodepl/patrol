import '../common.dart';
import 'web_example_app.dart';

void main() {
  patrol('take screenshot', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    // Takes an on-demand screenshot of the active page.
    await $.takeNativeScreenshot('web_home_page');
  });
}
