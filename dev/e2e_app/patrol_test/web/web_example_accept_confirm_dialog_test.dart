import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('accept confirm dialog', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    final message = $.platform.web.acceptNextDialog();
    await $('Show Confirm').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(await message, 'Do you confirm?');

    expect($('Confirm was accepted'), findsOneWidget);

    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
