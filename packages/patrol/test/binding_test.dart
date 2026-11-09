import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';

DartGroupEntry _entry(
  String name,
  GroupEntryType type, [
  List<DartGroupEntry> entries = const [],
]) => DartGroupEntry(
  name: name,
  type: type,
  entries: entries,
  skip: false,
  tags: [],
);

/// The binding only stores it; the real one needs Android, iOS, macOS or web.
class _FakePlatformAutomator implements PlatformAutomator {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // PatrolBinding's tearDown() waits for the native side to request a test.
  // Request one that is not in this file, so tearDown() reports nothing.
  final binding = PatrolBinding(_FakePlatformAutomator())
    ..logger = (_) {}
    ..patrolAppService = PatrolAppService(
      topLevelDartTestGroup: _entry('', GroupEntryType.group, [
        _entry('other_test', GroupEntryType.group, [
          _entry('other', GroupEntryType.test),
        ]),
      ]),
    )
    ..patrolAppService.runDartTest(
      const RunDartTestRequest(name: 'other_test other'),
    );

  // The host engine always starts on `/`, so equality can't tell the native
  // value from flutter_test's `/` stand-in. The stand-in is a string literal,
  // the native value is a new string on every read, so compare identity.
  Matcher isNativeRoute() => isNot(same('/'));

  group('PatrolBinding', () {
    test('reports the native default route name after construction', () {
      expect(binding.platformDispatcher.defaultRouteName, '/');
      expect(binding.platformDispatcher.defaultRouteName, isNativeRoute());
    });

    test('reports the native default route name after reset()', () {
      binding.platformDispatcher.defaultRouteNameTestValue = '/test-value';
      binding.reset();

      expect(binding.platformDispatcher.defaultRouteName, '/');
      expect(binding.platformDispatcher.defaultRouteName, isNativeRoute());
    });

    testWidgets('lets a test override the default route name', (tester) async {
      expect(tester.platformDispatcher.defaultRouteName, isNativeRoute());

      tester.platformDispatcher.defaultRouteNameTestValue = '/details/42';
      expect(tester.platformDispatcher.defaultRouteName, '/details/42');
    });
  });
}
