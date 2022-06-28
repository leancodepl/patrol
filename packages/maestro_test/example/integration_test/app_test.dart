import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final maestro = Maestro.forTest();

  testWidgets(
    'counter state is the same after going to Home and switching apps',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await maestro.healthCheck();

      await maestro.pressHome();

      await maestro.pressDoubleRecentApps();

      await maestro.pressHome();

      await maestro.openNotifications();
      await maestro.tap(const Selector(text: 'Bluetooth'));
      await maestro.tap(const Selector(text: 'Bluetooth'));
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
