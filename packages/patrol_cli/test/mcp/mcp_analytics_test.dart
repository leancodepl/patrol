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

  setUp(() {
    processManager = MockProcessManager();
    when(
      () => processManager.run(any(), runInShell: any(named: 'runInShell')),
    ).thenAnswer(
      (_) async => ProcessResult(
        0,
        0,
        '{"frameworkVersion": "3.47.5", "channel": "stable"}',
        '',
      ),
    );
    sent = [];
  });

  McpAnalytics analytics({AnalyticsEventSink? send}) => McpAnalytics(
    send:
        send ??
        (version, name, {eventData = const {}}) async {
          sent.add((version: version, name: name, data: eventData));
          return true;
        },
    cliSource: CliSource.global,
    processManager: processManager,
  );

  CallToolResult status(String testState, {bool isError = false}) =>
      CallToolResult(
        content: const [TextContent(text: '{}')],
        structuredContent: {
          'testState': testState,
          'projectRoot': '/Users/me/secret-project',
          'currentTestFile': 'patrol_test/login_test.dart',
          'error': 'Expected: true',
        },
        isError: isError,
      );

  group('outcome', () {
    test('a run reports the test result, or why it did not run', () {
      expect(McpAnalytics.outcomeOf('run', status('finishedPassed')), 'passed');
      expect(McpAnalytics.outcomeOf('run', status('finishedFailed')), 'failed');
      expect(McpAnalytics.outcomeOf('run', status('running')), 'timed_out');
      expect(McpAnalytics.outcomeOf('run', status('idle')), 'idle');
      expect(
        McpAnalytics.outcomeOf('run', status('finishedPassed', isError: true)),
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
        result: status('finishedFailed'),
        duration: const Duration(milliseconds: 4200),
        platform: TargetPlatform.android,
        flutterCommand: const FlutterCommand('flutter'),
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

  test('asks Flutter for its version once per command', () async {
    final reporter = analytics();
    for (var i = 0; i < 3; i++) {
      await reporter.toolCalled(
        tool: 'status',
        result: status('idle'),
        duration: Duration.zero,
        flutterCommand: const FlutterCommand('fvm', ['flutter']),
      );
    }

    expect(sent, hasLength(3));
    verify(
      () => processManager.run(any(), runInShell: any(named: 'runInShell')),
    ).called(1);
  });

  test('reports an unknown Flutter when it cannot be asked', () async {
    when(
      () => processManager.run(any(), runInShell: any(named: 'runInShell')),
    ).thenThrow(const ProcessException('flutter', []));

    await analytics().toolCalled(
      tool: 'devices',
      result: status('idle'),
      duration: Duration.zero,
      flutterCommand: const FlutterCommand('flutter'),
    );

    expect(sent.single.version.version, 'unknown');
    expect(sent.single.data['platform'], 'none');
  });

  test('a failing send never reaches the tool call', () async {
    await expectLater(
      analytics(
        send: (_, _, {eventData = const {}}) async =>
            throw Exception('offline'),
      ).toolCalled(
        tool: 'run',
        result: status('finishedPassed'),
        duration: Duration.zero,
        flutterCommand: const FlutterCommand('flutter'),
      ),
      completes,
    );
  });
}
