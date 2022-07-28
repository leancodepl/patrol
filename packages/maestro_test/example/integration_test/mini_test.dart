import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'goes to home',
    ($) async {
      await $.pumpWidgetAndSettle(MyApp());

      await maestro.pressHome();
    },
    appName: 'ExampleApp',
  );
}
