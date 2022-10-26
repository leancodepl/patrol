import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('never settles (just like OnePlus)', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $('Open unsettling screen').scrollTo().tap();
  });
}
