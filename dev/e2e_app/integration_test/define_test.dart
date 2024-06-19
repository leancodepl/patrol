import 'package:e2e_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Run this test with command:
/// patrol test -t integration_test/define_test.dart -d "emulator-5554" --dart-define-from-file=defines_1.json --dart-define-from-file=defines_2.json --verbose

void main() {
  patrolTest('check dart-define-from-file', ($) async {
    await $.pumpWidgetAndSettle(const ExampleApp());

    expect($('FIRST_KEY: First key from defines_1.json'), findsOneWidget);
    expect($('SECOND_KEY: Second key from defines_2.json'), findsOneWidget);
    expect($('THIRD_KEY: Third key from defines_2.json'), findsOneWidget);
  });
}
