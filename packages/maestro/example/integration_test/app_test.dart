import 'package:example/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro/maestro.dart';

// Runs on target device.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Automator.init(verbose: true);
  final automator = Automator.instance;

  testWidgets(
    "counter state is the same after going to Home and switching apps",
    (WidgetTester tester) async {
      Text findCounterText() {
        return tester
            .firstElement(find.byKey(const ValueKey('counterText')))
            .widget as Text;
      }

      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText().data, '1');

      await automator.pressHome();
      print('after press home 1');

      await automator.pressDoubleRecentApps();
      print('after press recent apps 1');

      expect(findCounterText().data, '1');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText().data, '2');
    },
  );
}
