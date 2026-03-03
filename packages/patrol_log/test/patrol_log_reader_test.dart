import 'dart:convert';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:test/test.dart';

PatrolLogReader _buildReader({List<String>? capturedLogs}) {
  return PatrolLogReader(
    scope: DisposeScope(),
    listenStdOut: (onData, {onError, onDone, cancelOnError}) =>
        const Stream<String>.empty().listen(onData),
    log: (capturedLogs ?? []).add,
    reportPath: 'test_report.html',
    showFlutterLogs: false,
    hideTestSteps: false,
    clearTestSteps: false,
    hideTestLifecycle: true,
  );
}

String _patrolLogLine(Map<String, dynamic> json) =>
    'PATROL_LOG ${jsonEncode(json)}';

Map<String, dynamic> _testEntryJson({
  required String name,
  required String status,
  String? error,
}) => {
  'type': 'test',
  'name': name,
  'status': status,
  'timestamp': DateTime.now().toIso8601String(),
  'error': error,
};

void main() {
  group('PatrolLogReader', () {
    group('parseEntry', () {
      test('parses TestEntry with start status', () {
        final entry = PatrolLogReader.parseEntry(
          '{"type":"test","name":"my test","status":"start","timestamp":"2024-01-01T00:00:00.000Z","error":null}',
        );
        expect(entry, isA<TestEntry>());
        final testEntry = entry as TestEntry;
        expect(testEntry.name, 'my test');
        expect(testEntry.status, TestEntryStatus.start);
      });

      test('parses TestEntry with success status', () {
        final entry = PatrolLogReader.parseEntry(
          '{"type":"test","name":"my test","status":"success","timestamp":"2024-01-01T00:00:00.000Z","error":null}',
        );
        final testEntry = entry as TestEntry;
        expect(testEntry.status, TestEntryStatus.success);
      });

      test('parses TestEntry with failure status and error', () {
        final entry = PatrolLogReader.parseEntry(
          '{"type":"test","name":"my test","status":"failure","timestamp":"2024-01-01T00:00:00.000Z","error":"Something went wrong"}',
        );
        final testEntry = entry as TestEntry;
        expect(testEntry.status, TestEntryStatus.failure);
        expect(testEntry.error, 'Something went wrong');
      });

      test('parses TestEntry with skip status', () {
        final entry = PatrolLogReader.parseEntry(
          '{"type":"test","name":"my test","status":"skip","timestamp":"2024-01-01T00:00:00.000Z","error":null}',
        );
        final testEntry = entry as TestEntry;
        expect(testEntry.status, TestEntryStatus.skip);
      });

      test('parses StepEntry', () {
        final entry = PatrolLogReader.parseEntry(
          '{"type":"step","action":"tap","status":"start","timestamp":"2024-01-01T00:00:00.000Z","data":null}',
        );
        expect(entry, isA<StepEntry>());
      });

      test('parses LogEntry', () {
        final entry = PatrolLogReader.parseEntry(
          '{"type":"log","message":"hello","timestamp":"2024-01-01T00:00:00.000Z"}',
        );
        expect(entry, isA<LogEntry>());
        expect((entry as LogEntry).message, 'hello');
      });

      test('throws on unknown entry type', () {
        expect(
          () => PatrolLogReader.parseEntry(
            '{"type":"unknown","timestamp":"2024-01-01T00:00:00.000Z"}',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('_normalizeTestName (via test matching)', () {
      late PatrolLogReader reader;

      setUp(() async {
        reader = _buildReader();
        await reader.readEntries();
      });

      tearDown(() => reader.close());

      test('matches start and finish entries with the same name', () async {
        reader
          ..parse(
            _patrolLogLine(_testEntryJson(name: 'my test', status: 'start')),
          )
          ..parse(
            _patrolLogLine(_testEntryJson(name: 'my test', status: 'success')),
          );

        await pumpEventQueue();

        expect(reader.totalTests, 1);
        expect(reader.successfulTests, 1);
      });

      test(
        'matches web-prefixed finish entry to non-prefixed start entry',
        () async {
          reader
            ..parse(
              _patrolLogLine(_testEntryJson(name: 'my test', status: 'start')),
            )
            ..parse(
              _patrolLogLine(
                _testEntryJson(
                  name: 'web.some_test my test',
                  status: 'success',
                ),
              ),
            );

          await pumpEventQueue();

          expect(reader.totalTests, 1);
          expect(reader.successfulTests, 1);
          expect(reader.failedTestsCount, 0);
        },
      );

      test(
        'matches web-prefixed failed finish entry to non-prefixed start entry',
        () async {
          reader
            ..parse(
              _patrolLogLine(_testEntryJson(name: 'my test', status: 'start')),
            )
            ..parse(
              _patrolLogLine(
                _testEntryJson(
                  name: 'web.some_test my test',
                  status: 'failure',
                  error: 'Test failed',
                ),
              ),
            );

          await pumpEventQueue();

          expect(reader.totalTests, 1);
          expect(reader.failedTestsCount, 1);
        },
      );

      test('does not strip prefix when first token has no dot', () async {
        // 'myprefix test' — first token 'myprefix' has no dot, so it is not treated as a web prefix
        reader
          ..parse(
            _patrolLogLine(
              _testEntryJson(name: 'myprefix test', status: 'start'),
            ),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(name: 'myprefix test', status: 'success'),
            ),
          );

        await pumpEventQueue();

        expect(reader.totalTests, 1);
        expect(reader.successfulTests, 1);
      });

      test('handles test name with no spaces (single token)', () async {
        reader
          ..parse(
            _patrolLogLine(_testEntryJson(name: 'mytestname', status: 'start')),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(name: 'mytestname', status: 'success'),
            ),
          );

        await pumpEventQueue();

        expect(reader.totalTests, 1);
        expect(reader.successfulTests, 1);
      });

      test('matches multiple tests with the same name in FIFO order', () async {
        reader
          ..parse(
            _patrolLogLine(_testEntryJson(name: 'my test', status: 'start')),
          )
          ..parse(
            _patrolLogLine(_testEntryJson(name: 'my test', status: 'start')),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(name: 'web.shard1 my test', status: 'success'),
            ),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(
                name: 'web.shard2 my test',
                status: 'failure',
                error: 'Error',
              ),
            ),
          );

        await pumpEventQueue();

        expect(reader.totalTests, 2);
        expect(reader.successfulTests, 1);
        expect(reader.failedTestsCount, 1);
      });

      test('strips only the first token when prefix contains a dot', () async {
        // 'web.file test name with spaces' should normalize to 'test name with spaces'
        reader
          ..parse(
            _patrolLogLine(
              _testEntryJson(name: 'test name with spaces', status: 'start'),
            ),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(
                name: 'web.file test name with spaces',
                status: 'success',
              ),
            ),
          );

        await pumpEventQueue();

        expect(reader.totalTests, 1);
        expect(reader.successfulTests, 1);
      });

      // On mobile (iOS/Android), finish entries use currentTestFullName which
      // starts with the test file path in dotted notation, e.g.
      // "patrol_test.app_test my test".
      test(
        'matches mobile finish entry with patrol_test.file prefix',
        () async {
          reader
            ..parse(
              _patrolLogLine(
                _testEntryJson(name: 'increase counter', status: 'start'),
              ),
            )
            ..parse(
              _patrolLogLine(
                _testEntryJson(
                  name: 'patrol_test.app_test increase counter',
                  status: 'success',
                ),
              ),
            );

          await pumpEventQueue();

          expect(reader.totalTests, 1);
          expect(reader.successfulTests, 1);
        },
      );

      test(
        'matches mobile finish with deeply nested dotted path prefix',
        () async {
          // Path like patrol_test/features/auth_test.dart becomes
          // "patrol_test.features.auth_test" as the first token.
          reader
            ..parse(
              _patrolLogLine(
                _testEntryJson(name: 'should login', status: 'start'),
              ),
            )
            ..parse(
              _patrolLogLine(
                _testEntryJson(
                  name: 'patrol_test.features.auth_test should login',
                  status: 'success',
                ),
              ),
            );

          await pumpEventQueue();

          expect(reader.totalTests, 1);
          expect(reader.successfulTests, 1);
        },
      );

      test('correctly tracks multiple distinct sequential tests', () async {
        reader
          ..parse(
            _patrolLogLine(_testEntryJson(name: 'first test', status: 'start')),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(
                name: 'patrol_test.app_test first test',
                status: 'success',
              ),
            ),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(name: 'second test', status: 'start'),
            ),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(
                name: 'patrol_test.app_test second test',
                status: 'failure',
                error: 'Something went wrong',
              ),
            ),
          );

        await pumpEventQueue();

        expect(reader.totalTests, 2);
        expect(reader.successfulTests, 1);
        expect(reader.failedTestsCount, 1);
      });

      test('does not strip dots that appear mid-description', () async {
        // "version 1.0 test" — first token "version" has no dot, so the whole
        // name is kept intact and the web prefix can still be stripped correctly.
        reader
          ..parse(
            _patrolLogLine(
              _testEntryJson(name: 'version 1.0 test', status: 'start'),
            ),
          )
          ..parse(
            _patrolLogLine(
              _testEntryJson(
                name: 'web.app_test version 1.0 test',
                status: 'success',
              ),
            ),
          );

        await pumpEventQueue();

        expect(reader.totalTests, 1);
        expect(reader.successfulTests, 1);
      });

      test(
        'finish entry for test in group does not match its start entry',
        () async {
          // When patrolTest() is inside group('HomeScreen', ...), the start entry
          // uses just description ("my test"), but the mobile finish entry uses
          // currentTestFullName which includes the group:
          // "patrol_test.app_test HomeScreen my test".
          // After normalization, finish becomes "HomeScreen my test" which does
          // not match the stored start key "my test".
          reader
            ..parse(
              _patrolLogLine(_testEntryJson(name: 'my test', status: 'start')),
            )
            ..parse(
              _patrolLogLine(
                _testEntryJson(
                  name: 'patrol_test.app_test HomeScreen my test',
                  status: 'success',
                ),
              ),
            );

          await pumpEventQueue();

          // The test was registered (totalTests counts the start entry),
          // but the finish entry is not matched so the test stays "open".
          expect(reader.totalTests, 1);
          expect(reader.successfulTests, 0);
        },
      );
    });
  });
}
