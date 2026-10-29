import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/cli_origin.dart';
import 'package:patrol_cli/src/mcp/mcp_analytics.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  late MockProcessManager processManager;
  late List<({FlutterVersion version, String name, Map<String, Object?> data})>
  sent;

  /// A `flutter --version` that prints [stdout] and exits, or never exits
  /// while [exits] is false.
  MockProcess flutterVersionProcess({
    String stdout = '{"frameworkVersion": "3.47.5", "channel": "stable"}',
    bool exits = true,
  }) {
    final process = MockProcess();
    final output = StreamController<List<int>>();
    when(() => process.stdout).thenAnswer((_) => output.stream);
    when(() => process.stderr).thenAnswer((_) => const Stream.empty());
    when(() => process.pid).thenReturn(1);
    when(process.kill).thenAnswer((_) {
      unawaited(output.close());
      return true;
    });
    if (exits) {
      output.add(utf8.encode(stdout));
      unawaited(output.close());
      when(() => process.exitCode).thenAnswer((_) async => 0);
    } else {
      when(() => process.exitCode).thenAnswer((_) => Completer<int>().future);
    }
    return process;
  }

  When<Future<Process>> whenStarted() => when(
    () => processManager.start(
      any(),
      workingDirectory: any(named: 'workingDirectory'),
      runInShell: any(named: 'runInShell'),
    ),
  );

  void verifyStarted(int times, {String? workingDirectory}) => verify(
    () => processManager.start(
      any(),
      workingDirectory: workingDirectory ?? any(named: 'workingDirectory'),
      runInShell: any(named: 'runInShell'),
    ),
  ).called(times);

  setUp(() {
    processManager = MockProcessManager();
    whenStarted().thenAnswer((_) async => flutterVersionProcess());
    sent = [];
  });

  McpAnalytics analytics({
    AnalyticsEventSink? send,
    bool consented = true,
    Duration versionTimeout = const Duration(seconds: 30),
  }) => McpAnalytics(
    send:
        send ??
        (version, name, {eventData = const {}}) async {
          sent.add((version: version, name: name, data: eventData));
          return true;
        },
    consented: () => consented,
    cliSource: CliSource.global,
    processManager: processManager,
    versionTimeout: versionTimeout,
  );

  Future<void> report(
    McpAnalytics reporter, {
    String tool = 'status',
    String outcome = 'ok',
    FlutterCommand flutterCommand = const FlutterCommand('flutter'),
    String? workingDirectory = '/Users/me/app',
  }) => reporter.toolCalled(
    tool: tool,
    outcome: outcome,
    duration: Duration.zero,
    flutterCommand: () => flutterCommand,
    workingDirectory: workingDirectory,
  );

  CallToolResult status(
    String testState, {
    bool isError = false,
    String? error = 'Expected: true',
  }) => CallToolResult(
    content: const [TextContent(text: '{}')],
    structuredContent: {
      'testState': testState,
      'projectRoot': '/Users/me/secret-project',
      'currentTestFile': 'patrol_test/login_test.dart',
      'error': ?error,
    },
    isError: isError,
  );

  group('outcome', () {
    test('a run reports the test result, or why it did not run', () {
      expect(McpAnalytics.outcomeOf('run', status('finishedPassed')), 'passed');
      expect(McpAnalytics.outcomeOf('run', status('finishedFailed')), 'failed');
      expect(McpAnalytics.outcomeOf('run', status('running')), 'timed_out');
      expect(McpAnalytics.outcomeOf('run', status('idle')), 'ended');
      expect(
        McpAnalytics.outcomeOf('run', status('finishedPassed', isError: true)),
        'refused',
      );
    });

    test('a run whose session failed before any test did is a session '
        'error', () {
      expect(
        McpAnalytics.outcomeOf('run', status('finishedFailed', error: null)),
        'session_error',
      );
    });

    test('a suite reports its state, or why it did not run', () {
      CallToolResult suite(String state, {bool isError = false}) =>
          CallToolResult(
            content: const [],
            structuredContent: {'suiteState': state},
            isError: isError,
          );

      expect(McpAnalytics.outcomeOf('test', suite('passed')), 'passed');
      expect(McpAnalytics.outcomeOf('test', suite('failed')), 'failed');
      expect(McpAnalytics.outcomeOf('test', suite('cancelled')), 'cancelled');
      expect(McpAnalytics.outcomeOf('test', suite('running')), 'timed_out');
      expect(
        McpAnalytics.outcomeOf('test', suite('passed', isError: true)),
        'refused',
      );
    });

    test('any other tool reports whether it answered', () {
      expect(McpAnalytics.outcomeOf('devices', status('idle')), 'ok');
      expect(
        McpAnalytics.outcomeOf('screenshot', status('idle', isError: true)),
        'error',
      );
    });
  });

  test(
    'sends the tool, outcome, timing, platform and CLI source only',
    () async {
      await analytics().toolCalled(
        tool: 'run',
        outcome: 'failed',
        duration: const Duration(milliseconds: 4200),
        platform: TargetPlatform.android,
        flutterCommand: () => const FlutterCommand('flutter'),
        workingDirectory: '/Users/me/secret-project',
      );

      final event = sent.single;
      expect(event.name, 'mcp_tool');
      expect(event.version.version, '3.47.5');
      expect(event.data, {
        'tool': 'run',
        'outcome': 'failed',
        'duration_ms': 4200,
        'platform': 'android',
        'cli_source': 'global',
      });
    },
  );

  test('asks Flutter for its version in the project', () async {
    await report(analytics(), workingDirectory: '/Users/me/shop');

    verifyStarted(1, workingDirectory: '/Users/me/shop');
  });

  test('asks Flutter once per command and directory', () async {
    final reporter = analytics();
    const fvm = FlutterCommand('fvm', ['flutter']);
    for (var i = 0; i < 3; i++) {
      await report(reporter, flutterCommand: fvm, workingDirectory: '/a');
    }
    await report(reporter, flutterCommand: fvm, workingDirectory: '/b');
    await report(reporter, workingDirectory: '/b');

    expect(sent, hasLength(5));
    verifyStarted(1, workingDirectory: '/a');
    verifyStarted(2, workingDirectory: '/b');
  });

  test('asks Flutter nothing without consent', () async {
    await analytics(consented: false).toolCalled(
      tool: 'status',
      outcome: 'ok',
      duration: Duration.zero,
      flutterCommand: () => fail('the Flutter command was looked up'),
    );

    expect(sent, isEmpty);
    verifyNever(
      () => processManager.start(
        any(),
        workingDirectory: any(named: 'workingDirectory'),
        runInShell: any(named: 'runInShell'),
      ),
    );
  });

  test('reports an unknown Flutter when it cannot be asked, and asks again '
      'on the next call', () async {
    whenStarted().thenThrow(const ProcessException('flutter', []));
    final reporter = analytics();

    await report(reporter, tool: 'devices');
    await report(reporter, tool: 'devices');

    expect(sent.map((e) => e.version.version), ['unknown', 'unknown']);
    expect(sent.first.data['platform'], 'none');
    verifyStarted(2);
  });

  test('kills a Flutter that does not answer in time, and asks again on the '
      'next call', () async {
    final hung = flutterVersionProcess(exits: false);
    whenStarted().thenAnswer((_) async => hung);
    final reporter = analytics(
      versionTimeout: const Duration(milliseconds: 50),
    );

    await report(reporter);

    expect(sent.single.version.version, 'unknown');
    verify(hung.kill).called(1);

    whenStarted().thenAnswer((_) async => flutterVersionProcess());
    await report(reporter);

    expect(sent.last.version.version, '3.47.5');
    verifyStarted(2);
  });

  test('a failing send never reaches the tool call', () async {
    await expectLater(
      report(
        analytics(
          send: (_, _, {eventData = const {}}) async =>
              throw Exception('offline'),
        ),
        tool: 'run',
        outcome: 'passed',
      ),
      completes,
    );
  });
}
