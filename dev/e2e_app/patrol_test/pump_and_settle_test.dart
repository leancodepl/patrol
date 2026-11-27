import 'package:e2e_app/keys.dart';

import 'common.dart';

void main() {
  patrol('pumpAndSettle returns the number of pumped frames', ($) async {
    await createApp($);

    expect(await $.pumpAndSettle(), greaterThanOrEqualTo(1));

    await $(K.atFinderScreenButton).scrollTo();
    // Tap without settling, so the route transition is left for pumpAndSettle.
    await $.tester.tap(find.byKey(K.atFinderScreenButton));
    final frames = await $.pumpAndSettle();

    expect(frames, greaterThan(1));
    expect($('at() finder'), findsOneWidget);
  }, tags: ['android', 'emulator', 'ios', 'simulator']);
}
