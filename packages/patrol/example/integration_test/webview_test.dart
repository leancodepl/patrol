import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  final patrol = Patrol.forTest();

  patrolTest(
    'navigates through the app using only native semantics',
    config: patrolConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open webview screen').scrollTo();

      await patrol.tap(const Selector(text: 'Open webview screen'));

      await $.pumpAndSettle();

      await patrol.waitAndTap($, const Selector(text: 'Accept cookies'));
      await patrol.waitAndTap($, const Selector(text: 'Select items'));
      await patrol.waitAndTap($, const Selector(text: 'Developer'));
      await patrol.waitAndTap($, const Selector(text: '1 item selected'));
      await patrol.waitAndEnterTextByIndex(
        $,
        const Selector(text: '1 item selected'),
        text: 'test@leancode.pl',
        index: 0,
      );
    },
  );
}

extension PatrolX on Patrol {
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
