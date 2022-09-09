import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

Future<void> main() async {
  final maestro = Maestro.forTest();

  maestroTest(
    'navigates through the app using only native semantics',
    config: maestroConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open webview screen').scrollTo();

      await maestro.tap(const Selector(text: 'Open webview screen'));

      await $.pumpAndSettle();

      await maestro.waitAndTap($, const Selector(text: 'Accept cookies'));
      await maestro.waitAndTap($, const Selector(text: 'Select items'));
      await maestro.waitAndTap($, const Selector(text: 'Developer'));
      await maestro.waitAndTap($, const Selector(text: '1 item selected'));
      await maestro.waitAndEnterTextByIndex(
        $,
        const Selector(text: '1 item selected'),
        text: 'test@leancode.pl',
        index: 0,
      );
    },
  );
}

extension MaestroX on Maestro {
  Future<void> waitAndTap(MaestroTester $, Selector selector) async {
    await tap(selector, appId: resolvedAppId);
    await $.pumpAndSettle();
  }

  Future<void> waitAndEnterText(
    MaestroTester $,
    Selector selector, {
    required String text,
  }) async {
    await enterText(selector, text: text, appId: resolvedAppId);
    await $.pumpAndSettle();
  }

  Future<void> waitAndEnterTextByIndex(
    MaestroTester $,
    Selector selector, {
    required String text,
    required int index,
  }) async {
    await enterTextByIndex(text, index: index, appId: resolvedAppId);
    await $.pumpAndSettle();
  }
}
