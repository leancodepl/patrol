import 'package:convenient_test_dev/convenient_test_dev.dart';
import 'package:example/main.dart' as app;
import 'package:flutter/widgets.dart';

class MyConvenientTestSlot extends ConvenientTestSlot {
  @override
  Future<void> appMain(AppMainExecuteMode mode) async => app.main();

  @override
  BuildContext? getNavContext(ConvenientTest t) =>
      app.ExampleApp.navigatorKey.currentContext;
}
