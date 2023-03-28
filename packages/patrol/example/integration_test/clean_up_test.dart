import 'common.dart';

Future<void> main() async {
  tearDown(() async {
    final automator = NativeAutomator(
      config: NativeAutomatorConfig(
        packageName: 'pl.leancode.patrol.example',
        bundleId: 'pl.leancode.patrol.Example',
      ),
    );
    await automator.configure();
    await automator.disableCellular();
  });

  patrol(
    'test description',
    ($) async {
      await createApp($);

      await $.native.enableCellular();
      await $.pumpAndSettle(duration: Duration(seconds: 3));

      // ...

      throw Exception('test failed');
    },
  );
}
