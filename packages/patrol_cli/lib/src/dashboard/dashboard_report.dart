/// Data model of the HTML dashboard produced after a `patrol test` run.
///
/// The model is filled in by `DashboardCollector` from the platform-agnostic
/// `patrol_log` entry stream, so a run on Android and a run on iOS produce the
/// same structure and therefore the same report.
library;

/// Result of a single test case.
enum DashboardTestStatus {
  /// The test finished successfully.
  passed,

  /// The test finished with a failure.
  failed,

  /// The test was skipped, e.g. by a `--tags` filter.
  skipped,

  /// The test started but never reported a result, e.g. because the app
  /// crashed or the run was interrupted.
  incomplete;

  /// Label shown on the test's status badge.
  String get label => switch (this) {
    DashboardTestStatus.passed => 'Passed',
    DashboardTestStatus.failed => 'Failed',
    DashboardTestStatus.skipped => 'Skipped',
    DashboardTestStatus.incomplete => 'Incomplete',
  };
}

/// Result of a single Patrol step within a test.
enum DashboardStepStatus {
  /// The step finished successfully.
  passed,

  /// The step finished with a failure.
  failed,

  /// The step never reported a result, so it was still running when the test
  /// ended. Usually the step that made the test fail.
  running,
}

/// A single Patrol step, e.g. a tap or a `waitUntilVisible` call.
///
/// Mutable while the run is being collected; treated as read-only afterwards.
class DashboardStep {
  /// Creates a step that started at [startedAt].
  DashboardStep({required this.action, required this.startedAt});

  /// Description of the step, as logged by `patrol`.
  final String action;

  /// When the step started.
  final DateTime startedAt;

  /// Log lines printed while this step was running.
  final List<String> logs = [];

  /// The step's result.
  DashboardStepStatus status = DashboardStepStatus.running;

  /// How long the step took, or `null` if it never finished.
  Duration? duration;
}

/// A single test case of the run.
///
/// Mutable while the run is being collected; treated as read-only afterwards.
class DashboardTest {
  /// Creates a test case that started at [startedAt].
  DashboardTest({
    required this.name,
    required this.filePath,
    required this.startedAt,
    required this.status,
  });

  /// The test description, without the file prefix Patrol logs it with.
  final String name;

  /// Path of the file declaring the test, relative to the project root, or
  /// `null` when the log entry carried no file prefix.
  final String? filePath;

  /// When the test started.
  final DateTime startedAt;

  /// Steps executed by the test, in order.
  final List<DashboardStep> steps = [];

  /// Log lines printed before the test's first step.
  final List<String> logs = [];

  /// The test's result.
  DashboardTestStatus status;

  /// How long the test took, or `null` if it never finished.
  Duration? duration;

  /// Failure message with the stack trace, when the test failed.
  String? error;

  /// Absolute path of the video recorded for this test, when `--record-video`
  /// was used and the recording succeeded.
  String? videoPath;

  /// Whether the test has anything to show in its expanded view.
  bool get hasDetails =>
      steps.isNotEmpty || logs.isNotEmpty || error != null || videoPath != null;

  /// The longest step duration, used to scale the step duration bars.
  Duration get longestStepDuration => steps
      .map((step) => step.duration ?? Duration.zero)
      .fold(
        Duration.zero,
        (longest, duration) => duration > longest ? duration : longest,
      );
}

/// Everything the dashboard shows about one `patrol test` run.
class DashboardRun {
  /// Creates a run description.
  DashboardRun({
    required this.tests,
    required this.platform,
    required this.deviceName,
    required this.deviceId,
    required this.buildMode,
    required this.startedAt,
    required this.duration,
    required this.cliVersion,
    this.appDescription,
    this.flavor,
    this.nativeReportPath,
    this.warnings = const [],
    this.errors = const [],
  });

  /// Test cases of the run, in the order they were started.
  final List<DashboardTest> tests;

  /// Human-readable target platform, e.g. `Android` or `iOS`.
  final String platform;

  /// Name of the device the tests ran on.
  final String deviceName;

  /// Id (serial / UDID) of the device the tests ran on.
  final String deviceId;

  /// Build mode the app was built in, e.g. `debug`.
  final String buildMode;

  /// When the run started.
  final DateTime startedAt;

  /// How long the whole run took.
  final Duration duration;

  /// Version of `patrol_cli` that produced the report.
  final String cliVersion;

  /// Description of the app under test, when known.
  final String? appDescription;

  /// Flavor the app was built with, when any.
  final String? flavor;

  /// Path to the platform's own report (Gradle HTML report or `.xcresult`).
  final String? nativeReportPath;

  /// Warnings reported during the run, not tied to a single test.
  final List<String> warnings;

  /// Errors reported during the run, not tied to a single test.
  final List<String> errors;

  /// Total number of test cases.
  int get totalCount => tests.length;

  /// Number of tests that passed.
  int get passedCount => _countWith(DashboardTestStatus.passed);

  /// Number of tests that failed.
  int get failedCount => _countWith(DashboardTestStatus.failed);

  /// Number of tests that were skipped.
  int get skippedCount => _countWith(DashboardTestStatus.skipped);

  /// Number of tests that never reported a result.
  int get incompleteCount => _countWith(DashboardTestStatus.incomplete);

  /// Whether the whole run is green.
  bool get isSuccessful => failedCount == 0 && incompleteCount == 0;

  /// Share of executed (non-skipped) tests that passed, from 0 to 1.
  double get passRate {
    final executed = totalCount - skippedCount;
    if (executed <= 0) {
      return 1;
    }
    return passedCount / executed;
  }

  int _countWith(DashboardTestStatus status) =>
      tests.where((test) => test.status == status).length;
}
