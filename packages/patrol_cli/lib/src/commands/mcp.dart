import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:mcp_dart/mcp_dart.dart' hide Logger;
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/mcp/device_lister.dart';
import 'package:patrol_cli/src/mcp/device_selection.dart';
import 'package:patrol_cli/src/mcp/flutter_command_resolver.dart';
import 'package:patrol_cli/src/mcp/native_tree_service.dart';
import 'package:patrol_cli/src/mcp/patrol_session.dart';
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:patrol_cli/src/mcp/screenshot_service.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

const _defaultTimeoutMinutes = 5.0;

/// Output schema for `run` and `status` -- a serialized [PatrolStatus].
/// Keys mirror `PatrolStatus.toMap`.
const _sessionStatusSchema = JsonObject(
  properties: {
    'isDevelopRunning': JsonBoolean(),
    'projectRoot': JsonString(
      description:
          'Absolute path of the project this server is anchored to. It is fixed '
          'when the server starts; check it before trusting a result if you '
          'work across checkouts.',
    ),
    'versionWarning': JsonString(
      description:
          "Present when the project's `patrol` version is not one this CLI can "
          'drive. Runs may fail for that reason alone; report it rather than '
          'debugging the test.',
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

const _instructions =
    'Patrol MCP lets AI agents run and control Patrol develop sessions.\n\n'
    'Usage workflow:\n'
    '1. Use run with testFile (for example: {"testFile":"patrol_test/your_test.dart"}) '
    'to start a test run.\n'
    '2. Use screenshot to capture the current app screen.\n'
    '3. Use native-tree to fetch the current native UI tree '
    '(requires an active session/device).\n'
    '4. Use quit to gracefully stop the active session when done.\n\n'
    'Behavior notes:\n'
    '- run waits for test completion.\n'
    '- If no session is running, run starts a new session.\n'
    '- If a session is already running, run triggers a restart for the requested test.\n'
    '- run auto-selects a device; to target a specific one, call devices and pass its id as run\'s "device".\n'
    '- status is optional and mainly useful for debugging session state and recent output.\n'
    '- native-tree is intended for native interactions and cross-app/native context inspection.\n'
    '- this server is anchored to one project, fixed when it started, and testFile is '
    'relative to it. Every result carries projectRoot: if it is not the project you mean, '
    'stop — nothing here can retarget it, so the run needs a server started against that project.';

class _RunArgs {
  _RunArgs.fromJson(Map<String, dynamic> json)
    : testFile = json['testFile'] as String,
      timeout = _parseTimeout(json['timeoutMinutes'] as num?),
      device = (json['device'] as String?)?.trim().nullIfEmpty;

  final String testFile;
  final Duration timeout;
  final String? device;

  static Duration _parseTimeout(num? timeoutMinutes) {
    final minutes = timeoutMinutes?.toDouble() ?? _defaultTimeoutMinutes;
    return Duration(milliseconds: (minutes * 60 * 1000).round());
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

/// Runs the MCP server that lets AI agents drive `patrol develop` sessions.
///
/// The process's real stdout is the JSON-RPC channel, so it is handed to the
/// transport directly while every other write is redirected — see
/// [PatrolSession.capturingStdout] and the guard in `patrolCommandRunner`.
class McpCommand extends PatrolCommand {
  McpCommand({required Logger logger})
    : _logger = logger,
      _protocolStdout = io.stdout {
    argParser
      ..addOption(
        'project-root',
        help:
            'Flutter project to operate on. Defaults to PROJECT_ROOT, the '
            'directory the client launched the server in, or the nearest '
            'ancestor with a pubspec.yaml.',
        valueHelp: './app',
      )
      ..addOption(
        'log-file',
        help:
            'Where to write session logs. Defaults to patrol.log in the '
            'project root.',
        valueHelp: 'path',
      )
      ..addFlag(
        'show-terminal',
        help: 'Open a macOS Terminal tailing the session log.',
      );
  }

  static const commandName = 'mcp';

  final Logger _logger;

  /// The real stdout, captured at construction — that is, before [run] installs
  /// the [io.IOOverrides] zone that sends every other write to stderr. Only the
  /// JSON-RPC transport may write here.
  final io.Stdout _protocolStdout;

  @override
  String get name => commandName;

  @override
  String get description =>
      '(Experimental) Run an MCP server so AI agents can run and control '
      'patrol develop sessions. Flags for the develop session go after `--`, '
      'e.g. `patrol mcp -- --flavor dev`.';

  @override
  String? get usageFooter =>
      'Read detailed docs at https://patrol.leancode.co/documentation/other/patrol-mcp';

  @override
  Future<int> run() async {
    final env = io.Platform.environment;

    // Resolved before the redirect below, so a resolution failure is reported on
    // the real stderr rather than swallowed.
    final projectRoot = await ProjectResolver(
      // TODO(mcp-roots): read the client's advertised workspace roots.
      readRoots: () async => const [],
      projectRootOverride: stringArg('project-root'),
    ).resolve();

    // Run from the project root so patrol_cli resolves the pubspec, test target
    // and build outputs there even when the client launched us elsewhere.
    io.Directory.current = projectRoot;

    final session = PatrolSession(
      flutterProjectPath: projectRoot,
      logger: _logger,
      developArgs: _developArgs(env),
      logFile: stringArg('log-file'),
      showTerminal:
          boolArg('show-terminal') ||
          env['SHOW_TERMINAL']?.toLowerCase() == 'true',
    );

    final transport = StdioServerTransport(stdout: _protocolStdout);

    return io.IOOverrides.runZoned(
      stdout: () => session.capturingStdout,
      () => _serve(_buildServer(session), session, transport),
    );
  }

  /// Flags forwarded to `patrol develop`, preferring real arguments
  /// (`patrol mcp -- --flavor dev`) over `PATROL_FLAGS`.
  ///
  /// The env var cannot express a value containing spaces, because it has to be
  /// split on whitespace to become an argument list (#3026). Arguments arrive
  /// already split, so they have no such limit.
  List<String> _developArgs(Map<String, String> env) {
    final passedThrough = argResults?.rest ?? const [];
    if (passedThrough.isNotEmpty) {
      return passedThrough;
    }
    final fromEnv = env['PATROL_FLAGS'] ?? '';
    return fromEnv.isEmpty ? const [] : fromEnv.split(RegExp(r'\s+'));
  }

  McpServer _buildServer(PatrolSession session) {
    return McpServer(
        const Implementation(name: 'patrol_mcp', version: constants.version),
        options: const McpServerOptions(
          capabilities: ServerCapabilities(tools: ServerCapabilitiesTools()),
          instructions: _instructions,
        ),
      )
      ..registerTool(
        'run',
        description:
            'Run patrol tests (starts new session or restarts if already '
            'running) and wait for completion',
        inputSchema: const ToolInputSchema(
          properties: {
            'testFile': JsonString(
              description:
                  'Path to the test file, relative to the project root '
                  "(e.g., 'integration_test/example_test.dart' or "
                  "'patrol_test/scenarios/login_test.dart'). "
                  'Do NOT include the project root prefix in the path.',
            ),
            'timeoutMinutes': JsonNumber(
              description: 'Optional timeout in minutes (default: 5)',
            ),
            'device': JsonString(
              description:
                  'Optional device id or name to run on (from the '
                  '`devices` tool). Omit to auto-select (Android device '
                  '> Android emulator > iOS device > iOS simulator). A '
                  '`--device` in PATROL_FLAGS takes precedence.',
            ),
          },
          required: ['testFile'],
        ),
        outputSchema: _sessionStatusSchema,
        annotations: const ToolAnnotations(title: 'Run Patrol Tests'),
        callback: (args, extra) => _run(session, args, extra),
      )
      ..registerTool(
        'devices',
        description:
            'List attached devices patrol can run on (Android, iOS). Use '
            'to resolve a device name/id to pass as `device` to run.',
        annotations: const ToolAnnotations(title: 'List Devices'),
        callback: (args, extra) => _devices(session),
      )
      ..registerTool(
        'quit',
        description: 'Quit the active patrol session gracefully',
        annotations: const ToolAnnotations(title: 'Quit Patrol'),
        callback: (args, extra) {
          if (!session.getStatus().isDevelopRunning) {
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
            content: [
              TextContent(text: session.sendCommand(SessionCommand.quit)),
            ],
          );
        },
      )
      ..registerTool(
        'status',
        description:
            'Get the current status of the patrol session and recent output',
        outputSchema: _sessionStatusSchema,
        annotations: const ToolAnnotations(
          title: 'Get Status',
          readOnlyHint: true,
          idempotentHint: true,
        ),
        callback: (args, extra) => _statusResult(session.getStatus()),
      )
      ..registerTool(
        'screenshot',
        description:
            'Capture a screenshot of the current device/simulator screen. '
            'Platform is auto-detected from the active patrol session.',
        annotations: const ToolAnnotations(
          title: 'Capture Screenshot',
          readOnlyHint: true,
        ),
        callback: (args, extra) =>
            ScreenshotService.handleScreenshotRequest(session.device),
      )
      ..registerTool(
        'native-tree',
        description:
            'Fetch the native UI tree. '
            'Requires an active patrol develop session.',
        annotations: const ToolAnnotations(
          title: 'Get Native UI Tree',
          readOnlyHint: true,
        ),
        callback: (args, extra) async {
          await session.ensureNativeAutomatorReachable();
          return NativeTreeService.handleGetNativeTreeRequest(
            session.device,
            session.testServerPort,
          );
        },
      );
  }

  Future<CallToolResult> _run(
    PatrolSession session,
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
                '{"testFile":"integration_test/app_test.dart"}.',
          ),
        ],
        isError: true,
      );
    }

    final runArgs = _RunArgs.fromJson(args);

    // If the client cancels the run (MCP notifications/cancelled), tear the
    // develop session down so it isn't left orphaned.
    final abortSub = extra.signal.onAbort.listen((_) {
      unawaited(session.dispose());
    });
    try {
      final result = await session.startAndWait(
        runArgs.testFile,
        timeout: runArgs.timeout,
        device: runArgs.device,
      );
      return _statusResult(result.status, isError: !result.started);
    } finally {
      await abortSub.cancel();
    }
  }

  Future<CallToolResult> _devices(PatrolSession session) async {
    // Resolve Flutter the same way `run` does (FVM autodetect,
    // `PATROL_FLUTTER_COMMAND` escape hatch) so device enumeration works in FVM
    // projects without a global `flutter` on PATH.
    final flutterCommand = FlutterCommandResolver()
        .resolve(projectRoot: session.flutterProjectPath)
        .command;
    try {
      final attached = await listAttachedDevices(
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

  CallToolResult _statusResult(PatrolStatus status, {bool isError = false}) {
    final map = status.toMap();
    return CallToolResult(
      content: [TextContent(text: jsonEncode(map))],
      structuredContent: map,
      isError: isError,
    );
  }

  Future<int> _serve(
    McpServer server,
    PatrolSession session,
    StdioServerTransport transport,
  ) async {
    // MCP clients disconnect by closing stdin (EOF), not always via SIGTERM, so
    // wake on EOF too -- otherwise we'd block on _ExitSignal forever and orphan.
    final closed = Completer<void>();
    server.server.onclose = () {
      if (!closed.isCompleted) {
        closed.complete();
      }
    };

    try {
      await server.connect(transport);
      _logger.detail('MCP server started on stdio');
    } catch (err, st) {
      _logger
        ..err('Failed to start the MCP stdio transport: $err')
        ..detail('$st');
      return 1;
    }

    final exitSignal = _ExitSignal();
    await Future.any([exitSignal.wait, closed.future]);
    // ProcessSignal.watch() keeps the VM alive; the EOF path skips
    // _handleSignal, so cancel here.
    exitSignal.cancel();
    _logger.detail('Shutting down (signal or client disconnect)');

    // Tear down the active session and close the transport, but never block
    // forever: a stalled teardown (e.g. a run cancelled mid-build) would orphan
    // the server process. Force-exit if it doesn't finish in time.
    Future<void> shutdown() async {
      await session.dispose();
      await server.close(); // closes the transport too
    }

    await shutdown().timeout(
      const Duration(seconds: 10),
      onTimeout: () => io.exit(0),
    );
    return 0;
  }
}

class _ExitSignal {
  _ExitSignal() {
    // ProcessSignal.sigterm cannot be listened to on Windows — it throws
    // SignalException. On that platform, graceful shutdown comes from stdin EOF
    // (MCP stdio transport) and Ctrl-C (SIGINT), both of which keep working.
    _sigtermSubscription = !io.Platform.isWindows
        ? io.ProcessSignal.sigterm.watch().listen(_handleSignal)
        : null;
    _sigintSubscription = io.ProcessSignal.sigint.watch().listen(_handleSignal);
  }

  final _completer = Completer<io.ProcessSignal>();
  late final StreamSubscription<io.ProcessSignal>? _sigtermSubscription;
  late final StreamSubscription<io.ProcessSignal> _sigintSubscription;

  Future<io.ProcessSignal> get wait => _completer.future;

  /// Cancels the signal subscriptions. Idempotent.
  void cancel() => _cleanup();

  void _handleSignal(io.ProcessSignal signal) {
    if (!_completer.isCompleted) {
      _completer.complete(signal);
      _cleanup();
    }
  }

  void _cleanup() {
    _sigtermSubscription?.cancel();
    _sigintSubscription.cancel();
  }
}
