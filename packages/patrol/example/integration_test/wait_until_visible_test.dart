import 'common.dart';

// This test on purpose uses native interactions where Flutter interactions
// would suffice.

void main() {
  patrol(
    'shows hello text when loading completes',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive,
    ($) async {
      await createApp($);

      await $.native.tap(Selector(contentDescription: 'Open loading screen'));

      await $.native.waitUntilVisible(Selector(contentDescription: 'Hello'));
    },
  );
}
