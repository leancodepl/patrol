import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('verify file downloads - check if list is empty', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    final downloads = await $.platform.web.verifyFileDownloads();
    expect(downloads, isEmpty);
  });
}
