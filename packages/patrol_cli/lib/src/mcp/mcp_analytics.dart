import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

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
    required this._send,
    required this._consented,
    required this._cliSource,
    required this._processManager,
    this._versionTimeout = const Duration(seconds: 30),
  });

  static const eventName = 'mcp_tool';

  final AnalyticsEventSink _send;

  /// Whether the user's analytics consent allows sending now.
  final bool Function() _consented;
  final CliSource _cliSource;
  final ProcessManager _processManager;

  /// How long `flutter --version` may take before the version is reported as
  /// unknown.
  final Duration _versionTimeout;

  /// One lookup per Flutter command and directory: `flutter --version` takes
  /// seconds, and a server serves many calls with the same one. A failed
  /// lookup is dropped, so a later call asks again.
  final _flutterVersions = <String, Future<FlutterVersion?>>{};

  /// Reports a finished tool call. Never throws; a failed send is dropped.
  ///
  /// [flutterCommand] is called only once the user's consent allows sending.
  Future<void> toolCalled({
    required String tool,
    required String outcome,
    required Duration duration,
    required FlutterCommand Function() flutterCommand,
    String? workingDirectory,
    TargetPlatform? platform,
  }) async {
    try {
      if (!_consented()) {
        return;
      }
      await _send(
        await _flutterVersion(flutterCommand(), workingDirectory) ??
            FlutterVersion('unknown', 'unknown'),
        eventName,
        eventData: {
          'tool': tool,
          'outcome': outcome,
          'duration_ms': duration.inMilliseconds,
          'platform': platform?.name ?? 'none',
          'cli_source': _cliSource.name,
        },
      );
    } on Object {
      // Analytics must never fail a tool call.
    }
  }

  /// How a call that returned [result] ended: for `run`, the test's outcome or
  /// why it did not run; for every other tool, whether it answered.
  static String outcomeOf(String tool, CallToolResult result) {
    if (tool != 'run') {
      return result.isError == true ? 'error' : 'ok';
    }
    if (result.isError == true) {
      return 'refused';
    }
    final status = result.structuredContent;
    return switch (status?['testState']) {
      'finishedPassed' => 'passed',
      // A failed test always carries `error`.
      'finishedFailed' when status?['error'] == null => 'session_error',
      'finishedFailed' => 'failed',
      'running' => 'timed_out',
      _ => 'ended',
    };
  }

  Future<FlutterVersion?> _flutterVersion(
    FlutterCommand command,
    String? workingDirectory,
  ) {
    final key = [
      workingDirectory ?? '',
      command.executable,
      ...command.arguments,
    ].join('\u0000');
    return _flutterVersions.putIfAbsent(key, () async {
      final version = await _readFlutterVersion(command, workingDirectory);
      if (version == null) {
        unawaited(_flutterVersions.remove(key));
      }
      return version;
    });
  }

  Future<FlutterVersion?> _readFlutterVersion(
    FlutterCommand command,
    String? workingDirectory,
  ) async {
    final io.Process process;
    try {
      process = await _processManager.start(
        [
          command.executable,
          ...command.arguments,
          '--no-version-check',
          '--suppress-analytics',
          '--version',
          '--machine',
        ],
        workingDirectory: workingDirectory,
        runInShell: true,
      );
    } on Object {
      return null;
    }
    final stdout = process.stdout.transform(utf8.decoder).join();
    unawaited(process.stderr.drain<void>());
    try {
      final exitCode = await process.exitCode.timeout(_versionTimeout);
      final json =
          jsonDecode(
                cleanJsonResult(
                  io.ProcessResult(process.pid, exitCode, await stdout, ''),
                ),
              )
              as Map<String, dynamic>;
      return FlutterVersion(
        json['frameworkVersion'] as String,
        json['channel'] as String,
      );
    } on TimeoutException {
      process.kill();
      stdout.ignore();
      return null;
    } on Object {
      return null;
    }
  }
}
