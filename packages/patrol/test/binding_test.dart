import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/phases.dart' show PatrolPhaseContinuation;
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
  // Request one that is not in this file, so tearDown() reports nothing. The
  // request is for phase 1, as after the first relaunch of a phased test.
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
      const RunDartTestRequest(name: 'other_test other', phaseIndex: 1),
    );

  // The host engine always starts on `/`, so equality can't tell the native
  // value from flutter_test's `/` stand-in. The stand-in is a string literal,
  // the native value is a new string on every read, so compare identity.
  Matcher isNativeRoute() => isNot(same('/'));

  group('PatrolBinding', () {
    // On web the native value is the page's URL, which a hot restart in
    // patrol develop would carry over, so only deep-link phases show it.
    test("keeps flutter_test's `/` stand-in by default", () {
      expect(binding.platformDispatcher.defaultRouteName, same('/'));
    });

    test('shows the native default route name when a phase asks for it', () {
      binding.showNativeDefaultRouteName();

      expect(binding.platformDispatcher.defaultRouteName, '/');
      expect(binding.platformDispatcher.defaultRouteName, isNativeRoute());
    });

    test('puts the stand-in back after reset()', () {
      binding
        ..showNativeDefaultRouteName()
        ..reset();

      expect(binding.platformDispatcher.defaultRouteName, same('/'));
    });

    testWidgets('lets a test override the default route name', (tester) async {
      tester.platformDispatcher.defaultRouteNameTestValue = '/details/42';
      expect(tester.platformDispatcher.defaultRouteName, '/details/42');
    });
  });

  group('PatrolBinding phases', () {
    int? phaseInSetUp;
    setUp(() => phaseInSetUp = binding.currentPhaseIndex);

    test('reports the phase the native side asked this process to run', () {
      // Hooks see it too, not only code that runs after a test body set it.
      expect(phaseInSetUp, 1);
      expect(binding.currentPhaseIndex, 1);
    });

    test('reports a relaunch once a phase asks for the next one', () {
      expect(binding.willRelaunchApp, isFalse);

      binding.patrolAppService.setContinuation(
        PatrolPhaseContinuation(nextPhaseIndex: 2, launchUrl: null),
      );

      expect(binding.willRelaunchApp, isTrue);
    });
  });
}
