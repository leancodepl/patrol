import '../../utils/process_runner.dart';
import 'agent_tool.dart';

/// Executes allowed commands only (sandboxed).
class RunCommandTool extends AgentTool {
  RunCommandTool({
    required this.projectRoot,
    required this.allowedCommands,
    ProcessRunner? processRunner,
  }) : _processRunner = processRunner ?? ProcessRunner(workingDirectory: projectRoot);

  final String projectRoot;
  final List<String> allowedCommands;
  final ProcessRunner _processRunner;

  @override
  String get name => 'run_command';

  @override
  String get description =>
      'Run an allowed command in the project directory. '
      'Allowed commands: ${allowedCommands.join(', ')}';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'command': {
            'type': 'string',
            'description':
                'The command to run. Must be one of the allowed commands.',
          },
        },
        'required': ['command'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final command = input['command'] as String;

    // Security: check against allowlist
    if (!_isAllowed(command)) {
      return 'Error: Command not allowed. '
          'Allowed commands: ${allowedCommands.join(', ')}';
    }

    try {
      final result = await _processRunner.runCommand(
        command,
        workingDirectory: projectRoot,
        timeout: const Duration(minutes: 3),
      );

      final output = StringBuffer();
      if (result.stdout.isNotEmpty) {
        output.writeln(result.stdout);
      }
      if (result.stderr.isNotEmpty) {
        output.writeln(result.stderr);
      }

      final outputStr = output.toString();
      // Truncate long outputs
      if (outputStr.length > 10000) {
        return '${outputStr.substring(0, 10000)}\n\n[... output truncated ...]'
            '\nExit code: ${result.exitCode}';
      }

      return '$outputStr\nExit code: ${result.exitCode}';
    } on ProcessTimeoutException {
      return 'Error: Command timed out after 3 minutes.';
    } on Exception catch (e) {
      return 'Error running command: $e';
    }
  }

  bool _isAllowed(String command) {
    return allowedCommands.any((allowed) {
      // Exact match or prefix match (e.g., "dart analyze" matches "dart analyze lib/")
      return command == allowed || command.startsWith('$allowed ');
    });
  }
}
