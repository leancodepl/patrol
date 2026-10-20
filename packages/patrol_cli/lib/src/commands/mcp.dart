import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:mcp_dart/mcp_dart.dart' hide Logger;
import 'package:meta/meta.dart';
import 'package:patrol_cli/src/base/command_line.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/device_selection.dart';
import 'package:patrol_cli/src/mcp/flutter_command_resolver.dart';
import 'package:patrol_cli/src/mcp/native_tree_service.dart';
import 'package:patrol_cli/src/mcp/patrol_session.dart';
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:patrol_cli/src/mcp/screenshot_service.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:process/process.dart';

const _defaultTimeoutMinutes = 5.0;

/// How long the client has to answer `roots/list`.
const _rootsTimeout = Duration(seconds: 5);

/// Output schema for `run` and `status` -- a serialized [PatrolStatus].
/// Keys mirror `PatrolStatus.toMap`.
const _sessionStatusSchema = JsonObject(
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
    '- every result carries projectRoot, the project the run happened in. testFile is '
    'relative to it or to the workspace the client opened. To work in another checkout, '
    'quit the session and pass projectRoot to run.';

class _RunArgs {
  _RunArgs.fromJson(Map<String, dynamic> json)
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

/// Runs the MCP server that lets AI agents drive `patrol develop` sessions.
///
/// The process's real stdout is the JSON-RPC channel, so it is handed to the
/// transport directly while every other write is redirected — see
/// [PatrolSession.capturingStdout] and the guard in `patrolCommandRunner`.
class McpCommand extends PatrolCommand {
  McpCommand({
    required DeviceFinder deviceFinder,
    required ProcessManager processManager,
    required Logger logger,
  }) : _deviceFinder = deviceFinder,
       _processManager = processManager,
       _logger = logger,
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

  final DeviceFinder _deviceFinder;
  final ProcessManager _processManager;
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

  /// Set once the server exists, so the resolver can ask the client for its
  /// roots. They are only answerable after the initialize handshake.
  McpServer? _server;

  late final ProjectResolver _projectResolver = ProjectResolver(
    readRoots: _clientRoots,
    projectRootOverride: stringArg('project-root'),
  );

  @override
  Future<int> run() async {
    final env = io.Platform.environment;

    final session = PatrolSession(
      resolveProjectRoot: _projectResolver.resolve,
      listAttachedDevices: _deviceFinder.getAttachedDevices,
      processManager: _processManager,
      logger: _logger,
      developArgs: _developArgs(env),
      logFile: stringArg('log-file'),
      showTerminal:
          boolArg('show-terminal') ||
          env['SHOW_TERMINAL']?.toLowerCase() == 'true',
    );

    final server = _server = _buildServer(session);
    final transport = StdioServerTransport(stdout: _protocolStdout);

    return io.IOOverrides.runZoned(
      stdout: () => session.capturingStdout,
      () => _serve(server, session, transport),
    );
  }

  /// The workspace directories the client advertises, or none when it does not
  /// support `roots/list`.
  ///
  /// A client that never answers is treated as one with no roots: the request
  /// otherwise blocks the tool call that is waiting for a project.
  Future<List<String>> _clientRoots() async {
    final server = _server;
    if (server == null) {
      return const [];
    }
    try {
      final result = await server.server.listRoots().timeout(_rootsTimeout);
      return [for (final root in result.roots) ?_rootPath(root.uri)];
    } on Object {
      return const [];
    }
  }

  /// The local path a root points at, or null for one that names no local
  /// directory: an editor working over a remote or virtual filesystem
  /// advertises roots this server cannot open, alongside ones it can.
  static String? _rootPath(String uri) {
    try {
      return Uri.parse(uri).toFilePath();
    } on Object {
      return null;
    }
  }

  List<String> _developArgs(Map<String, String> env) =>
      developArgsFrom(argResults?.rest ?? const [], env['PATROL_FLAGS']);

  /// Flags forwarded to `patrol develop`: the arguments after `--`
  /// (`patrol mcp -- --flavor dev`), or else [patrolFlags] split as
  /// [splitCommandLine] does, so a quoted value keeps its spaces.
  @visibleForTesting
  static List<String> developArgsFrom(
    List<String> passedThrough,
    String? patrolFlags,
  ) {
    if (passedThrough.isNotEmpty) {
      return passedThrough;
    }
    return splitCommandLine(patrolFlags ?? '');
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
                  'Path to the test file, relative to the project root or to '
                  'the workspace the client opened, which is how a project in a '
                  "subdirectory is reached: 'patrol_test/login_test.dart' or "
                  "'app/patrol_test/login_test.dart'. The project it belongs to "
                  'is reported back as projectRoot.',
            ),
            'timeoutMinutes': JsonNumber(
              description: 'Optional timeout in minutes (default: 5)',
            ),
            'projectRoot': JsonString(
              description:
                  'Optional project to run in, for work spanning more than one '
                  'checkout. Accepted while no session is running; a running '
                  'session must be quit first. Omit to use the project the '
                  'server resolved.',
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
        callback: (args, extra) => _withProject(
          session,
          () => _run(session, args, extra),
          testFile: (args['testFile'] as String?)?.trim().nullIfEmpty,
          requestedRoot: (args['projectRoot'] as String?)?.trim().nullIfEmpty,
        ),
      )
      ..registerTool(
        'devices',
        description:
            'List attached devices patrol can run on (Android, iOS). Use '
            'to resolve a device name/id to pass as `device` to run.',
        annotations: const ToolAnnotations(title: 'List Devices'),
        callback: (args, extra) => _withProject(
          session,
          () => _devices(session),
          projectRequired: false,
        ),
      )
      ..registerTool(
        'quit',
        description: 'Quit the active patrol session gracefully',
        annotations: const ToolAnnotations(title: 'Quit Patrol'),
        callback: (args, extra) =>
            _withProject(session, projectRequired: false, () async {
              if (!session.isRunning) {
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
                content: [TextContent(text: await session.quit())],
              );
            }),
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
        callback: (args, extra) => _withProject(
          session,
          () async => _statusResult(session.getStatus()),
          projectRequired: false,
        ),
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
        callback: (args, extra) => _withProject(
          session,
          () => ScreenshotService.handleScreenshotRequest(
            session.device,
            processManager: _processManager,
          ),
          projectRequired: false,
        ),
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
        callback: (args, extra) =>
            _withProject(session, projectRequired: false, () async {
              await session.ensureNativeAutomatorReachable();
              return NativeTreeService.handleGetNativeTreeRequest(
                session.device,
                session.testServerPort,
                processManager: _processManager,
              );
            }),
      );
  }

  /// Resolves the project before a tool touches the session, and reports a
  /// resolution failure as the tool's error with the signals that were tried.
  ///
  /// [testFile] and [requestedRoot] are what the call itself said about the
  /// project. A server started outside any Dart package has nothing else to go
  /// on, so resolving without them would fail here before the call's own signals
  /// were ever read.
  Future<CallToolResult> _withProject(
    PatrolSession session,
    Future<CallToolResult> Function() body, {
    String? testFile,
    String? requestedRoot,
    bool projectRequired = true,
  }) async {
    try {
      await session.ensureProjectResolved(
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
      session.noteProjectUnresolved('$err');
    }
    return body();
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
        projectRoot: runArgs.projectRoot,
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
    // A client disconnects by closing stdin as often as by a signal, and either
    // one ends the server.
    final closed = Completer<void>();
    server.server.onclose = () {
      if (!closed.isCompleted) {
        closed.complete();
      }
    };

    try {
      await server.connect(transport);
      _logger.info('MCP server started on stdio');
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
    _logger.info('Shutting down (signal or client disconnect)');

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
    _subscriptions = watchStopSignals((_) {
      if (!_completer.isCompleted) {
        _completer.complete();
        cancel();
      }
    });
  }

  final _completer = Completer<void>();
  late final List<StreamSubscription<io.ProcessSignal>> _subscriptions;

  Future<void> get wait => _completer.future;

  /// Cancels the signal subscriptions. Idempotent.
  void cancel() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }
}
