import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart' as logging;
import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_mcp/src/native_tree_service.dart';
import 'package:patrol_mcp/src/patrol_session.dart';
import 'package:patrol_mcp/src/screenshot_service.dart';

const version = '0.3.0';

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
    ..writeln('  PATROL_TEST_PORT  Port for patrol test server (default: 8081)')
    ..writeln(
      '  SHOW_TERMINAL     Set to "true" to open terminal with logs (macOS)',
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
            options: const ServerOptions(
              capabilities: ServerCapabilities(
                tools: ServerCapabilitiesTools(),
              ),
            ),
          )
          // Tools
          ..tool(
            'patrol-run',
            description:
                'Run patrol tests (starts new session or restarts if already running) and wait for completion',
            toolInputSchema: const ToolInputSchema(
              properties: {
                'testFile': {
                  'type': 'string',
                  'description':
                      "Path to the test file (e.g., 'integration_test/personal_stats_test.dart')",
                },
                'timeoutMinutes': {
                  'type': 'number',
                  'description':
                      'Optional timeout in minutes (default: $_defaultTimeoutMinutes)',
                },
              },
            ),
            annotations: const ToolAnnotations(title: 'Run Patrol Tests'),
            callback: ({args, extra}) async {
              final runArgs = _PatrolRunArgs.fromJson(args!);

              final result = await patrolSession.startAndWait(
                runArgs.testFile,
                timeout: runArgs.timeout,
              );
              return CallToolResult.fromContent(
                content: [TextContent(text: jsonEncode(result.toMap()))],
              );
            },
          )
          ..tool(
            'patrol-quit',
            description: 'Quit the active patrol session gracefully',
            toolInputSchema: const ToolInputSchema(properties: {}),
            annotations: const ToolAnnotations(title: 'Quit Patrol'),
            callback: ({args, extra}) {
              final result = patrolSession.sendCommand(PatrolCommand.quit);
              return CallToolResult.fromContent(
                content: [TextContent(text: result)],
              );
            },
          )
          ..tool(
            'patrol-status',
            description:
                'Get the current status of the patrol session and recent output',
            toolInputSchema: const ToolInputSchema(properties: {}),
            annotations: const ToolAnnotations(
              title: 'Get Status',
              readOnlyHint: true,
              idempotentHint: true,
            ),
            callback: ({args, extra}) {
              final status = patrolSession.getStatus();
              return CallToolResult.fromContent(
                content: [TextContent(text: jsonEncode(status.toMap()))],
              );
            },
          )
          ..tool(
            'patrol-screenshot',
            description:
                'Capture a screenshot of the current device/simulator screen',
            toolInputSchema: const ToolInputSchema(
              properties: {
                'platform': {
                  'type': 'string',
                  'enum': ['android', 'ios'],
                  'description':
                      'The platform to capture screenshot from (android or ios)',
                },
              },
            ),
            annotations: const ToolAnnotations(
              title: 'Capture Screenshot',
              readOnlyHint: true,
            ),
            callback: ({args, extra}) {
              return ScreenshotService.handleScreenshotRequest(args ?? {});
            },
          )
          ..tool(
            'patrol-native-tree',
            description:
                'Fetch the native UI tree. '
                'Requires an active patrol develop session.',
            toolInputSchema: const ToolInputSchema(properties: {}),
            annotations: const ToolAnnotations(
              title: 'Get Native UI Tree',
              readOnlyHint: true,
            ),
            callback: ({args, extra}) {
              return NativeTreeService.handleGetNativeTreeRequest(args ?? {});
            },
          );

    return await _runStdio(server);
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

Future<int> _runStdio(McpServer server) async {
  final logger = logging.Logger('patrol_mcp');
  final transport = StdioServerTransport();
  try {
    logger.info('Running MCP server on stdio');
    await server.connect(transport);
    logger.info('Server started');
  } catch (e, st) {
    logger.severe('Error when starting the Stdio transport', e, st);
    return 1;
  }

  final signal = await _ExitSignal().wait;
  logger.info('Received ${signal.name}, stopping');
  await server.close();
  await transport.close();
  logger.info('Stopped');
  return 0;
}

class _ExitSignal {
  _ExitSignal() {
    _sigtermSubscription = ProcessSignal.sigterm.watch().listen(_handleSignal);
    _sigintSubscription = ProcessSignal.sigint.watch().listen(_handleSignal);
  }

  final _completer = Completer<ProcessSignal>();
  late final StreamSubscription<ProcessSignal> _sigtermSubscription;
  late final StreamSubscription<ProcessSignal> _sigintSubscription;

  Future<ProcessSignal> get wait => _completer.future;

  void _handleSignal(ProcessSignal signal) {
    if (!_completer.isCompleted) {
      _completer.complete(signal);
      _cleanup();
    }
  }

  void _cleanup() {
    _sigtermSubscription.cancel();
    _sigintSubscription.cancel();
  }
}
