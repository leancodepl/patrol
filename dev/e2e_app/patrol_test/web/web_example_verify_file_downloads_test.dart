import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('verify file downloads', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    var downloads = await $.platform.web.verifyFileDownloads();
    expect(downloads, isEmpty);

    await $('Download File').tap();
    await $.pumpAndSettle();

    await Future<void>.delayed(const Duration(seconds: 1));

    downloads = await $.platform.web.verifyFileDownloads();
    expect(downloads, hasLength(1));
    expect(downloads.first, 'example.txt');

    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
