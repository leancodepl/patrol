import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

// Idea: rename MaestroFinder.visible to MaestroFinder.waitForVisible
// Idea: create bool getter MaestroFinder.visible

void main() {
  maestroTest('correctly handles non-hittestable widgets', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $('Open overlay screen').tap();

    expect($('hidden boi'), findsOneWidget);
    expect($('hidden boi').hitTestable(), findsNothing);

    await expectLater(
      () => $('hidden boi').visible(),
      throwsA(isA<MaestroFinderFoundNothingException>()),
    );
  });
}
