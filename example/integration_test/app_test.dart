import 'package:example/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro/automator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final automator = Automator.instance;
  Automator.init();

  testWidgets("go home and come back", (WidgetTester tester) async {
    counterText() =>
        tester.firstElement(find.byKey(const ValueKey('counterText'))).widget
            as Text;

    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(counterText().data, '1');

    await automator.pressHome();
    await automator.pressDoubleRecentApps();

    await tester.pumpAndSettle();
    expect(counterText().data, '1');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(counterText().data, '2');
  });
}
