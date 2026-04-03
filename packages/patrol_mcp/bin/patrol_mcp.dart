import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart' as logging;
import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_mcp/src/native_tree_service.dart';
import 'package:patrol_mcp/src/patrol_session.dart';
import 'package:patrol_mcp/src/screenshot_service.dart';

/// Version of patrol_mcp. Must be kept in sync with pubspec.yaml.
const version = '0.1.4';

const double _defaultTimeoutMinutes = 5;

ArgParser _buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void _printUsage(ArgParser argParser) {
  stderr
    ..writeln('Usage: patrol_mcp [--help] [--version]')
    ..writeln()
    ..writeln('Environment variables:')
    ..writeln(
      '  PROJECT_ROOT      Path to Flutter project (default: current directory)',
    )
    ..writeln('  PATROL_FLAGS      Additional flags for patrol develop command')
    ..writeln(
      '  SHOW_TERMINAL     Set to "true" to open terminal with logs (macOS)',
    )
    ..writeln(
      '  (also supports patrol_cli env vars, e.g. PATROL_FLUTTER_COMMAND)',
    )
    ..writeln()
    ..writeln(argParser.usage);
}

Duration _parseTimeout(num? timeoutMinutes) {
  final minutes = timeoutMinutes?.toDouble() ?? _defaultTimeoutMinutes;
  return Duration(milliseconds: (minutes * 60 * 1000).round());
}

class _PatrolRunArgs {
  _PatrolRunArgs.fromJson(Map<String, dynamic> json)
    : testFile = json['testFile'] as String,
      timeout = _parseTimeout(json['timeoutMinutes'] as num?);

  final String testFile;
  final Duration timeout;
}

/// Output schema for `run` and `status` -- a serialized [PatrolStatus].
/// Keys mirror `PatrolStatus.toMap`.
const _sessionStatusSchema = JsonObject(
  properties: {
    'isDevelopRunning': JsonBoolean(),
    'testState': JsonString(
      enumValues: ['idle', 'running', 'finishedPassed', 'finishedFailed'],
    ),
    'currentTestFile': JsonString(),
    'warning': JsonString(),
    'deviceName': JsonString(),
    'deviceId': JsonString(),
    'devicePlatform': JsonString(),
    'output': JsonString(),
    'summary': JsonString(),
  },
  required: ['isDevelopRunning', 'testState', 'output', 'summary'],
);

Future<int> main(List<String> args) async {
  final argParser = _buildParser();
  logging.Logger.root.level = logging.Level.INFO;
  logging.Logger.root.onRecord.listen((r) {
    stderr.writeln('[${r.level.name}][${r.loggerName}] ${r.message}');
  });

  try {
    final results = argParser.parse(args);
    if (results.flag('help')) {
      _printUsage(argParser);
      return 0;
    }
    if (results.flag('version')) {
      stderr.writeln('patrol_mcp version: $version');
      return 0;
    }

    final projectRoot =
        Platform.environment['PROJECT_ROOT'] ?? Directory.current.path;
    final flags = Platform.environment['PATROL_FLAGS'] ?? '';
    final showTerminal =
        Platform.environment['SHOW_TERMINAL']?.toLowerCase() == 'true';

    final patrolSession = PatrolSession(
      flutterProjectPath: projectRoot,
      additionalFlags: flags,
      showTerminal: showTerminal,
    );

    final server =
        McpServer(
            const Implementation(name: 'patrol_mcp', version: version),
            options: const McpServerOptions(
              capabilities: ServerCapabilities(
                tools: ServerCapabilitiesTools(),
              ),
              instructions:
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
                  '- status is optional and mainly useful for debugging session state and recent output.\n'
                  '- native-tree is intended for native interactions and cross-app/native context inspection.',
            ),
          )
          ..registerTool(
            'run',
            description:
                'Run patrol tests (starts new session or restarts if already running) and wait for completion',
            inputSchema: const ToolInputSchema(
              properties: {
                'testFile': JsonString(
                  description:
                      'Path to the test file, relative to PROJECT_ROOT '
                      "(e.g., 'integration_test/example_test.dart' or "
                      "'patrol_test/scenarios/login_test.dart'). "
                      'Do NOT include the PROJECT_ROOT prefix in the path.',
                ),
                'timeoutMinutes': JsonNumber(
                  description: 'Optional timeout in minutes (default: 5)',
                ),
              },
              required: ['testFile'],
            ),
            outputSchema: _sessionStatusSchema,
            annotations: const ToolAnnotations(title: 'Run Patrol Tests'),
            callback: (args, extra) async {
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

              final runArgs = _PatrolRunArgs.fromJson(args);
              final result = await patrolSession.startAndWait(
                runArgs.testFile,
                timeout: runArgs.timeout,
              );
              final status = result.toMap();
              return CallToolResult(
                content: [TextContent(text: jsonEncode(status))],
                structuredContent: status,
              );
            },
          )
          ..registerTool(
            'quit',
            description: 'Quit the active patrol session gracefully',
            annotations: const ToolAnnotations(title: 'Quit Patrol'),
            callback: (args, extra) {
              if (!patrolSession.getStatus().isDevelopRunning) {
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
              final result = patrolSession.sendCommand(PatrolCommand.quit);
              return CallToolResult(content: [TextContent(text: result)]);
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
            callback: (args, extra) {
              final status = patrolSession.getStatus().toMap();
              return CallToolResult(
                content: [TextContent(text: jsonEncode(status))],
                structuredContent: status,
              );
            },
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
            callback: (args, extra) {
              return ScreenshotService.handleScreenshotRequest(
                patrolSession.device,
                webDebuggerPort: patrolSession.webDebuggerPort,
              );
            },
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
            callback: (args, extra) {
              return NativeTreeService.handleGetNativeTreeRequest(
                patrolSession.device,
                patrolSession.testServerPort,
              );
            },
          );

    return await _runStdio(server, patrolSession);
  } on FormatException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln();
    _printUsage(_buildParser());
    return 1;
  } catch (e, st) {
    stderr
      ..writeln('Error: $e')
      ..writeln(st.toString());
    return 1;
  }
}

Future<int> _runStdio(McpServer server, PatrolSession patrolSession) async {
  final logger = logging.Logger('patrol_mcp');
  final transport = StdioServerTransport();

  // MCP clients disconnect by closing stdin (EOF), not always via SIGTERM, so
  // wake on EOF too -- otherwise we'd block on _ExitSignal forever and orphan.
  final closed = Completer<void>();
  server.server.onclose = () {
    if (!closed.isCompleted) {
      closed.complete();
    }
  };

  try {
    logger.info('Running MCP server on stdio');
    await server.connect(transport);
    logger.info('Server started');
  } catch (e, st) {
    logger.severe('Error when starting the Stdio transport', e, st);
    return 1;
  }

  // Shut down on an OS signal or a client disconnect (stdin EOF).
  final exitSignal = _ExitSignal();
  await Future.any([exitSignal.wait, closed.future]);
  // ProcessSignal.watch() keeps the VM alive; the EOF path skips _handleSignal,
  // so cancel here.
  exitSignal.cancel();
  logger.info('Shutting down (signal or client disconnect)');

  // Tear down any active session so its child processes don't outlive us.
  await patrolSession.dispose();

  await server.close(); // closes the transport too
  logger.info('Stopped');
  return 0;
}

class _ExitSignal {
  _ExitSignal() {
    // ProcessSignal.sigterm cannot be listened to on Windows — it throws
    // SignalException. On that platform, graceful shutdown comes from stdin
    // EOF (MCP stdio transport) and Ctrl-C (SIGINT), both of which continue
    // to work. Guard the registration so the server can start on Windows.
    _sigtermSubscription = !Platform.isWindows
        ? ProcessSignal.sigterm.watch().listen(_handleSignal)
        : null;
    _sigintSubscription = ProcessSignal.sigint.watch().listen(_handleSignal);
  }

  final _completer = Completer<ProcessSignal>();
  late final StreamSubscription<ProcessSignal>? _sigtermSubscription;
  late final StreamSubscription<ProcessSignal> _sigintSubscription;

  Future<ProcessSignal> get wait => _completer.future;

  /// Cancels the signal subscriptions. Idempotent.
  void cancel() => _cleanup();

  void _handleSignal(ProcessSignal signal) {
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
