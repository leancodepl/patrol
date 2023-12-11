import '../common.dart';

void main() {
  var globalSetUpIndex = 0,
      globalTearDownIndex = 0,
      topGroupSetUpIndex = 0,
      topGroupTearDownIndex = 0,
      alphaGroupSetUpIndex = 0,
      alphaGroupTearDownIndex = 0;

  final globalSetUpIndexes = [0, 3, 10, 17, 22, 27];
  final globalTearDownIndexes = [2, 9, 16, 21, 26, 31];
  final topGroupSetUpIndexes = [4, 11, 18, 23, 28];
  final topGroupTearDownIndexes = [8, 15, 20, 25, 30];
  final alphaGroupSetUpIndexes = [5, 12];
  final alphaGroupTearDownIndexes = [7, 14];

  patrolSetUp(() {
    print(globalSetUpIndexes.elementAt(globalSetUpIndex));
    globalSetUpIndex += 1;
  });
  patrolTearDown(() {
    print(globalTearDownIndexes.elementAt(globalTearDownIndex));
    globalTearDownIndex += 1;
  });

  patrol('at the beginning', ($) async {
    await _testBody($, '1');
  });

  group('top level group', () {
    patrolSetUp(() {
      print(topGroupSetUpIndexes.elementAt(topGroupSetUpIndex));
      topGroupSetUpIndex += 1;
    });
    patrolTearDown(() {
      print(topGroupTearDownIndexes.elementAt(topGroupTearDownIndex));
      topGroupTearDownIndex += 1;
    });

    group('alpha', () {
      patrolSetUp(() {
        print(alphaGroupSetUpIndexes.elementAt(alphaGroupSetUpIndex));
        alphaGroupSetUpIndex += 1;
      });
      patrolTearDown(() {
        print(alphaGroupTearDownIndexes.elementAt(alphaGroupTearDownIndex));
        alphaGroupTearDownIndex += 1;
      });

      patrol('first', ($) async {
        await _testBody($, '6');
      });
      patrol('second', ($) async {
        await _testBody($, '13');
      });
    });

    patrol('test between groups', ($) async {
      await _testBody($, '19');
    });

    group('bravo', () {
      patrol('first', ($) async {
        await _testBody($, '24');
      });
      patrol('second', ($) async {
        await _testBody($, '29');
      });
    });
  });
}

Future<void> _testBody(PatrolIntegrationTester $, String text) async {
  print(text);
}
