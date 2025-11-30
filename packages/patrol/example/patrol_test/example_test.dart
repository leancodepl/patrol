import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('request notification permission first', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    expect($('app'), findsOneWidget);
    if (!Platform.isMacOS) {
      //
      // ignore: deprecated_member_use
      await $.native.pressHome();
    }
  });
}
