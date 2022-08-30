import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  Maestro.forTest();
  maestroTest('drags to non existing and not visible widget', ($) async {
    await $.pumpWidgetAndSettle(
      MaterialApp(
        home: LayoutBuilder(
          builder: (_, constraints) {
            return ListView(
              children: [
                const Text('top text'),
                SizedBox(height: constraints.maxHeight),
                const Text('bottom text'),
              ],
            );
          },
        ),
      ),
    );

    expect($('top text').exists, true);
    expect($('top text').visible, true);

    expect($('bottom text').exists, false);
    expect($('bottom text').visible, false);

    print('here 1');
    /* await $('bottom text').dragTo(
      step: 100,
      view: $(ListView),
      maxIteration: 300,
    ); */

    // 2: raw dragUntilVisible
    await $.tester.dragUntilVisible(
      find.text('bottom text'), //.first,
      find.byType(ListView),
      const Offset(0, 16),
      maxIteration: 300,
    );

    // 3: from StackOverflow
    /* final gesture = await $.tester.startGesture(const Offset(100, 2000));
    await Future<void>.delayed(const Duration(seconds: 2));
    await gesture.moveBy(const Offset(0, 2000));
    await $.pump();
    await Future<void>.delayed(const Duration(seconds: 2));
    await gesture.moveBy(const Offset(0, 2000));
    await $.pump();
    await Future<void>.delayed(const Duration(seconds: 2));
    await gesture.moveBy(const Offset(0, 2000));
    await $.pump(); */

    //expect($('top text').visible, false);
    expect($('bottom text').visible, true);
  });
}
