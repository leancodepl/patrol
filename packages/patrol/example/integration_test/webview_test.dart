import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  patrolTest(
    'navigates through the app using only native semantics',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open webview screen').scrollTo();

      await $.native.tap(Selector(text: 'Open webview screen'));

      await $.pumpAndSettle();

      await $.native.waitAndTap($, Selector(text: 'Accept cookies'));
      await $.native.waitAndTap($, Selector(text: 'Select items'));
      await $.native.waitAndTap($, Selector(text: 'Developer'));
      await $.native.waitAndTap($, Selector(text: '1 item selected'));
      await $.native.waitAndEnterTextByIndex(
        $,
        Selector(text: '1 item selected'),
        text: 'test@leancode.pl',
        index: 0,
      );
    },
  );
}

extension PatrolX on NativeAutomator {
  Future<void> waitAndTap(PatrolTester $, Selector selector) async {
    await tap(selector, appId: resolvedAppId);
    await $.pumpAndSettle();
  }

  Future<void> waitAndEnterText(
    PatrolTester $,
    Selector selector, {
    required String text,
  }) async {
    await enterText(selector, text: text, appId: resolvedAppId);
    await $.pumpAndSettle();
  }

  Future<void> waitAndEnterTextByIndex(
    PatrolTester $,
    Selector selector, {
    required String text,
    required int index,
  }) async {
    await enterTextByIndex(text, index: index, appId: resolvedAppId);
    await $.pumpAndSettle();
  }
}
