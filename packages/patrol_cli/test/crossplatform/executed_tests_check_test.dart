import 'package:file/memory.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/crossplatform/executed_tests_check.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

const _manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"example_test","type":"group","skip":false,"entries":[
    {"name":"a","type":"test","skip":false},
    {"name":"b","type":"test","skip":true}
  ]},
  {"name":"other_test","type":"group","skip":false,"entries":[
    {"name":"c","type":"test","skip":false}
  ]}
]}}
''';

TestEntry _result(String name, TestEntryStatus status) =>
    TestEntry(name: name, status: status);

Matcher _toolExit(Object messageMatcher) => throwsA(
  isA<ToolExit>().having((e) => e.message, 'message', messageMatcher),
);

void main() {
  final manifest = TestManifest.parse(_manifest);

  group('selectedTests', () {
    List<String> names(List<DiscoveredTest> tests) => [
      for (final test in tests) test.dartName,
    ];

    test('selects every test, skipped ones included, without --only', () {
      expect(names(selectedTests(manifest.tests)), [
        'example_test a',
        'example_test b',
        'other_test c',
      ]);
    });

    test('selects only the tests and files --only names', () {
      expect(
        names(selectedTests(manifest.tests, onlyTests: ['other_test c'])),
        ['other_test c'],
      );
      expect(
        names(selectedTests(manifest.tests, onlyTests: ['example_test.dart'])),
        ['example_test a', 'example_test b'],
      );
    });
  });

  group('ExecutedTestsCheck', () {
    late ExecutedTestsCheck check;

    setUp(() => check = ExecutedTestsCheck.fromManifest(manifest));

    test('does not expect skipped tests, which the app never reports', () {
      expect(check.expected, ['example_test a', 'other_test c']);
    });

    test('passes when the app logged a result for every test', () {
      check
        ..onLogEntry(_result('example_test a', TestEntryStatus.success))
        ..onLogEntry(_result('other_test c', TestEntryStatus.failure));

      expect(check.verify, returnsNormally);
    });

    test('fails when no test ran', () {
      expect(
        check.verify,
        _toolExit(
          allOf(
            contains('3 test(s) should have run, but only 0 did'),
            contains('MainActivityTest.java'),
          ),
        ),
      );
    });

    test('fails and names only the tests that did not run', () {
      check
        ..onLogEntry(_result('example_test a', TestEntryStatus.start))
        ..onLogEntry(_result('example_test a', TestEntryStatus.success));

      expect(
        check.verify,
        _toolExit(
          allOf(
            contains('but only 1 did'),
            contains('  - other_test c'),
            isNot(contains('example_test a\n')),
            isNot(contains('example_test b')),
          ),
        ),
      );
    });

    test('a started test without a result did not run to the end', () {
      check.onLogEntry(_result('other_test c', TestEntryStatus.start));

      expect(check.missing, contains('other_test c'));
    });

    test('trusts the native runner count when the app logged nothing', () {
      check.onRunnerOutput('Executed 3 tests, with 0 failures (0 unexpected)');

      expect(check.verify, returnsNormally);
    });

    test('compares the runner count with skipped tests included', () {
      // 3 selected, 1 of them skipped: the runner counts the skipped one too.
      check.onRunnerOutput('OK (2 tests)');

      expect(
        check.verify,
        _toolExit(contains('3 test(s) should have run, but only 2 did')),
      );
    });

    test('reads the counts of am instrument and Gradle', () {
      check.onRunnerOutput('OK (3 tests)');
      expect(check.executedCount, 3);

      final gradle = ExecutedTestsCheck.fromManifest(manifest)
        ..onRunnerOutput('Finished 3 tests on emulator-5554 - 14');
      expect(gradle.executedCount, 3);
    });

    test('trusts the names over the count when the app logged results', () {
      // A stale test APK: as many tests as the manifest, but other ones.
      check
        ..onLogEntry(_result('example_test old', TestEntryStatus.success))
        ..onLogEntry(_result('other_test old', TestEntryStatus.success))
        ..onRunnerOutput('OK (3 tests)');

      expect(
        check.verify,
        _toolExit(
          allOf(contains('but only 0 did'), contains('  - example_test a')),
        ),
      );
    });

    test('passes when every selected test is skipped', () {
      final skipped = ExecutedTestsCheck.fromManifest(
        manifest,
        onlyTests: ['example_test b'],
      );

      expect(skipped.expected, isEmpty);
      expect(skipped.verify, returnsNormally);
    });

    test('fails when discovery found no tests', () {
      expect(
        ExecutedTestsCheck(const []).verify,
        _toolExit(contains('found no tests to run')),
      );
    });
  });

  group('ExecutedTestsCheck.forRun', () {
    late MemoryFileSystem fs;

    setUp(() {
      fs = MemoryFileSystem.test();
      fs.file('/app/build/patrol/android/patrol_test_manifest.json')
        ..createSync(recursive: true)
        ..writeAsStringSync(_manifest);
    });

    test('checks runs with build-time discovery', () {
      final check = ExecutedTestsCheck.forRun(
        fs.directory('/app'),
        MockLogger(),
        platform: TargetPlatform.android,
        emitTestManifest: true,
      );

      expect(check?.expected, hasLength(2));
    });

    test('skips runtime discovery even with a manifest left from before', () {
      final check = ExecutedTestsCheck.forRun(
        fs.directory('/app'),
        MockLogger(),
        platform: TargetPlatform.android,
        emitTestManifest: false,
      );

      expect(check, isNull);
    });

    test('skips develop sessions', () {
      final check = ExecutedTestsCheck.forRun(
        fs.directory('/app'),
        MockLogger(),
        platform: TargetPlatform.android,
        emitTestManifest: true,
        interruptible: true,
      );

      expect(check, isNull);
    });

    test("reads the manifest of the device's platform only", () {
      final check = ExecutedTestsCheck.forRun(
        fs.directory('/app'),
        MockLogger(),
        platform: TargetPlatform.iOS,
        emitTestManifest: true,
      );

      expect(check, isNull);
    });
  });
}
