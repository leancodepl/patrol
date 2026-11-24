import 'dart:convert';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/web/restart_teardown_window.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

String patrolLog(Entry entry) => 'PATROL_LOG ${jsonEncode(entry.toJson())}';

final replacementRunMarker = patrolLog(
  ConfigEntry(config: {'printLogs': true}),
);

const restarted = 'Restarted application in 154ms.';
const exceptionBanner =
    '══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞═══════════';
const someTestsFailed = 'Some tests failed.';

void main() {
  group('RestartTeardownWindow.isReplacementRunMarker', () {
    test('matches the config entry a declared patrolTest prints', () {
      expect(
        RestartTeardownWindow.isReplacementRunMarker(replacementRunMarker),
        isTrue,
      );
    });

    test('ignores the develop-completed entry of a finished run', () {
      final line = patrolLog(
        ConfigEntry(config: {ConfigEntry.developCompletedKey: true}),
      );

      expect(RestartTeardownWindow.isReplacementRunMarker(line), isFalse);
    });

    test('ignores other entries and malformed lines', () {
      final testStart = patrolLog(
        TestEntry(name: 'app_test logs in', status: TestEntryStatus.start),
      );

      expect(RestartTeardownWindow.isReplacementRunMarker(testStart), isFalse);
      expect(
        RestartTeardownWindow.isReplacementRunMarker('PATROL_LOG {not json'),
        isFalse,
      );
      expect(RestartTeardownWindow.isReplacementRunMarker(restarted), isFalse);
    });
  });

  group('WebTestBackend.onFlutterLine across a hot restart', () {
    late MockLogger logger;
    late WebTestBackend backend;

    setUp(() {
      logger = MockLogger();
      when(() => logger.err(any())).thenReturn(null);
      when(() => logger.detail(any())).thenReturn(null);
      when(() => logger.success(any())).thenReturn(null);
      backend = WebTestBackend(
        processManager: MockProcessManager(),
        parentDisposeScope: DisposeScope(),
        logger: logger,
      );
    });

    void feed(List<String> lines) => lines.forEach(backend.onFlutterLine);

    test("hides the replaced run's failures until the new run starts", () {
      backend.restartTeardown.restartRequested();
      feed([exceptionBanner, restarted, someTestsFailed]);

      verifyNever(() => logger.err(any()));
    });

    test("hides the replaced run's assertion when r lands mid-expect", () {
      backend.restartTeardown.restartRequested();
      feed([
        restarted,
        'TestFailure: Expected: exactly one matching candidate',
        'Expected: exactly one matching candidate',
        '  Actual: _TextWidgetFinder:<Found 0 widgets>',
        '   Which: means none were found but one was expected',
      ]);

      verifyNever(() => logger.err(any()));
    });

    test('shows a throwing setUpAll when the marker follows the restart', () {
      backend.restartTeardown.restartRequested();
      feed([
        exceptionBanner,
        restarted,
        replacementRunMarker,
        exceptionBanner,
        someTestsFailed,
      ]);

      verify(() => logger.err(exceptionBanner)).called(1);
      verify(() => logger.err(someTestsFailed)).called(1);
    });

    test('shows a throwing setUpAll when the marker precedes the restart', () {
      backend.restartTeardown.restartRequested();
      feed([replacementRunMarker, restarted, exceptionBanner, someTestsFailed]);

      verify(() => logger.err(exceptionBanner)).called(1);
      verify(() => logger.err(someTestsFailed)).called(1);
    });

    test('shows failures once the backstop expires without a marker', () {
      fakeAsync((async) {
        backend.restartTeardown.restartRequested();
        feed([restarted, someTestsFailed]);
        verifyNever(() => logger.err(any()));

        async.elapse(kRestartTeardownBackstop);
        feed([someTestsFailed]);

        verify(() => logger.err(someTestsFailed)).called(1);
      });
    });

    test("shows a throwing setUpAll's error, not just the summary", () {
      const errorLine =
          '00:00 +0: web.app_test (setUpAll) \x1b[1m\x1b[31m[E]\x1b[0m';
      backend.restartTeardown.restartRequested();
      feed([
        restarted,
        replacementRunMarker,
        errorLine,
        '  Bad state: setUpAll failed',
        '  package:e2e_app/app_test.dart 7:18  <fn>',
        someTestsFailed,
      ]);

      verify(() => logger.err(errorLine)).called(1);
      verify(() => logger.err('  Bad state: setUpAll failed')).called(1);
      verifyNever(
        () => logger.err('  package:e2e_app/app_test.dart 7:18  <fn>'),
      );
      verify(() => logger.err(someTestsFailed)).called(1);
    });

    test("hides the replaced run's reporter errors inside the window", () {
      backend.restartTeardown.restartRequested();
      feed(['00:01 +0: web.app_test logs in [E]', '  Bad state: torn down']);

      verifyNever(() => logger.err(any()));
    });

    test('closes the window when the restart fails to compile', () {
      backend.restartTeardown.restartRequested();
      feed(['Try again after fixing the above error(s).', someTestsFailed]);

      verify(() => logger.err(someTestsFailed)).called(1);
    });
  });
}
