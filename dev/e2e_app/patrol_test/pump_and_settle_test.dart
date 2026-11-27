import 'package:e2e_app/keys.dart';

import 'common.dart';

void main() {
  patrol('pumpAndSettle returns the number of pumped frames', ($) async {
    await createApp($);

    // noSettle leaves the route transition for pumpAndSettle to count.
    await $(
      K.atFinderScreenButton,
    ).scrollTo().tap(settlePolicy: SettlePolicy.noSettle);
    final frames = await $.pumpAndSettle();

    expect(frames, greaterThan(1));
    expect($('at() finder'), findsOneWidget);
  }, tags: ['android', 'emulator', 'ios', 'simulator']);
}
