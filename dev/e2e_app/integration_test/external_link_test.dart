import 'common.dart';

void main() {
  patrol('Open external url', ($) async {
    await createApp($);

    await $.native2.openUrl('https://leancode.co');

    await $.pump(Duration(seconds: 5));

    try {
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'Use without an account'),
        ),
      );
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'No thanks'),
          ios: IOSSelector(label: 'No thanks'),
        ),
        appId: 'com.apple.mobilesafari',
      );
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(
            text: 'ACCEPT ALL COOKIES',
            applicationPackage: 'com.android.chrome',
          ),
          ios: IOSSelector(label: 'ACCEPT ALL COOKIES'),
        ),
        appId: 'com.apple.mobilesafari',
      );
    } on PatrolActionException catch (_) {
      // ignore
    }

    await $.native2.waitUntilVisible(
      NativeSelector(
        android: AndroidSelector(text: 'Contact us'),
        ios: IOSSelector(label: 'Contact us'),
      ),
      appId: 'com.apple.mobilesafari',
    );
  });
}
