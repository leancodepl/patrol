import 'package:e2e_app/keys.dart';

import '../common.dart';

void main() {
  patrol('dismisses native NSAlert with macos automator', ($) async {
    await createApp($);

    // Avoid settling: NSAlert.runModal blocks until the alert is dismissed.
    await $(K.showNativeAlertButton).scrollTo().tap(
      settlePolicy: SettlePolicy.noSettle,
    );

    expect(await $.platform.macos.isAlertVisible(), isTrue);
    await $.platform.macos.tapAlertButton('OK');
    await $.pumpAndSettle();

    expect($(K.nativeAlertResult).text, 'Native alert result: ok');
  }, tags: ['macos']);
}
