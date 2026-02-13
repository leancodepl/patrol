import 'dart:convert';
import 'dart:io';

/// Wrapper around Process with timeout and logging support.
class ProcessRunner {
  const ProcessRunner({this.workingDirectory});

  final String? workingDirectory;

  /// Runs a command and returns the result.
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Duration timeout = const Duration(minutes: 5),
    Map<String, String>? environment,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      environment: environment,
    );

    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    final stdoutFuture = process.stdout
        .transform(utf8.decoder)
        .forEach(stdoutBuffer.write);
    final stderrFuture = process.stderr
        .transform(utf8.decoder)
        .forEach(stderrBuffer.write);

    final exitCode = await process.exitCode.timeout(
      timeout,
      onTimeout: () {
        process.kill(ProcessSignal.sigterm);
        throw ProcessTimeoutException(
          'Process timed out after ${timeout.inSeconds}s: '
          '$executable ${arguments.join(' ')}',
        );
      },
    );

    await Future.wait([stdoutFuture, stderrFuture]);

    return ProcessResult(
      exitCode: exitCode,
      stdout: stdoutBuffer.toString(),
      stderr: stderrBuffer.toString(),
    );
  }

  /// Runs a command string by splitting it and executing.
  Future<ProcessResult> runCommand(
    String command, {
    String? workingDirectory,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final parts = command.split(' ');
    return run(
      parts.first,
      parts.skip(1).toList(),
      workingDirectory: workingDirectory,
      timeout: timeout,
    );
  }
}

class ProcessResult {
  const ProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;

  bool get success => exitCode == 0;

  String get output => stdout.isNotEmpty ? stdout : stderr;
}

class ProcessTimeoutException implements Exception {
  const ProcessTimeoutException(this.message);

  final String message;

  @override
  String toString() => message;
}
