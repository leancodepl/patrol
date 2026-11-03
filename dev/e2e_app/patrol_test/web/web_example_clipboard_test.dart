import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('clipboard', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await $.platform.web.grantPermissions(
      permissions: ['clipboard-read', 'clipboard-write'],
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.setClipboard(text: 'abab');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(await $.platform.web.getClipboard(), 'abab');

    await $.platform.web.setClipboard(text: 'test');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(await $.platform.web.getClipboard(), 'test');

    await $.platform.web.clearPermissions();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
