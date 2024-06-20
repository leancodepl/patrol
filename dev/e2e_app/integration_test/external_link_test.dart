import 'common.dart';

void main() {
  patrol('Open external url', ($) async {
    await createApp($);

    await $.native.openUrl('https://leancode.co');

    try {
      await $.native.tap(Selector(text: 'Use without an account'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native.tap(Selector(text: 'No thanks'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native.tap(Selector(text: 'Accept all cookies'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    await $.native.waitUntilVisible(Selector(text: 'Subscribe'));
  });
}
