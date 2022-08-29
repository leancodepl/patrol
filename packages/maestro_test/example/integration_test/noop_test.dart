import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'a dummy test that does nothing',
    (tester) async {
      await tester.pumpWidget(const ExampleApp());

      final testBinding = tester.binding;
      testBinding.window.platformDispatcher.semanticsEnabledTestValue = true;

      await Future<void>.delayed(const Duration(minutes: 10));
    },
  );
}
