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

      late Selector selector;
      late List<NativeWidget> nativeWidgets;

      // Tap on "Accept cookies"
      selector = Selector(text: 'Accept cookies');
      nativeWidgets = await maestro.getNativeWidgets(selector);
      while (nativeWidgets.isEmpty) {
        $.log('no "Accept cookies" found, pumping again...');
        await $.pump();
        nativeWidgets = await maestro.getNativeWidgets(selector);
      }
      await maestro.tap(selector);
      await $.pumpAndSettle();

      // Tap on "Select items"
      selector = Selector(text: 'Select items');

      await maestro.tap(selector);
      await $.pumpAndSettle();

      // Tap on "Developer"
      selector = Selector(text: 'Developer');
      nativeWidgets = await maestro.getNativeWidgets(selector);
      while (nativeWidgets.isEmpty) {
        $.log('no "Developer" found, pumping again...');
        await $.pump();
        nativeWidgets = await maestro.getNativeWidgets(selector);
      }
      await maestro.tap(selector);
      await $.pumpAndSettle();

      await Future<void>.delayed(const Duration(seconds: 10));
    },
    config: maestroConfig,
  );
}

/* extension MaestroX on Maestro {
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
 */
