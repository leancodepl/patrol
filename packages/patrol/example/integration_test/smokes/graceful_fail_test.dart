import '../common.dart';

final _nativeAutomatorConfig = globalNativeAutomatorConfig.copyWith(
  findTimeout: Duration(seconds: 3), // shorter timeout for this test
);

void main() {
  patrol(
    'native tap() fails gracefully',
    nativeAutomatorConfig: _nativeAutomatorConfig,
    ($) async {
      await createApp($);

      await expectLater(
        () => $.native.tap(Selector(text: 'This does not exist, boom!')),
        throwsA(
          isA<PatrolActionException>().having(
            (err) => err.message,
            'message',
            contains('This does not exist, boom!'),
          ),
        ),
      );
    },
  );

  patrol(
    'native enterText() fails gracefully',
    nativeAutomatorConfig: _nativeAutomatorConfig,
    ($) async {
      await createApp($);

      await expectLater(
        () => $.native.enterText(
          Selector(text: 'This does not exist, boom!'),
          text: 'some text',
        ),
        throwsA(
          isA<PatrolActionException>().having(
            (err) => err.message,
            'message',
            contains('This does not exist, boom!'),
          ),
        ),
      );
    },
  );

  patrol(
    'native enterTextByIndex() fails gracefully',
    nativeAutomatorConfig: _nativeAutomatorConfig,
    ($) async {
      await createApp($);

      await expectLater(
        () => $.native.enterTextByIndex('some text', index: 100),
        throwsA(isA<PatrolActionException>()),
      );
    },
  );
}
