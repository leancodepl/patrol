import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('accept alert dialog', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    final message = $.platform.web.acceptNextDialog();
    await $('Show Alert').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(await message, 'This is an alert!');

    expect($('Alert was accepted'), findsOneWidget);

    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
