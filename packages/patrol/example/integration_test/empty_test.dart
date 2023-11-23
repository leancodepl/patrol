import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_challenge/main.dart';

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
