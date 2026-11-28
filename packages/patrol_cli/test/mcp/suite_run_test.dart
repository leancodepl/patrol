import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/mcp/suite_run.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../src/processes.dart';

void main() {
  group('SuiteCommandLine', () {
    SuiteCommandLine build(
      List<String> serverArgs, {
      List<String> targets = const [],
      String? tags,
      String? excludeTags,
      String? device,
      FlutterCommand? flutterCommand,
    }) => SuiteCommandLine.build(
      serverArgs: serverArgs,
      targets: targets,
      tags: tags,
      excludeTags: excludeTags,
      device: device,
      flutterCommand: flutterCommand,
      resultsFile: '/tmp/results.jsonl',
    );

    test('puts global flags before the command', () {
      final line = build(['--verbose', '--flavor', 'dev']);

      expect(line.arguments.indexOf('--verbose'), 0);
      expect(line.arguments.indexOf('test'), 1);
      expect(line.arguments, contains('--flavor=dev'));
      expect(line.arguments.last, '--results-file=/tmp/results.jsonl');
    });

    test('leaves out the flags only develop takes and names them', () {
      final line = build([
        '--open-devtools',
        '--use-prebuilt-apks',
        'build/apks',
        '--flavor=dev',
      ]);

      expect(
        line.dropped,
        unorderedEquals(['--open-devtools', '--use-prebuilt-apks']),
      );
      expect(line.arguments.join(' '), isNot(contains('devtools')));
      expect(line.arguments.join(' '), isNot(contains('prebuilt')));
    });

    test('keeps repeated and negated flags as they were given', () {
      final line = build([
        '--dart-define',
        'A=1',
        '--dart-define=B=2',
        '--no-label',
      ]);

      expect(
        line.arguments,
        containsAll(['--dart-define=A=1', '--dart-define=B=2', '--no-label']),
      );
    });

    test("replaces the server's targets and adds the call's tags", () {
      final line = build(
        ['--target', 'patrol_test/a_test.dart'],
        targets: ['patrol_test/b_test.dart'],
        tags: 'slow',
        excludeTags: 'flaky',
      );

      expect(
        line.arguments,
        containsAll([
          '--target=patrol_test/b_test.dart',
          '--tags=slow',
          '--exclude-tags=flaky',
        ]),
      );
      expect(
        line.arguments,
        isNot(contains('--target=patrol_test/a_test.dart')),
      );
    });

    test("keeps the server's targets when the call names none", () {
      final line = build(['--target', 'patrol_test/a_test.dart']);

      expect(line.arguments, contains('--target=patrol_test/a_test.dart'));
    });

    test('keeps a device the server flags pin over the one picked', () {
      final line = build(['--device', 'emulator-5554'], device: 'iPhone 16');

      expect(line.arguments, contains('--device=emulator-5554'));
      expect(line.arguments, isNot(contains('--device=iPhone 16')));
      expect(SuiteCommandLine.pinnedDevices(['-d', 'emulator-5554']), [
        'emulator-5554',
      ]);
    });

    test('runs on the picked device when the flags pin none', () {
      expect(
        build([], device: 'chrome').arguments,
        contains('--device=chrome'),
      );
    });

    test('skips the compatibility check unless the flags ask for it', () {
      expect(build([]).arguments, contains('--no-check-compatibility'));

      final checked = build(['--check-compatibility']).arguments;
      expect(checked, contains('--check-compatibility'));
      expect(checked, isNot(contains('--no-check-compatibility')));
    });

    test('passes the resolved Flutter command unless the flags name one', () {
      const fvm = FlutterCommand('fvm', ['flutter']);
      expect(
        build([], flutterCommand: fvm).arguments.first,
        '--flutter-command=fvm flutter',
      );
      expect(
        build([
          '--flutter-command',
          'my-flutter',
        ], flutterCommand: fvm).arguments.first,
        '--flutter-command=my-flutter',
      );
    });

    test('quotes a Flutter command whose path holds a space', () {
      const sdk = '/Users/me/flutter sdk/bin/flutter';
      final flag = build(
        [],
        flutterCommand: const FlutterCommand(sdk, ['--suppress-analytics']),
      ).arguments.first;

      final passed = FlutterCommand.parse(
        flag.substring('--flutter-command='.length),
      );
      expect(passed.executable, sdk);
      expect(passed.arguments, ['--suppress-analytics']);
    });

    test('rejects flags develop does not take', () {
      expect(
        () => SuiteCommandLine.pinnedDevices(['--no-such-flag']),
        throwsFormatException,
      );
    });
  });

  test('starts the run with analytics turned off', () async {
    final processManager = _RecordingProcessManager();

    final run = await SuiteRun.start(
      processManager: processManager,
      command: const ['patrol', 'test'],
      projectRoot: Directory.systemTemp.path,
      resultsFile: '${Directory.systemTemp.path}/no_such_results.jsonl',
      targets: const [],
      droppedFlags: const [],
      onOutput: (_) {},
    );
    await run.done;

    expect(processManager.environment, {
      'PATROL_ANALYTICS_ENABLED': 'false',
      'PATROL_SKIP_FIRST_RUN': 'true',
    });
    expect(processManager.includeParentEnvironment, isTrue);
  });

  group(
    'SuiteRun',
    () {
      late Directory dir;
      late String resultsFile;

      setUp(() {
        dir = Directory.systemTemp.createTempSync('suite_run_test');
        resultsFile = '${dir.path}/results.jsonl';
      });

      tearDown(() => dir.deleteSync(recursive: true));

      void report(Entry entry) => File(resultsFile).writeAsStringSync(
        '${jsonEncode(entry.toJson())}\n',
        mode: FileMode.append,
      );

      Future<SuiteRun> start(
        String script, {
        List<String>? output,
        Duration stopGrace = const Duration(seconds: 5),
      }) => SuiteRun.start(
        processManager: const LocalProcessManager(),
        command: ['sh', '-c', script],
        projectRoot: dir.path,
        resultsFile: resultsFile,
        targets: const [],
        droppedFlags: const [],
        stopGrace: stopGrace,
        onOutput: (line) => output?.add(line),
      );

      Future<void> printed(List<String> output, String line) =>
          waitUntil(() => output.contains(line), 'the run to print "$line"');

      test('counts the tests the run reports and passes on exit 0', () async {
        report(TestEntry(name: 'a', status: TestEntryStatus.start));
        report(TestEntry(name: 'a', status: TestEntryStatus.success));
        report(TestEntry(name: 'b', status: TestEntryStatus.skip));
        report(TestEntry(name: 'c', status: TestEntryStatus.start));

        final run = await start('exit 0');
        await run.done;
        final status = run.toMap();

        expect(status['suiteState'], 'passed');
        expect(status['passed'], 1);
        expect(status['skipped'], 1);
        expect(status['failed'], 0);
        expect(status, isNot(contains('currentTest')));
        expect(status, isNot(contains('output')));
        expect(status, isNot(contains('warning')));
      });

      test(
        'warns that a run which passed without reporting a test has no counts',
        () async {
          final run = await start('exit 0');
          await run.done;
          final status = run.toMap();

          expect(status['suiteState'], 'passed');
          expect(status['passed'], 0);
          expect(
            status['warning'],
            contains('without reporting a single test'),
          );
        },
      );

      test('reports progress while the run is going', () async {
        final run = await start('sleep 30');
        addTearDown(run.stop);
        report(TestEntry(name: 'a', status: TestEntryStatus.start));
        report(TestEntry(name: 'a', status: TestEntryStatus.success));
        report(TestEntry(name: 'b', status: TestEntryStatus.start));

        final status = run.toMap();

        expect(status['suiteState'], 'running');
        expect(status['passed'], 1);
        expect(status['currentTest'], 'b');
      });

      test(
        'names each failure with its error and the lines after it',
        () async {
          report(TestEntry(name: 'a', status: TestEntryStatus.start));
          report(
            TestEntry(
              name: 'a',
              status: TestEntryStatus.failure,
              error: 'Expected: true\nActual: false',
            ),
          );
          report(ErrorEntry(message: 'at a_test.dart:12'));
          report(TestEntry(name: 'b', status: TestEntryStatus.start));
          report(ErrorEntry(message: 'not about a failure'));
          report(TestEntry(name: 'b', status: TestEntryStatus.success));

          final run = await start('exit 1');
          await run.done;
          final status = run.toMap();

          expect(status['suiteState'], 'failed');
          expect(status['failed'], 1);
          expect(status['failures'], [
            {
              'name': 'a',
              'error': 'Expected: true\nActual: false\nat a_test.dart:12',
            },
          ]);
          expect(status, isNot(contains('warning')));
        },
      );

      test('caps the error lines and the failures it lists', () async {
        for (var i = 0; i < 12; i++) {
          report(TestEntry(name: 't$i', status: TestEntryStatus.start));
          report(
            TestEntry(
              name: 't$i',
              status: TestEntryStatus.failure,
              error: List.generate(100, (l) => 'line $l').join('\n'),
            ),
          );
        }

        final run = await start('exit 1');
        await run.done;
        final status = run.toMap();
        final failures = status['failures']! as List<Map<String, Object>>;

        expect(status['failed'], 12);
        expect(failures, hasLength(10));
        expect(status['failuresNotListed'], 2);
        expect((failures.first['error']! as String).split('\n'), hasLength(60));
      });

      test(
        'explains a run that failed before any test did, with its output',
        () async {
          final run = await start('echo "Gradle build failed"; exit 1');
          await run.done;
          final status = run.toMap();

          expect(status['suiteState'], 'failed');
          expect(status['warning'], contains('code 1'));
          expect(status['output'], contains('Gradle build failed'));
        },
      );

      test('hands every line it prints to onOutput', () async {
        final output = <String>[];
        final run = await start('echo out; echo err >&2', output: output);
        await run.done;
        await pumpEventQueue();

        expect(output, containsAll(['out', 'err']));
      });

      test(
        'stops a running suite with SIGINT and reports it cancelled',
        () async {
          final output = <String>[];
          final run = await start(
            'trap "exit 130" INT; echo ready; sleep 30 & wait',
            output: output,
          );
          await printed(output, 'ready');

          final watch = Stopwatch()..start();
          await run.stop();

          expect(run.isRunning, isFalse);
          expect(run.toMap()['suiteState'], 'cancelled');
          expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
        },
      );

      test(
        'counts a stopping run as running until it exits, and shares the stop',
        () async {
          final output = <String>[];
          final run = await start(
            'trap "sleep 1; exit 130" INT; echo ready; sleep 30 & wait',
            output: output,
          );
          await printed(output, 'ready');

          final first = run.stop();

          expect(run.isRunning, isTrue);
          expect(run.toMap()['suiteState'], 'stopping');
          expect(identical(run.stop(), first), isTrue);

          await first;

          expect(run.isRunning, isFalse);
          expect(run.toMap()['suiteState'], 'cancelled');
        },
      );

      test(
        'keeps the result of a run that exited while its last output drains',
        () async {
          // The background sleep holds the pipes open after the shell exits.
          final run = await start('sleep 3 & exit 0');
          addTearDown(run.done.ignore);
          await Future<void>.delayed(const Duration(milliseconds: 300));

          expect(run.isRunning, isTrue);
          await run.stop();
          await run.done;

          expect(run.toMap()['suiteState'], 'passed');
        },
      );

      test('counts an entry read half-written once, whole', () async {
        final entry = jsonEncode(
          TestEntry(name: 'a', status: TestEntryStatus.success).toJson(),
        );
        final half = entry.length ~/ 2;
        final run = await start('sleep 30');
        addTearDown(run.stop);
        File(resultsFile).writeAsStringSync(
          '${jsonEncode(TestEntry(name: 'a', status: TestEntryStatus.start).toJson())}\n'
          '${entry.substring(0, half)}',
        );

        expect(run.toMap()['passed'], 0);
        expect(run.toMap()['currentTest'], 'a');

        File(resultsFile).writeAsStringSync(
          '${entry.substring(half)}\n',
          mode: FileMode.append,
        );

        final status = run.toMap();
        expect(status['passed'], 1);
        expect(status, isNot(contains('currentTest')));
        expect(run.toMap()['passed'], 1);
      });

      test(
        'kills a run that ignores SIGINT and SIGTERM, children included',
        () async {
          final childPid = File('${dir.path}/child.pid');
          final run = await SuiteRun.start(
            processManager: const LocalProcessManager(),
            command: [
              'sh',
              '-c',
              'trap "" INT TERM; sleep 30 & echo \$! > ${childPid.path}; wait',
            ],
            projectRoot: dir.path,
            resultsFile: resultsFile,
            targets: const [],
            droppedFlags: const [],
            stopGrace: const Duration(milliseconds: 300),
            onOutput: (_) {},
          );
          while (!childPid.existsSync() ||
              childPid.readAsStringSync().trim().isEmpty) {
            await Future<void>.delayed(const Duration(milliseconds: 20));
          }
          final child = childPid.readAsStringSync().trim();

          await run.stop();

          expect(run.isRunning, isFalse);
          expect(run.toMap()['suiteState'], 'cancelled');
          await expectGone([int.parse(child)]);
        },
      );
    },
    skip: Platform.isWindows ? 'The runs are POSIX shell scripts.' : null,
  );
}

final class _RecordingProcessManager extends Fake implements ProcessManager {
  Map<String, String>? environment;
  bool? includeParentEnvironment;

  @override
  Future<Process> start(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    this.environment = environment;
    this.includeParentEnvironment = includeParentEnvironment;
    return _FinishedProcess();
  }
}

final class _FinishedProcess extends Fake implements Process {
  @override
  Stream<List<int>> get stdout => const Stream.empty();

  @override
  Stream<List<int>> get stderr => const Stream.empty();

  @override
  IOSink get stdin => _ClosedSink();

  @override
  Future<int> get exitCode => Future.value(0);
}

final class _ClosedSink extends Fake implements IOSink {
  @override
  Future<void> close() async {}
}
