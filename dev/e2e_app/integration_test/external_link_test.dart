import 'common.dart';

void main() {
  patrol('Open external url', ($) async {
    await createApp($);

    await $.native.openUrl('https://leancode.co');

    try {
      await $.native.tap(
        Selector(text: 'Contact us'),
        timeout: Duration(seconds: 5),
      );
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native.tap(
        Selector(text: 'No thanks'),
        timeout: Duration(seconds: 5),
      );
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native.tap(
        Selector(text: 'Accept all cookies'),
        timeout: Duration(seconds: 5),
      );
    } on PatrolActionException catch (_) {
      // ignore
    }

    await $.native.waitUntilVisible(
      Selector(text: 'Subscribe'),
      appId: 'com.apple.mobilesafari',
    );
  });
}
