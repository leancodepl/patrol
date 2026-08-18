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

  /// The test currently running, and its currently running step.
  ///
  /// Steps and logs arrive far more often than tests do, so the entries they
  /// attach to are tracked directly instead of being searched for on each one.
  DashboardTest? _openTest;
  DashboardStep? _openStep;

  final List<String> _warnings = [];
  final List<String> _errors = [];

  /// Test whose failure details are still arriving.
  ///
  /// On mobile, patrol logs the failure entry without an error and then sends
  /// the exception one [ErrorEntry] per line, so the lines have to be stitched
  /// back onto the test that just failed.
  DashboardTest? _failureDetailsTarget;

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
        _appendErrorLine(entry.message);
      case WarningEntry():
        _warnings.add(entry.message);
      case ConfigEntry():
        break;
    }
  }

  /// Attaches the video saved for [testName] to its test case.
  ///
  /// Called by the video recording manager once a recording is saved, which
  /// happens after the test it belongs to has finished.
  void registerVideo({required String testName, required String videoPath}) {
    final description = _parseName(testName).description;
    _tests.lastWhereOrNull((test) => test.name == description)?.videoPath =
        videoPath;
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
    for (final test in _tests) {
      test.error = _trimmedOrNull(test.error);
    }

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
    // Any new lifecycle event ends the previous failure's detail lines.
    _failureDetailsTarget = null;

    switch (entry.status) {
      case TestEntryStatus.start:
        final test = DashboardTest(
          name: parsed.description,
          filePath: _filePath(parsed.filePrefix),
          startedAt: entry.timestamp,
          status: DashboardTestStatus.incomplete,
        );
        _tests.add(test);
        _openTest = test;
        _openStep = null;

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
          ..error = _trimmedOrNull(entry.error);
        if (test == _openTest) {
          _openTest = null;
          _openStep = null;
        }

        if (entry.status == TestEntryStatus.failure) {
          _failureDetailsTarget = test;
        }
    }
  }

  /// Appends one line of a failure message, either to the test it belongs to
  /// or, when no test is failing, to the run-level errors.
  void _appendErrorLine(String line) {
    final target = _failureDetailsTarget;
    if (target == null) {
      _errors.add(line);
      return;
    }

    final existing = target.error;
    target.error = existing == null ? line : '$existing\n$line';
  }

  void _handleStepEntry(StepEntry entry) {
    _failureDetailsTarget = null;
    final test = _openTest;
    if (test == null) {
      return;
    }

    switch (entry.status) {
      case StepEntryStatus.start:
        final step = DashboardStep(
          action: entry.action,
          startedAt: entry.timestamp,
        );
        test.steps.add(step);
        _openStep = step;
      case StepEntryStatus.success:
      case StepEntryStatus.failure:
        final step = _openStep;
        if (step == null) {
          return;
        }
        step
          ..status = entry.status == StepEntryStatus.success
              ? DashboardStepStatus.passed
              : DashboardStepStatus.failed
          ..duration = entry.timestamp.difference(step.startedAt);
        _openStep = null;
    }
  }

  void _handleLogEntry(LogEntry entry) {
    final test = _openTest;
    if (test == null) {
      return;
    }
    // Nest the log under the step it was printed from, if any.
    (_openStep?.logs ?? test.logs).add(entry.message);
  }

  /// The oldest test with this name that has not finished yet.
  ///
  /// `_tests` is in start order, so the first match is the FIFO one — which is
  /// what pairs a finish entry with its start when a parameterized test reuses
  /// a name.
  DashboardTest? _takeOpenTest(String description) => _tests.firstWhereOrNull(
    (test) =>
        test.name == description &&
        test.status == DashboardTestStatus.incomplete,
  );

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
