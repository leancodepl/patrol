import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';

/// Fails a run in which fewer tests ran than the build-time manifest lists.
///
/// Native runners report success when no test ran, so the manifest is the
/// only list of what should have run. A test counts as run when the app logged
/// its result, or when the native runner reports at least that many tests
/// (device logs can arrive late).
class ExecutedTestsCheck {
  ExecutedTestsCheck(this.expected, {this.selectedCount});

  /// Expects every test in [manifest], or only the ones [onlyTests] selects,
  /// except skipped ones, which the native runner skips without the app.
  factory ExecutedTestsCheck.fromManifest(
    TestManifest manifest, {
    List<String> onlyTests = const [],
  }) {
    final selected = selectedTests(manifest.tests, onlyTests: onlyTests);
    return ExecutedTestsCheck([
      for (final test in selected)
        if (!test.skip) test.dartName,
    ], selectedCount: selected.length);
  }

  /// The check for a run of the app in [rootDirectory], or `null` when
  /// build-time discovery is off, the run is a `develop` session, or there is
  /// no manifest to compare with.
  static ExecutedTestsCheck? forRun(
    Directory rootDirectory,
    Logger logger, {
    required TargetPlatform platform,
    required bool emitTestManifest,
    bool interruptible = false,
    List<String> onlyTests = const [],
  }) {
    if (!emitTestManifest || interruptible) {
      return null;
    }
    final manifest = TestManifest.loadFromBuild(
      rootDirectory,
      platform: platform,
    );
    if (manifest == null) {
      logger.warn(
        'No build-time test manifest found, so Patrol cannot check that every '
        'test ran.',
      );
      return null;
    }
    return ExecutedTestsCheck.fromManifest(manifest, onlyTests: onlyTests);
  }

  /// Dart names of the tests that must run.
  final List<String> expected;

  /// How many tests the run selects, skipped ones included.
  final int? selectedCount;

  final _finished = <String>{};
  var _runnerCount = 0;

  static final _runnerCountPatterns = [
    // xcodebuild
    RegExp(r'Executed (\d+) tests?, with'),
    // am instrument
    RegExp(r'^OK \((\d+) tests?\)'),
    RegExp(r'^Tests run: (\d+),'),
    // Gradle connected tests
    RegExp(r'Finished (\d+) tests? on '),
  ];

  /// [onLogEntry] that also records the entry here.
  void Function(Entry entry) wrapOnLogEntry(
    void Function(Entry entry)? onLogEntry,
  ) {
    return (entry) {
      this.onLogEntry(entry);
      onLogEntry?.call(entry);
    };
  }

  /// Records a test result the app logged.
  void onLogEntry(Entry entry) {
    if (entry is TestEntry && entry.status != TestEntryStatus.start) {
      _finished.add(entry.name);
    }
  }

  /// Reads a line of native runner output for the number of tests it ran.
  void onRunnerOutput(String line) {
    final trimmed = line.trim();
    for (final pattern in _runnerCountPatterns) {
      final match = pattern.firstMatch(trimmed);
      if (match != null) {
        final count = int.parse(match.group(1)!);
        if (count > _runnerCount) {
          _runnerCount = count;
        }
      }
    }
  }

  /// Expected tests the app logged no result for.
  List<String> get missing =>
      expected.where((name) => !_finished.contains(name)).toList();

  /// The number of expected tests that ran. The runner count stands in only
  /// when the app logged no result at all, because device logs can be lost.
  int get executedCount {
    if (_finished.isEmpty) {
      return _runnerCount;
    }
    return expected.length - missing.length;
  }

  /// Like [verify], but fails [task] for [subject] first.
  void verifyTask(Progress task, String subject) {
    try {
      verify();
    } on ToolExit {
      task.fail('Failed to execute tests of $subject (not every test ran)');
      rethrow;
    }
  }

  /// Throws a [ToolExit] when fewer tests ran than [expected].
  void verify() {
    if ((selectedCount ?? expected.length) == 0) {
      throwToolExit(
        'Build-time test discovery found no tests to run. Check the test '
        'targets and the --tags/--exclude-tags filters.',
      );
    }

    final executed = executedCount;
    if (executed >= expected.length) {
      return;
    }

    final missingNames = missing;
    final buffer = StringBuffer(
      '${expected.length} test(s) should have run, but only $executed did.',
    );
    if (missingNames.isNotEmpty) {
      const shown = 20;
      buffer.write('\nTests that did not run:');
      for (final name in missingNames.take(shown)) {
        buffer.write('\n  - $name');
      }
      if (missingNames.length > shown) {
        buffer.write('\n  ...and ${missingNames.length - shown} more');
      }
    }
    if (executed == 0) {
      buffer.write(
        '\n\nOn Android, check that android/app/src/androidTest has the '
        'Patrol test class (MainActivityTest.java) and that the app could be '
        'installed. Run with --verbose to see the native runner output.',
      );
    }
    throwToolExit(buffer.toString());
  }
}

/// The tests in [tests] that a run with [onlyTests] selects: every test when
/// [onlyTests] is empty, otherwise the requested tests and every test of a
/// requested file.
List<DiscoveredTest> selectedTests(
  List<DiscoveredTest> tests, {
  List<String> onlyTests = const [],
}) {
  if (onlyTests.isEmpty) {
    return tests;
  }

  final selection = resolveOnlySelection(tests, onlyTests);
  final names = generatePerFileTestNames(tests);
  final classes = selection.classNames.toSet();
  final picked = selection.tests.map((t) => t.qualified).toSet();
  return [
    for (var i = 0; i < tests.length; i++)
      if (classes.contains(names[i].className) ||
          picked.contains(names[i].qualified))
        tests[i],
  ];
}
