import '../common.dart';

void main() {
  // TODO uncomment after https://github.com/leancodepl/patrol/issues/2017
  // patrolSetUpAll(() {
  //   _printOrder('SetUpAll - run only once');
  // });

  patrolSetUp(() {
    _printOrder('SetUpTopLevel');
  });
  patrolTearDown(() {
    _printOrder('TearDownTopLevel');
  });

  patrol('alpha', ($) async {
    await _testBody($, 'Test alpha');
  });

  group('group one', () {
    patrolSetUp(() {
      _printOrder('SetUp - GroupOne');
    });
    patrolTearDown(() {
      _printOrder('TearDown - GroupOne');
    });

    group('group two', () {
      patrolSetUp(() {
        _printOrder('SetUp - GroupTwo');
      });
      patrolTearDown(() {
        _printOrder('TearDown - GroupTwo');
      });

      patrol('bravo', ($) async {
        await _testBody($, 'Test bravo');
      });
      patrol('charlie', ($) async {
        await _testBody($, 'Test charlie');
      });
    });

    patrol('delta', ($) async {
      await _testBody($, 'Test delta');
    });

    group('group three', () {
      patrol('echo', ($) async {
        await _testBody($, 'Test echo');
      });
      patrol('foxtrot', ($) async {
        await _testBody($, 'Test foxtrot');
      });
    });
  });
}

Future<void> _testBody(PatrolIntegrationTester $, String text) async {
  _printOrder(text);
}

void _printOrder(String text) => print('ORDER OF RUN: $text ~');
