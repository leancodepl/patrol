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
  final maestro = Maestro.forTest();

  testWidgets(
    'counter state is the same after going to Home and switching apps',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await maestro.pressHome();

      await maestro.pressDoubleRecentApps();

      await maestro.pressHome();

      await maestro.openNotifications();
      await maestro.tapOnNotification(0);
      await maestro.pressBack();

      await maestro.enableWifi();
      await maestro.disableWifi();
      await maestro.enableWifi();

      await maestro.enableCelluar();
      await maestro.disableCelluar();
      await maestro.enableCelluar();

      await maestro.enableDarkMode();
      await maestro.disableDarkMode();
      await maestro.enableDarkMode();
    },
  );
}
