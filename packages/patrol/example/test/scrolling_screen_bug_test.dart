import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  group('scrollTo()', () {
    patrolTest(
      'fails when the default Scrollable is wrong',
      ($) async {
        await $.pumpWidgetAndSettle(ExampleApp());
        await $('Open scrolling screen bug').scrollTo().tap();

        expect($('index: 1'), findsOneWidget);
        expect($('index: 100').hitTestable(), findsNothing);

        await expectLater(
          $('index: 100').scrollTo,
          throwsA(isA<StateError>()),
        );
        expect($('index: 100').hitTestable(), findsNothing);
      },
    );

    patrolTest(
      'succeeds when the right Scrollable is explicitly specified',
      ($) async {
        await $.pumpWidgetAndSettle(ExampleApp());
        await $('Open scrolling screen bug').scrollTo().tap();

        expect($('index: 1'), findsOneWidget);
        expect($('index: 100').hitTestable(), findsNothing);

        await $('index: 100').scrollTo(scrollable: $(#listView2).$(Scrollable));

        expect($('index: 100').hitTestable(), findsOneWidget);
      },
    );
  });
}
