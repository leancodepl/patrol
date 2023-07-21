import '../common.dart';

void main() {
  const appId = 'pl.baftek.Landmarks';

  patrol(
    'internal test',
    ($) async {
      await createApp($);

      await $.native.openApp(appId: appId);

      final username = Selector(text: 'username');

      // Old way – use enterTextByIndex
      /*
      await $.native.enterTextByIndex('My username', index: 0, appId: appId);
      await $.native.enterTextByIndex(
        'My username again!',
        index: 1,
        appId: appId,
      );
      */

      // New way - use Selector.instance
      await $.native.enterText(username, text: 'My username', appId: appId);
      await $.native.enterText(
        username..instance = 1,
        text: 'Username again',
        appId: appId,
      );
      await $.native.tap(
        Selector(text: 'Landmarks', instance: 2),
        appId: appId,
      );
    },
  );
}
