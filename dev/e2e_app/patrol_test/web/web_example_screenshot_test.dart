import '../common.dart';
import 'web_example_app.dart';

void main() {
  patrol('take screenshot', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    // Call the web API directly so screenshot failures fail the test.
    await $.platform.web.takeNativeScreenshot('web_home_page');
  });
}
