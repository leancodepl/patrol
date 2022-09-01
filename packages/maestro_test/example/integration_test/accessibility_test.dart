import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

Future<void> main() async {
  final maestro = Maestro.forTest();

  maestroTest(
    'maestroTest works correctly with semantics',
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await maestro.tap(Selector(contentDescriptionContains: 'webview'));

      await $.pumpAndSettle();

      await maestro.waitAndTap($, Selector(text: 'Accept cookies'));
      await maestro.waitAndTap($, Selector(text: 'Select items'));
      await maestro.waitAndTap($, Selector(text: 'Developer'));
      await maestro.waitAndTap($, Selector(text: '1 item selected'));
      await maestro.waitAndEnterTextByIndex(
        $,
        Selector(text: '1 item selected'),
        text: 'test@leancode.pl',
        index: 0,
      );

      await Future<void>.delayed(const Duration(seconds: 10));
    },
    config: maestroConfig,
  );
}

extension MaestroX on Maestro {
  Future<void> waitAndTap(MaestroTester $, Selector selector) async {
    await waitUntilVisible($, selector);
    await tap(selector);
    await $.pumpAndSettle();
  }

  Future<void> waitAndEnterText(
    MaestroTester $,
    Selector selector, {
    required String text,
  }) async {
    await waitUntilVisible($, selector);
    await enterText(selector, text: text);
    await $.pumpAndSettle();
  }

  Future<void> waitAndEnterTextByIndex(
    MaestroTester $,
    Selector selector, {
    required String text,
    required int index,
  }) async {
    await waitUntilVisible($, selector);
    await enterTextByIndex(text, index: index);
    await $.pumpAndSettle();
  }

  Future<void> waitUntilVisible(MaestroTester $, Selector selector) async {
    var nativeWidgets = await getNativeWidgets(selector);
    while (nativeWidgets.isEmpty) {
      $.log('no "Select items" found, pumping...');
      await $.pump();
      nativeWidgets = await getNativeWidgets(selector);
    }
    await $.pump();
  }
}
