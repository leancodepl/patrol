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

      await $('Open webview screen B').scrollTo();

      await $.native.tap(Selector(text: 'Open webview screen B'));

      await $.pumpAndSettle();

      await $.native.waitAndTap($, Selector(text: 'login'));
      await $.native.waitAndEnterTextByIndex(
        $,
        text: 'test@leancode.pl',
        index: 0,
      );
      await $.native.waitAndEnterTextByIndex(
        $,
        text: 'ny4ncat',
        index: 1,
      );
    },
  );
}

extension PatrolX on NativeAutomator {
  Future<void> waitAndTap(PatrolTester $, Selector selector) async {
    await tap(selector, appId: resolvedAppId);
    //await $.pumpAndSettle();
  }

  Future<void> waitAndEnterText(
    PatrolTester $,
    Selector selector, {
    required String text,
  }) async {
    await enterText(selector, text: text, appId: resolvedAppId);
    //await $.pumpAndSettle();
  }

  Future<void> waitAndEnterTextByIndex(
    PatrolTester $, {
    required String text,
    required int index,
  }) async {
    await enterTextByIndex(text, index: index, appId: resolvedAppId);
    //await $.pumpAndSettle();
  }
}
