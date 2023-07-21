import '../common.dart';

void main() {
  const appId = 'pl.baftek.Landmarks';

  patrol(
    'internal test',
    ($) async {
      await createApp($);

      await $.native.openApp(appId: appId);

      final turtleRock = Selector(text: 'Turtle Rock');
      final back = Selector(text: 'Landmarks');

      await $.native.tap(turtleRock, appId: appId);
      await $.native.tap(back, appId: appId);
      await $.native.tap(turtleRock..instance = 1, appId: appId);
      await $.native.tap(back, appId: appId);
    },
  );
}
