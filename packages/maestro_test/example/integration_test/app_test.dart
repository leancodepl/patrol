import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro_test/maestro_test.dart';

// This is an example file. Use it as a base to create your own Maestro-powered
// test.
//
// It runs on target device.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final automator = Automator();

  testWidgets(
    'counter state is the same after going to Home and switching apps',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await automator.pressHome();

      await automator.pressDoubleRecentApps();

      await automator.pressHome();

      await automator.openNotifications();

      await automator.enableWifi();
      await automator.disableWifi();
      await automator.enableWifi();

      await automator.enableCelluar();
      await automator.disableCelluar();
      await automator.enableCelluar();

      await automator.enableDarkMode();
      await automator.disableDarkMode();
      await automator.enableDarkMode();
    },
  );
}
