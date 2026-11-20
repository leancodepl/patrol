import 'dart:async';
import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/cli_origin.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:process/process.dart';

/// Sends one analytics event, as [Analytics.sendCommand] does.
typedef AnalyticsEventSink =
    Future<bool> Function(
      FlutterVersion flutterVersion,
      String name, {
      Map<String, Object?> eventData,
    });

/// Reports `patrol mcp` tool calls to the CLI's analytics, under the same
/// consent: which tool, how it ended, how long it took, on which platform and
/// from which install of the CLI. Nothing that names a project, a test or an
/// error is sent.
final class McpAnalytics {
  McpAnalytics({
    required AnalyticsEventSink send,
    required CliSource cliSource,
    required ProcessManager processManager,
  }) : _send = send,
       _cliSource = cliSource,
       _processManager = processManager;

  static const eventName = 'mcp_tool';

  final AnalyticsEventSink _send;
  final CliSource _cliSource;
  final ProcessManager _processManager;

  /// One lookup per Flutter command: `flutter --version` takes seconds, and a
  /// server serves many calls with the same one.
  final _flutterVersions = <String, Future<FlutterVersion>>{};

  /// Reports a finished tool call. Never throws; a failed send is dropped.
  Future<void> toolCalled({
    required String tool,
    required CallToolResult result,
    required Duration duration,
    required FlutterCommand flutterCommand,
    TargetPlatform? platform,
  }) async {
    try {
      await _send(
        await _flutterVersion(flutterCommand),
        eventName,
        eventData: {
          'tool': tool,
          'outcome': outcomeOf(tool, result),
          'duration_ms': duration.inMilliseconds,
          'platform': platform?.name ?? 'none',
          'cli_source': _cliSource.name,
        },
      );
    } on Object {
      // Analytics must never fail a tool call.
    }
  }

  /// How a call ended: for `run`, the test's outcome or why it did not run;
  /// for every other tool, whether it answered.
  static String outcomeOf(String tool, CallToolResult result) {
    if (tool != 'run') {
      return result.isError == true ? 'error' : 'ok';
    }
    if (result.isError == true) {
      return 'refused';
    }
    return switch (result.structuredContent?['testState']) {
      'finishedPassed' => 'passed',
      'finishedFailed' => 'failed',
      'running' => 'timed_out',
      _ => 'idle',
    };
  }

  Future<FlutterVersion> _flutterVersion(FlutterCommand command) =>
      _flutterVersions.putIfAbsent(
        [command.executable, ...command.arguments].join(' '),
        () => _readFlutterVersion(command),
      );

  Future<FlutterVersion> _readFlutterVersion(FlutterCommand command) async {
    try {
      final result = await _processManager.run([
        command.executable,
        ...command.arguments,
        '--no-version-check',
        '--suppress-analytics',
        '--version',
        '--machine',
      ], runInShell: true);
      final json = jsonDecode(cleanJsonResult(result)) as Map<String, dynamic>;
      return FlutterVersion(
        json['frameworkVersion'] as String,
        json['channel'] as String,
      );
    } on Object {
      return FlutterVersion('unknown', 'unknown');
    }
  }
}
