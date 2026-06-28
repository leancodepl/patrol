import 'package:patrol_log/patrol_log.dart';

/// A logical test, collapsing all attempts (the initial run plus any retries)
/// of a single test into one outcome.
class TestRun {
  /// Attempts in execution order. The last attempt determines the final
  /// outcome of the test.
  final List<PatrolSingleTestEntry> attempts = [];

  /// The last (most recent) attempt of this test.
  PatrolSingleTestEntry get last => attempts.last;

  /// Whether every attempt of this test has finished.
  bool get isClosed => attempts.every((a) => a.closingTestEntry != null);

  /// Whether any attempt of this test failed.
  bool get _hasFailure =>
      attempts.any((a) => a.status == TestEntryStatus.failure);

  /// The test passed on every attempt (no failed attempt).
  bool get passed => last.status == TestEntryStatus.success && !_hasFailure;

  /// The test failed at least once but passed on a later retry.
  bool get flaky => last.status == TestEntryStatus.success && _hasFailure;

  /// The test failed on its last attempt (all retries exhausted).
  bool get failed => last.status == TestEntryStatus.failure;
}

/// Aggregates per-attempt test entries into per-test outcomes.
///
/// Each test attempt (the initial run plus any retries) is collapsed into a
/// single [TestRun], so a test that fails then passes on retry is reported as
/// flaky rather than failed. Retries only happen on the web backend
/// (Playwright); on mobile every test has a single attempt, so every run is
/// trivially passed or failed.
class TestResults {
  final List<TestRun> _runs = [];
  final Map<String, List<TestRun>> _runsByName = {};

  /// Tests that passed on every attempt (no failed attempt). Flaky tests are
  /// reported separately and are NOT included here.
  List<TestRun> get passed => _runs.where((r) => r.passed).toList();

  /// Tests that failed at least one attempt but passed on a later retry.
  List<TestRun> get flaky => _runs.where((r) => r.flaky).toList();

  /// Tests that failed on every attempt (all retries exhausted).
  List<TestRun> get failed => _runs.where((r) => r.failed).toList();

  /// The number of distinct tests (not attempts). A flaky test that ran twice
  /// counts once.
  int get total => _runs.length;

  /// Registers a starting test attempt, grouping it into a [TestRun].
  ///
  /// A new attempt is treated as a **retry** of an existing test (and grouped
  /// with it) only when there is no other attempt of the same name currently
  /// open ([hasOpenAttempt] is `false`) AND the most recent closed run for that
  /// name ended in a failure — which mirrors Playwright semantics, where a test
  /// is retried only after it fails and retries run sequentially.
  ///
  /// Otherwise it starts a **new** logical test. In particular, when another
  /// attempt with the same name is still open (e.g. two distinct tests sharing
  /// a name running in parallel across workers/shards), the attempts are kept
  /// as separate logical tests.
  ///
  /// Note: matching is name-based, so two genuinely different tests that share
  /// an identical (normalized) name and run sequentially — one failing, one
  /// passing — can be collapsed into a single flaky test. This is an inherent
  /// limitation of name-based grouping and is accepted as a rare edge case.
  void registerStart(
    String normalizedTestName,
    PatrolSingleTestEntry attempt, {
    required bool hasOpenAttempt,
  }) {
    final retryTarget = hasOpenAttempt
        ? null
        : _findRetryTarget(normalizedTestName);

    if (retryTarget != null) {
      retryTarget.attempts.add(attempt);
    } else {
      final run = TestRun()..attempts.add(attempt);
      _runs.add(run);
      _runsByName.putIfAbsent(normalizedTestName, () => []).add(run);
    }
  }

  /// Returns the most recent closed run for [normalizedTestName] that ended in
  /// a failure (i.e. a candidate to be retried), or `null` if there is none.
  TestRun? _findRetryTarget(String normalizedTestName) {
    final runs = _runsByName[normalizedTestName];
    if (runs == null) {
      return null;
    }

    for (var i = runs.length - 1; i >= 0; i--) {
      final run = runs[i];
      if (run.isClosed && run.last.status == TestEntryStatus.failure) {
        return run;
      }
    }
    return null;
  }
}
