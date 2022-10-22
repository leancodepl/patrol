import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('scrollTo() bug', () {
    patrolTest(
      'fails',
      ($) async {
        await $.pumpWidgetAndSettle(ExampleApp());
        await $('Open scrolling screen bug').tap();

        expect(await $('index: 1').waitUntilVisible(), findsOneWidget);

        expect($('index: 100').hitTestable(), findsNothing);

        await $('index: 100').scrollTo(); // spins here
        $.log('After scrollTo()');

        await Future<void>.delayed(Duration(seconds: 3));

        await $('index: 100').tap();
        $.log('After tap()');

        expect($('index: 100').hitTestable(), findsOneWidget);
      },
    );

    patrolTest(
      'succeeds',
      ($) async {
        await $.pumpWidgetAndSettle(ExampleApp());
        await $('Open scrolling screen bug').tap();

        expect(await $('index: 1').waitUntilVisible(), findsOneWidget);

        expect($('index: 100').hitTestable(), findsNothing);

        await $('index: 100')
            .scrollTo(scrollable: $(#listView2).$(Scrollable)); // spins here
        $.log('After scrollTo()');

        await Future<void>.delayed(Duration(seconds: 3));

        await $('index: 100').tap();
        $.log('After tap()');

        expect($('index: 100').hitTestable(), findsOneWidget);
      },
    );
  });
}
