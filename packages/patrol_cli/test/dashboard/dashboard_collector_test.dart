import 'package:patrol_cli/src/dashboard/dashboard_collector.dart';
import 'package:patrol_cli/src/dashboard/dashboard_report.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:test/test.dart';

void main() {
  final start = DateTime(2026, 8, 17, 12);

  DateTime at(int milliseconds) =>
      start.add(Duration(milliseconds: milliseconds));

  DashboardCollector collector({String? testDirectory = 'integration_test'}) =>
      DashboardCollector(testDirectory: testDirectory);

  group('DashboardCollector', () {
    test('collects a passing test with its steps and duration', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'app_test signs in',
            status: TestEntryStatus.start,
            timestamp: at(0),
          ),
        )
        ..handleEntry(
          StepEntry(
            action: 'Tap on "Sign in"',
            status: StepEntryStatus.start,
            timestamp: at(100),
          ),
        )
        ..handleEntry(
          StepEntry(
            action: 'Tap on "Sign in"',
            status: StepEntryStatus.success,
            timestamp: at(700),
          ),
        )
        ..handleEntry(
          TestEntry(
            name: 'app_test signs in',
            status: TestEntryStatus.success,
            timestamp: at(2500),
          ),
        );

      final run = _build(sut);
      expect(run.tests, hasLength(1));

      final test = run.tests.single;
      expect(test.name, 'signs in');
      expect(test.filePath, 'integration_test/app_test.dart');
      expect(test.status, DashboardTestStatus.passed);
      expect(test.duration, const Duration(milliseconds: 2500));
      expect(test.steps, hasLength(1));
      expect(test.steps.single.status, DashboardStepStatus.passed);
      expect(test.steps.single.duration, const Duration(milliseconds: 600));
      expect(run.passedCount, 1);
      expect(run.isSuccessful, isTrue);
      expect(run.passRate, 1);
    });

    test('collects the exception and the failing step of a failing test', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'app_test signs in',
            status: TestEntryStatus.start,
            timestamp: at(0),
          ),
        )
        ..handleEntry(
          StepEntry(
            action: 'Wait until "Home" is visible',
            status: StepEntryStatus.start,
            timestamp: at(100),
          ),
        )
        ..handleEntry(
          StepEntry(
            action: 'Wait until "Home" is visible',
            status: StepEntryStatus.failure,
            timestamp: at(900),
          ),
        )
        ..handleEntry(
          TestEntry(
            name: 'app_test signs in',
            status: TestEntryStatus.failure,
            error: '  Expected: exactly one matching candidate\n',
            timestamp: at(1000),
          ),
        );

      final test = _build(sut).tests.single;
      expect(test.status, DashboardTestStatus.failed);
      expect(test.error, 'Expected: exactly one matching candidate');
      expect(test.steps.single.status, DashboardStepStatus.failed);
      expect(_build(sut).isSuccessful, isFalse);
    });

    test('leaves a test that never finished as incomplete', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'app_test crashes',
            status: TestEntryStatus.start,
            timestamp: at(0),
          ),
        )
        ..handleEntry(
          StepEntry(
            action: 'Tap on "Boom"',
            status: StepEntryStatus.start,
            timestamp: at(50),
          ),
        );

      final test = _build(sut).tests.single;
      expect(test.status, DashboardTestStatus.incomplete);
      expect(test.duration, isNull);
      expect(test.steps.single.status, DashboardStepStatus.running);
      expect(test.steps.single.duration, isNull);
    });

    test('nests logs under the step they were printed from', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'app_test logs',
            status: TestEntryStatus.start,
            timestamp: at(0),
          ),
        )
        ..handleEntry(LogEntry(message: 'before any step', timestamp: at(10)))
        ..handleEntry(
          StepEntry(
            action: 'Tap on "Next"',
            status: StepEntryStatus.start,
            timestamp: at(20),
          ),
        )
        ..handleEntry(LogEntry(message: 'inside the step', timestamp: at(30)))
        ..handleEntry(
          StepEntry(
            action: 'Tap on "Next"',
            status: StepEntryStatus.success,
            timestamp: at(40),
          ),
        )
        ..handleEntry(
          TestEntry(
            name: 'app_test logs',
            status: TestEntryStatus.success,
            timestamp: at(50),
          ),
        );

      final test = _build(sut).tests.single;
      expect(test.logs.map((log) => log.message), ['before any step']);
      expect(test.steps.single.logs.map((log) => log.message), [
        'inside the step',
      ]);
    });

    test('records skipped tests without a finish entry', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'app_test is skipped',
            status: TestEntryStatus.skip,
            timestamp: at(0),
          ),
        );

      final run = _build(sut);
      expect(run.tests.single.status, DashboardTestStatus.skipped);
      expect(run.skippedCount, 1);
      // Skipped tests are not counted against the pass rate.
      expect(run.passRate, 1);
    });

    test('matches finish entries of tests sharing a name in order', () {
      final sut = collector();

      for (var i = 0; i < 2; i++) {
        sut.handleEntry(
          TestEntry(
            name: 'app_test parameterized',
            status: TestEntryStatus.start,
            timestamp: at(i * 100),
          ),
        );
      }
      sut
        ..handleEntry(
          TestEntry(
            name: 'app_test parameterized',
            status: TestEntryStatus.success,
            timestamp: at(300),
          ),
        )
        ..handleEntry(
          TestEntry(
            name: 'app_test parameterized',
            status: TestEntryStatus.failure,
            error: 'boom',
            timestamp: at(400),
          ),
        );

      final run = _build(sut);
      expect(run.tests.map((test) => test.status), [
        DashboardTestStatus.passed,
        DashboardTestStatus.failed,
      ]);
      expect(run.tests.first.duration, const Duration(milliseconds: 300));
      expect(run.tests.last.duration, const Duration(milliseconds: 300));
    });

    test('keeps names logged without a file prefix intact', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'signs the user in',
            status: TestEntryStatus.skip,
            timestamp: at(0),
          ),
        );

      final test = _build(sut).tests.single;
      expect(test.name, 'signs the user in');
      expect(test.filePath, isNull);
    });

    test('resolves nested file prefixes against the test directory', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'permissions.location_test asks for location',
            status: TestEntryStatus.skip,
            timestamp: at(0),
          ),
        );

      final test = _build(sut).tests.single;
      expect(test.name, 'asks for location');
      expect(test.filePath, 'integration_test/permissions/location_test.dart');
    });

    test('attaches a video registered after the test finished', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'app_test signs in',
            status: TestEntryStatus.start,
            timestamp: at(0),
          ),
        )
        ..handleEntry(
          TestEntry(
            name: 'app_test signs in',
            status: TestEntryStatus.success,
            timestamp: at(100),
          ),
        )
        ..registerVideo(
          testName: 'app_test signs in',
          videoPath: '/project/integration_test/videos/signs_in.mp4',
        );

      expect(
        _build(sut).tests.single.videoPath,
        '/project/integration_test/videos/signs_in.mp4',
      );
      expect(_build(sut).hasVideos, isTrue);
    });

    test('attaches a video registered while the test is still running', () {
      final sut = collector()
        ..handleEntry(
          TestEntry(
            name: 'app_test signs in',
            status: TestEntryStatus.start,
            timestamp: at(0),
          ),
        )
        ..registerVideo(
          testName: 'app_test signs in',
          videoPath: '/videos/signs_in.mp4',
        );

      expect(_build(sut).tests.single.videoPath, '/videos/signs_in.mp4');
    });

    test('collects run-level errors and warnings', () {
      final sut = collector()
        ..handleEntry(ErrorEntry(message: 'native automation failed'))
        ..handleEntry(WarningEntry(message: 'printLogs is disabled'));

      final run = _build(sut);
      expect(run.errors, ['native automation failed']);
      expect(run.warnings, ['printLogs is disabled']);
    });
  });
}

DashboardRun _build(DashboardCollector collector) => collector.build(
  platform: 'Android',
  deviceName: 'Pixel 9',
  deviceId: 'emulator-5554',
  buildMode: 'debug',
  startedAt: DateTime(2026, 8, 17, 12),
  duration: const Duration(seconds: 42),
  cliVersion: '4.7.0',
);
