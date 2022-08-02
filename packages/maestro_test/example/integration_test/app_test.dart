import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'counter state is the same after going to Home and switching apps',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await maestro.pressHome();

      $.log(
        'I went to home! Now gonna wait for 5 seconds and then go open the app '
        'again...',
      );
      await Future<void>.delayed(Duration(seconds: 5));

      $.log('Opeing the app again...');
      await maestro.openApp(id: 'com.example.example');

      $.log("More functionality is not implemented, so I'm gonna crash now :(");

      await maestro.openQuickSettings();
      await maestro.tap(Selector(text: 'Bluetooth'));
      await maestro.tap(Selector(text: 'Bluetooth'));
      await maestro.pressBack();

      await maestro.openNotifications();

      await maestro.enableWifi();
      await maestro.disableWifi();
      await maestro.enableWifi();

      await maestro.enableCelluar();
      await maestro.disableCelluar();
      await maestro.enableCelluar();

      await maestro.enableDarkMode();
      await maestro.disableDarkMode();
      await maestro.enableDarkMode();

      await maestro.pressBack();
    },
    appName: 'ExampleApp',
  );
}
