import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('dismiss confirm dialog', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    final message = $.platform.web.dismissNextDialog();
    await $('Show Confirm').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(await message, 'Do you confirm?');

    expect($('Confirm was dismissed'), findsOneWidget);

    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
