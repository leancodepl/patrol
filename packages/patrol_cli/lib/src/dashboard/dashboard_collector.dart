import 'package:collection/collection.dart';
import 'package:patrol_cli/src/dashboard/dashboard_report.dart';
import 'package:patrol_log/patrol_log.dart';

/// Builds a [DashboardRun] out of the `patrol_log` entry stream.
///
/// The entries come from `PatrolLogReader`, which parses the same `PATROL_LOG`
/// lines on every platform (logcat on Android, the syslog stream on iOS), so
/// the collector is platform-agnostic and both platforms end up with an
/// identical report.
class DashboardCollector {
  /// Creates a collector for tests declared in [testDirectory].
  DashboardCollector({String? testDirectory}) : _testDirectory = testDirectory;

  final String? _testDirectory;

  /// Test cases in the order they were started.
  final List<DashboardTest> _tests = [];

  /// Open tests keyed by description, so a finish entry closes the right one
  /// even when several tests share a name (parameterized tests).
  final Map<String, List<DashboardTest>> _openTests = {};

  /// Absolute video paths keyed by test description. Recordings are saved
  /// asynchronously, so a video may be registered before or after the test's
  /// finish entry arrives.
  final Map<String, String> _videos = {};

  final List<String> _warnings = [];
  final List<String> _errors = [];

  /// Returns an `onLogEntry` callback that feeds this collector and then
  /// delegates to [next].
  void Function(Entry entry) wrapOnLogEntry(void Function(Entry entry)? next) {
    return (entry) {
      handleEntry(entry);
      next?.call(entry);
    };
  }

  /// Records a single log [entry].
  void handleEntry(Entry entry) {
    switch (entry) {
      case TestEntry():
        _handleTestEntry(entry);
      case StepEntry():
        _handleStepEntry(entry);
      case LogEntry():
        _handleLogEntry(entry);
      case ErrorEntry():
        _errors.add(entry.message);
      case WarningEntry():
        _warnings.add(entry.message);
      case ConfigEntry():
        break;
    }
  }

  /// Attaches the video saved for [testName] to its test case.
  ///
  /// Called by the video recording manager, which knows the name of the test it
  /// recorded.
  void registerVideo({required String testName, required String videoPath}) {
    final description = _parseName(testName).description;
    _videos[description] = videoPath;

    final openTest = _openTests[description]?.firstOrNull;
    if (openTest != null) {
      openTest.videoPath = videoPath;
      return;
    }

    // The test already finished, so attach the video to the last matching one.
    final finishedTest = _tests.lastWhereOrNull(
      (test) => test.name == description,
    );
    finishedTest?.videoPath = videoPath;
  }

  /// Builds the report of the finished run.
  DashboardRun build({
    required String platform,
    required String deviceName,
    required String deviceId,
    required String buildMode,
    required DateTime startedAt,
    required Duration duration,
    required String cliVersion,
    String? appDescription,
    String? flavor,
    String? nativeReportPath,
  }) {
    return DashboardRun(
      tests: List<DashboardTest>.unmodifiable(_tests),
      platform: platform,
      deviceName: deviceName,
      deviceId: deviceId,
      buildMode: buildMode,
      startedAt: startedAt,
      duration: duration,
      cliVersion: cliVersion,
      appDescription: appDescription,
      flavor: flavor,
      nativeReportPath: nativeReportPath,
      warnings: List<String>.unmodifiable(_warnings),
      errors: List<String>.unmodifiable(_errors),
    );
  }

  void _handleTestEntry(TestEntry entry) {
    final parsed = _parseName(entry.name);

    switch (entry.status) {
      case TestEntryStatus.start:
        final test = DashboardTest(
          name: parsed.description,
          filePath: _filePath(parsed.filePrefix),
          startedAt: entry.timestamp,
          status: DashboardTestStatus.incomplete,
        )..videoPath = _videos[parsed.description];
        _tests.add(test);
        _openTests.putIfAbsent(parsed.description, () => []).add(test);

      case TestEntryStatus.skip:
        _tests.add(
          DashboardTest(
            name: parsed.description,
            filePath: _filePath(parsed.filePrefix),
            startedAt: entry.timestamp,
            status: DashboardTestStatus.skipped,
          ),
        );

      case TestEntryStatus.success:
      case TestEntryStatus.failure:
        final test = _takeOpenTest(parsed.description);
        if (test == null) {
          return;
        }
        test
          ..status = entry.status == TestEntryStatus.success
              ? DashboardTestStatus.passed
              : DashboardTestStatus.failed
          ..duration = entry.timestamp.difference(test.startedAt)
          ..error = _trimmedOrNull(entry.error)
          ..videoPath ??= _videos[parsed.description];
    }
  }

  void _handleStepEntry(StepEntry entry) {
    final test = _currentOpenTest();
    if (test == null) {
      return;
    }

    switch (entry.status) {
      case StepEntryStatus.start:
        test.steps.add(
          DashboardStep(action: entry.action, startedAt: entry.timestamp),
        );
      case StepEntryStatus.success:
      case StepEntryStatus.failure:
        final step = _takeOpenStep(test, entry.action);
        if (step == null) {
          return;
        }
        step
          ..status = entry.status == StepEntryStatus.success
              ? DashboardStepStatus.passed
              : DashboardStepStatus.failed
          ..duration = entry.timestamp.difference(step.startedAt);
    }
  }

  void _handleLogEntry(LogEntry entry) {
    final test = _currentOpenTest();
    if (test == null) {
      return;
    }

    final log = DashboardLog(
      message: entry.message,
      timestamp: entry.timestamp,
    );
    // Nest the log under the step it was printed from, if any.
    final openStep = _openStep(test);
    (openStep?.logs ?? test.logs).add(log);
  }

  /// The most recently started test that has not finished yet.
  DashboardTest? _currentOpenTest() => _tests.lastWhereOrNull(
    (test) => test.status == DashboardTestStatus.incomplete,
  );

  DashboardTest? _takeOpenTest(String description) {
    final open = _openTests[description];
    if (open == null || open.isEmpty) {
      return null;
    }
    final test = open.removeAt(0);
    if (open.isEmpty) {
      _openTests.remove(description);
    }
    return test;
  }

  DashboardStep? _openStep(DashboardTest test) => test.steps.lastWhereOrNull(
    (step) => step.status == DashboardStepStatus.running,
  );

  DashboardStep? _takeOpenStep(DashboardTest test, String action) {
    final byAction = test.steps.lastWhereOrNull(
      (step) =>
          step.status == DashboardStepStatus.running && step.action == action,
    );
    // Fall back to the newest open step: patrol may reword the action between
    // the start and the finish entry.
    return byAction ?? _openStep(test);
  }

  String? _filePath(String? filePrefix) {
    if (filePrefix == null) {
      return null;
    }
    final file = '${filePrefix.replaceAll('.', '/')}.dart';
    final directory = _testDirectory;
    return directory == null || directory.isEmpty ? file : '$directory/$file';
  }

  static String? _trimmedOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Splits a logged test name into its file prefix and description.
  ///
  /// Patrol logs a test as `<file prefix> <description>`, where the prefix is
  /// the test file path with `.` as the separator, e.g.
  /// `permissions.permissions_location_test opens settings`. Names logged
  /// without a prefix are returned as-is, so the description never loses its
  /// first word.
  static _TestName _parseName(String name) {
    final firstSpace = name.indexOf(' ');
    if (firstSpace == -1) {
      return _TestName(null, name);
    }

    final firstToken = name.substring(0, firstSpace);
    final looksLikeFilePrefix =
        firstToken.endsWith('_test') || firstToken.contains('.');
    if (!looksLikeFilePrefix) {
      return _TestName(null, name);
    }

    return _TestName(firstToken, name.substring(firstSpace + 1));
  }
}

class _TestName {
  _TestName(this.filePrefix, this.description);

  final String? filePrefix;
  final String description;
}
