import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/src/test_results.dart';
import 'package:test/test.dart';

/// A started-but-not-yet-finished attempt.
PatrolSingleTestEntry _openAttempt(String name) =>
    PatrolSingleTestEntry(TestEntry(name: name, status: TestEntryStatus.start));

void _close(PatrolSingleTestEntry attempt, TestEntryStatus status) =>
    attempt.closeTest(TestEntry(name: attempt.name, status: status));

void main() {
  group('TestResults', () {
    test('fail then pass on retry → one flaky test', () {
      final results = TestResults();

      final first = _openAttempt('t');
      results.registerStart('t', first, hasOpenAttempt: false);
      _close(first, TestEntryStatus.failure);

      // The retry starts after the first attempt has closed with a failure.
      final retry = _openAttempt('t');
      results.registerStart('t', retry, hasOpenAttempt: false);
      _close(retry, TestEntryStatus.success);

      expect(results.total, 1);
      expect(results.flaky, hasLength(1));
      expect(results.failed, isEmpty);
      expect(results.passed, isEmpty);
    });

    test('fails every attempt → one failed test', () {
      final results = TestResults();

      final first = _openAttempt('t');
      results.registerStart('t', first, hasOpenAttempt: false);
      _close(first, TestEntryStatus.failure);

      final retry = _openAttempt('t');
      results.registerStart('t', retry, hasOpenAttempt: false);
      _close(retry, TestEntryStatus.failure);

      expect(results.total, 1);
      expect(results.failed, hasLength(1));
      expect(results.flaky, isEmpty);
    });

    test('passes first attempt → one passed test', () {
      final results = TestResults();

      final attempt = _openAttempt('t');
      results.registerStart('t', attempt, hasOpenAttempt: false);
      _close(attempt, TestEntryStatus.success);

      expect(results.total, 1);
      expect(results.passed, hasLength(1));
      expect(results.flaky, isEmpty);
      expect(results.failed, isEmpty);
    });

    test(
      'two distinct tests sharing a name run in parallel → two tests, not a retry',
      () {
        final results = TestResults();

        // Both attempts are open at the same time, so the second start is a
        // distinct test, not a retry of the first.
        final a = _openAttempt('dup');
        results.registerStart('dup', a, hasOpenAttempt: false);
        final b = _openAttempt('dup');
        results.registerStart('dup', b, hasOpenAttempt: true);

        _close(a, TestEntryStatus.success);
        _close(b, TestEntryStatus.failure);

        expect(results.total, 2);
        expect(results.passed, hasLength(1));
        expect(results.failed, hasLength(1));
        expect(results.flaky, isEmpty);
      },
    );

    test('a passed test is never treated as a retry target', () {
      final results = TestResults();

      final passed = _openAttempt('t');
      results.registerStart('t', passed, hasOpenAttempt: false);
      _close(passed, TestEntryStatus.success);

      // A later same-name start must be a new test, not a retry, because a
      // passed test is never retried.
      final second = _openAttempt('t');
      results.registerStart('t', second, hasOpenAttempt: false);
      _close(second, TestEntryStatus.success);

      expect(results.total, 2);
      expect(results.passed, hasLength(2));
      expect(results.flaky, isEmpty);
    });
  });
}
