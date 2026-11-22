import 'package:file/memory.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/crossplatform/executed_tests_check.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
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

  group('expectedTestNames', () {
    test('expects every test, skipped ones included, without --only', () {
      expect(expectedTestNames(manifest.tests), [
        'example_test a',
        'example_test b',
        'other_test c',
      ]);
    });

    test('expects only the tests and files --only selects', () {
      expect(expectedTestNames(manifest.tests, onlyTests: ['other_test c']), [
        'other_test c',
      ]);
      expect(
        expectedTestNames(manifest.tests, onlyTests: ['example_test.dart']),
        ['example_test a', 'example_test b'],
      );
    });
  });

  group('ExecutedTestsCheck', () {
    late ExecutedTestsCheck check;

    setUp(() => check = ExecutedTestsCheck.fromManifest(manifest));

    test('passes when the app logged a result for every test', () {
      check
        ..onLogEntry(_result('example_test a', TestEntryStatus.success))
        ..onLogEntry(_result('example_test b', TestEntryStatus.skip))
        ..onLogEntry(_result('other_test c', TestEntryStatus.failure));

      expect(check.verify, returnsNormally);
    });

    test('fails when no test ran', () {
      expect(
        check.verify,
        _toolExit(
          allOf(
            contains('found 3 test(s), but only 0 ran'),
            contains('MainActivityTest.java'),
          ),
        ),
      );
    });

    test('fails and names the tests that did not run', () {
      check
        ..onLogEntry(_result('example_test a', TestEntryStatus.start))
        ..onLogEntry(_result('example_test a', TestEntryStatus.success))
        ..onLogEntry(_result('example_test b', TestEntryStatus.skip));

      expect(
        check.verify,
        _toolExit(
          allOf(
            contains('but only 2 ran'),
            contains('  - other_test c'),
            isNot(contains('example_test a\n')),
          ),
        ),
      );
    });

    test('a started test without a result did not run to the end', () {
      check.onLogEntry(_result('other_test c', TestEntryStatus.start));

      expect(check.missing, contains('other_test c'));
    });

    test('trusts the native runner count when device logs are lost', () {
      check.onRunnerOutput('Executed 3 tests, with 0 failures (0 unexpected)');

      expect(check.verify, returnsNormally);
    });

    test('reads the counts of am instrument and Gradle', () {
      check.onRunnerOutput('OK (3 tests)');
      expect(check.executedCount, 3);

      final gradle = ExecutedTestsCheck.fromManifest(manifest)
        ..onRunnerOutput('Finished 3 tests on emulator-5554 - 14');
      expect(gradle.executedCount, 3);
    });

    test('a smaller runner count does not hide logged results', () {
      check
        ..onLogEntry(_result('example_test a', TestEntryStatus.success))
        ..onLogEntry(_result('example_test b', TestEntryStatus.skip))
        ..onLogEntry(_result('other_test c', TestEntryStatus.success))
        ..onRunnerOutput('OK (1 test)');

      expect(check.verify, returnsNormally);
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
      fs.file('/app/build/patrol/patrol_test_manifest.json')
        ..createSync(recursive: true)
        ..writeAsStringSync(_manifest);
    });

    test('checks runs with build-time discovery', () {
      final check = ExecutedTestsCheck.forRun(
        fs.directory('/app'),
        MockLogger(),
        emitTestManifest: true,
      );

      expect(check?.expected, hasLength(3));
    });

    test('skips runtime discovery even with a manifest left from before', () {
      final check = ExecutedTestsCheck.forRun(
        fs.directory('/app'),
        MockLogger(),
        emitTestManifest: false,
      );

      expect(check, isNull);
    });

    test('skips develop sessions', () {
      final check = ExecutedTestsCheck.forRun(
        fs.directory('/app'),
        MockLogger(),
        emitTestManifest: true,
        interruptible: true,
      );

      expect(check, isNull);
    });
  });
}
