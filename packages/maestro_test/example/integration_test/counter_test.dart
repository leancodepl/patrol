import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro_test/maestro_test.dart';
import 'package:maestro_test/src/widget_tester_extensions.dart';

// This is an example file. Use it as a base to create your own Maestro-powered
// test.
//
// It runs on target device.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final maestro = Maestro.forTest();

  testWidgets(
    'counter state is the same after going to Home and switching apps',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(tester.findTextWithNumber()!.data, '1');

      await maestro.pressHome();

      await maestro.pressDoubleRecentApps();

      expect(tester.findTextWithNumber()!.data, '1');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(tester.findTextWithNumber()!.data, '2');

      await maestro.pressHome();

      await maestro.openNotifications();

      await maestro.pressBack();
    },
  );
}
