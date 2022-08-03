import 'package:example/keys.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

// Idea: rename MaestroFinder.visible to MaestroFinder.waitForVisible
// Idea: create bool getter MaestroFinder.visible

void main() {
  maestroTest('drags to a widget', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $('Open scrolling screen').tap();

    expect(await $(K.topText).visible(), findsOneWidget);
    expect($(K.bottomText).hitTestable(), findsNothing);

    await $(K.bottomText).dragTo();

    expect($(K.bottomText).hitTestable(), findsOneWidget);
  });
}
