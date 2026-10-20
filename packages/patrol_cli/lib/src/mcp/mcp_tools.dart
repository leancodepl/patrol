import 'dart:async';
import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/device_selection.dart';
import 'package:patrol_cli/src/mcp/flutter_command_resolver.dart';
import 'package:patrol_cli/src/mcp/native_tree_service.dart';
import 'package:patrol_cli/src/mcp/patrol_session.dart';
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:patrol_cli/src/mcp/screenshot_service.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:process/process.dart';

const _defaultTimeoutMinutes = 5.0;

/// Output schema for `run` and `status` -- a serialized [PatrolStatus].
/// Keys mirror `PatrolStatus.toMap`.
const sessionStatusSchema = JsonObject(
  properties: {
    'isDevelopRunning': JsonBoolean(),
    'projectRoot': JsonString(
      description:
          'Absolute path of the project this result came from. Check it before '
          'trusting a result if you work across checkouts.',
    ),
    'versionWarning': JsonString(
      description:
          "Present when the project's `patrol` version is not one this CLI can "
          'drive. Runs may fail for that reason alone; report it rather than '
          'debugging the test. `patrol mcp -- --no-check-compatibility` runs '
          'anyway.',
    ),
    'testState': JsonString(
      enumValues: ['idle', 'running', 'finishedPassed', 'finishedFailed'],
    ),
    'currentTestFile': JsonString(),
    'warning': JsonString(),
    'deviceSelectionNote': JsonString(),
    'deviceName': JsonString(),
    'deviceId': JsonString(),
    'devicePlatform': JsonString(),
    'quietForSeconds': JsonInteger(
      description:
          'How long the running session has heard nothing from the device. '
          'Absent when no run is in progress.',
    ),
    'lastTestEntry': JsonString(
      description: 'The last test the session saw start, pass or fail.',
    ),
    'stallNote': JsonString(
      description:
          'Present when the quiet has lasted long enough to be worth '
          'reporting. A run that goes quiet may be stuck; quit stops it.',
    ),
    'terminalWarning': JsonString(
      description:
          'Present when --show-terminal could not open a Terminal window for '
          'the session log, with the reason.',
    ),
    'output': JsonString(),
    'summary': JsonString(),
  },
  required: [
    'isDevelopRunning',
    'projectRoot',
    'testState',
    'output',
    'summary',
  ],
);

/// The arguments of a `run` call.
class RunArgs {
  RunArgs.fromJson(Map<String, dynamic> json)
    : testFile = json['testFile'] as String,
      timeout = _parseTimeout(json['timeoutMinutes'] as num?),
      device = (json['device'] as String?)?.trim().nullIfEmpty,
      projectRoot = (json['projectRoot'] as String?)?.trim().nullIfEmpty;

  final String testFile;
  final Duration timeout;
  final String? device;
  final String? projectRoot;

  static Duration _parseTimeout(num? timeoutMinutes) {
    final minutes = timeoutMinutes?.toDouble() ?? _defaultTimeoutMinutes;
    return Duration(milliseconds: (minutes * 60 * 1000).round());
  }
}

/// What each MCP tool does once called. Separate from the server wiring so a
/// test can call a tool without a transport.
class McpTools {
  McpTools({
    required PatrolSession session,
    required DeviceFinder deviceFinder,
    required ProcessManager processManager,
  }) : _session = session,
       _deviceFinder = deviceFinder,
       _processManager = processManager;

  final PatrolSession _session;
  final DeviceFinder _deviceFinder;
  final ProcessManager _processManager;

  Future<CallToolResult> run(
    Map<String, dynamic> args,
    RequestHandlerExtra extra,
  ) => withProject(
    () => _run(args, extra),
    testFile: (args['testFile'] as String?)?.trim().nullIfEmpty,
    requestedRoot: (args['projectRoot'] as String?)?.trim().nullIfEmpty,
  );

  Future<CallToolResult> devices() =>
      withProject(_devices, projectRequired: false);

  Future<CallToolResult> quit() =>
      withProject(projectRequired: false, () async {
        if (!_session.isRunning) {
          return const CallToolResult(
            content: [
              TextContent(
                text:
                    'No active patrol session to quit. '
                    'Start one with the run tool first.',
              ),
            ],
            isError: true,
          );
        }
        return CallToolResult(
          content: [TextContent(text: await _session.quit())],
        );
      });

  Future<CallToolResult> status() => withProject(
    () async => statusResult(_session.getStatus()),
    projectRequired: false,
  );

  Future<CallToolResult> screenshot() => withProject(
    () => ScreenshotService.handleScreenshotRequest(
      _session.device,
      webDebuggerPort: _session.webDebuggerPort,
      processManager: _processManager,
    ),
    projectRequired: false,
  );

  Future<CallToolResult> nativeTree() =>
      withProject(projectRequired: false, () async {
        if (_session.device?.targetPlatform == TargetPlatform.web) {
          return const CallToolResult(
            content: [
              TextContent(
                text:
                    'native-tree is not available for a web session: the '
                    "page's DOM is its view tree and nothing serves it here "
                    'yet. Use screenshot to see the page.',
              ),
            ],
            isError: true,
          );
        }
        await _session.ensureNativeAutomatorReachable();
        return NativeTreeService.handleGetNativeTreeRequest(
          _session.device,
          _session.testServerPort,
          processManager: _processManager,
        );
      });

  /// Resolves the project before a tool touches the session, and reports a
  /// resolution failure as the tool's error with the signals that were tried.
  ///
  /// [testFile] and [requestedRoot] are what the call itself said about the
  /// project. A server started outside any Dart package has nothing else to go
  /// on, so resolving without them would fail here before the call's own signals
  /// were ever read.
  Future<CallToolResult> withProject(
    Future<CallToolResult> Function() body, {
    String? testFile,
    String? requestedRoot,
    bool projectRequired = true,
  }) async {
    try {
      await _session.ensureProjectResolved(
        testFile: testFile,
        requestedRoot: requestedRoot,
      );
    } on ProjectResolutionException catch (err) {
      if (projectRequired) {
        return CallToolResult(
          content: [TextContent(text: '$err')],
          isError: true,
        );
      }
      // Only a run needs a project. A tool that reports on the session, or lists
      // what is attached, still has an answer — and refusing it would leave an
      // agent nothing to call on a server that has not been told where to work.
      _session.noteProjectUnresolved('$err');
    }
    return body();
  }

  Future<CallToolResult> _run(
    Map<String, dynamic> args,
    RequestHandlerExtra extra,
  ) async {
    final testFile = args['testFile'];
    if (testFile is! String || testFile.trim().isEmpty) {
      return const CallToolResult(
        content: [
          TextContent(
            text:
                'The "testFile" argument is required, e.g. '
                '{"testFile":"patrol_test/login_test.dart"}.',
          ),
        ],
        isError: true,
      );
    }

    final runArgs = RunArgs.fromJson(args);

    // If the client cancels the run (MCP notifications/cancelled), tear the
    // develop session down so it isn't left orphaned.
    final abortSub = extra.signal.onAbort.listen((_) {
      unawaited(_session.dispose());
    });
    try {
      final result = await _session.startAndWait(
        runArgs.testFile,
        timeout: runArgs.timeout,
        device: runArgs.device,
        projectRoot: runArgs.projectRoot,
      );
      return statusResult(result.status, isError: !result.started);
    } finally {
      await abortSub.cancel();
    }
  }

  Future<CallToolResult> _devices() async {
    // Resolve Flutter the same way `run` does (FVM autodetect,
    // `PATROL_FLUTTER_COMMAND` escape hatch) so device enumeration works in FVM
    // projects without a global `flutter` on PATH. A server that has no project
    // yet lists devices with the default `flutter`.
    final projectRoot = _session.projectRoot;
    final flutterCommand = projectRoot == null
        ? null
        : FlutterCommandResolver().resolve(projectRoot: projectRoot).command;
    try {
      final attached = await _deviceFinder.getAttachedDevices(
        flutterCommand: flutterCommand ?? const FlutterCommand('flutter'),
      );
      final payload = {
        'devices': [
          for (final d in supportedDevices(attached))
            {
              'id': d.id,
              'name': d.name,
              'platform': d.targetPlatform.name,
              'isEmulator': !d.real,
            },
        ],
      };
      return CallToolResult(
        content: [TextContent(text: jsonEncode(payload))],
        structuredContent: payload,
      );
    } catch (err) {
      return CallToolResult(
        content: [TextContent(text: 'Failed to list attached devices: $err')],
        isError: true,
      );
    }
  }

  CallToolResult statusResult(PatrolStatus status, {bool isError = false}) {
    final map = status.toMap();
    return CallToolResult(
      content: [TextContent(text: jsonEncode(map))],
      structuredContent: map,
      isError: isError,
    );
  }
}
