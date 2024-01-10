import 'common.dart';

// Same as example_test, but using only native selectors.
void main() {
  patrolSetUp(() {
    // Smoke test for https://github.com/leancodepl/patrol/issues/2021
    expect(2 + 2, equals(4));
  });

  patrol(
    'tap and enterText work when matching exact strings',
    ($) async {
      await createApp($);

      await $.native.tap(Selector(text: 'Increment counter'));

      await $.native.enterText(
        Selector(text: 'You have entered this text'),
        text: 'Hello from Patrol native automation!',
      );
      await $.pump();

      await $.native.tap(Selector(text: 'Increment counter'));
      await $.pump();
      await $.native.tap(Selector(text: 'Increment counter'));
      await $.pump();

      expect($('Hello from Patrol native automation!'), findsOneWidget);

      expect($(#counterText).text, '3');
    },
  );

  patrol(
    'tap and enterText work when matching by textStartsWith',
    ($) async {
      await createApp($);

      await $.native.tap(Selector(textStartsWith: 'Increment coun'));

      await $.native.enterText(
        Selector(textStartsWith: 'You have entered th'),
        text: 'Hello from Patrol native automation!',
      );
      await $.pump();

      await $.native.tap(Selector(textStartsWith: 'Increment c'));
      await $.pump();
      await $.native.tap(Selector(textStartsWith: 'Increment'));
      await $.pump();

      expect($('Hello from Patrol native automation!'), findsOneWidget);

      expect($(#counterText).text, '3');
    },
  );
}
