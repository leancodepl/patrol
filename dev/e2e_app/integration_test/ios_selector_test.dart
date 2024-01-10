import 'common.dart';

// Those tests are failing with weird errors when you run them all together.
// If you run them one by one, they pass.
void main() {
  patrol(
    'tap and enterText work when matching exact strings',
    ($) async {
      await createApp($);

      await $.native.waitUntilVisible(Selector(text: 'Increment counter'));

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

      await $.native.waitUntilVisible(Selector(textStartsWith: 'Increment'));

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

  patrol(
    'tap and enterText work when matching by textContains',
    ($) async {
      await createApp($);

      await $.native.waitUntilVisible(Selector(textContains: 'counter'));

      await $.native.tap(Selector(textContains: 'counter'));

      await $.native.enterText(
        Selector(textContains: 'entered th'),
        text: 'Hello from Patrol native automation!',
      );
      await $.pump();

      await $.native.tap(Selector(textContains: 'ent c'));
      await $.pump();
      await $.native.tap(Selector(textContains: 'rement'));
      await $.pump();

      expect($('Hello from Patrol native automation!'), findsOneWidget);

      expect($(#counterText).text, '3');
    },
  );
}
