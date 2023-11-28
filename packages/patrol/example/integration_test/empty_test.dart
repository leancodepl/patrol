import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'test',
    ($) async {
      await initApp();
      await $.pumpWidgetAndSettle(const MyApp());

      // write your code here

      await $.pumpAndSettle();

      expect($('Congratulations!'), findsOneWidget);
    },
  );
}
