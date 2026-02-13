import '../utils/process_runner.dart';

/// Result of a Marathon Cloud test run.
class MarathonRunResult {
  const MarathonRunResult({
    required this.success,
    required this.runId,
    this.passed = 0,
    this.failed = 0,
    this.skipped = 0,
    this.output,
    this.error,
  });

  final bool success;
  final String runId;
  final int passed;
  final int failed;
  final int skipped;
  final String? output;
  final String? error;

  int get total => passed + failed + skipped;
}

/// Status of a Marathon Cloud run.
class MarathonStatus {
  const MarathonStatus({
    required this.runId,
    required this.status,
    this.passed = 0,
    this.failed = 0,
    this.skipped = 0,
  });

  final String runId;
  final String status;
  final int passed;
  final int failed;
  final int skipped;
}

/// Wraps the `marathon-cloud` CLI for test execution.
class MarathonClient {
  const MarathonClient({
    required ProcessRunner processRunner,
    required this.apiKey,
  }) : _processRunner = processRunner;

  final ProcessRunner _processRunner;
  final String apiKey;

  /// Submits tests to Marathon Cloud.
  Future<MarathonRunResult> run({
    required String platform,
    required String applicationPath,
    required String testApplicationPath,
    bool isolated = true,
    String timeout = '30m',
    String? workingDirectory,
  }) async {
    final args = <String>[
      'run',
      platform,
      '--application', applicationPath,
      '--test-application', testApplicationPath,
      '--api-key', apiKey,
      if (isolated) '--isolated',
      '--output', 'json',
    ];

    final result = await _processRunner.run(
      'marathon-cloud',
      args,
      workingDirectory: workingDirectory,
      timeout: _parseTimeout(timeout),
    );

    if (!result.success) {
      return MarathonRunResult(
        success: false,
        runId: '',
        error: result.stderr.isNotEmpty ? result.stderr : result.stdout,
      );
    }

    return _parseRunResult(result.stdout);
  }

  /// Checks the status of a Marathon Cloud run.
  Future<MarathonStatus> status({String? runId}) async {
    final args = <String>[
      'status',
      if (runId != null) ...['-r', runId],
      '--api-key', apiKey,
    ];

    final result = await _processRunner.run(
      'marathon-cloud',
      args,
      timeout: const Duration(seconds: 30),
    );

    if (!result.success) {
      throw MarathonException(
        result.stderr.isNotEmpty ? result.stderr : result.stdout,
      );
    }

    return _parseStatus(result.stdout);
  }

  Duration _parseTimeout(String timeout) {
    final match = RegExp(r'(\d+)([mhd])').firstMatch(timeout);
    if (match == null) return const Duration(minutes: 30);

    final value = int.parse(match.group(1)!);
    switch (match.group(2)) {
      case 'h':
        return Duration(hours: value);
      case 'd':
        return Duration(days: value);
      case 'm':
      default:
        return Duration(minutes: value);
    }
  }

  MarathonRunResult _parseRunResult(String output) {
    // Parse marathon-cloud output for test results
    var passed = 0;
    var failed = 0;
    var skipped = 0;
    var runId = 'unknown';

    for (final line in output.split('\n')) {
      if (line.contains('run_id') || line.contains('Run ID')) {
        final match = RegExp(r'["\s:]+([a-zA-Z0-9-]+)').firstMatch(
          line.split(':').last,
        );
        if (match != null) runId = match.group(1)?.trim() ?? runId;
      }
      if (line.contains('passed')) {
        final match = RegExp(r'(\d+)').firstMatch(line);
        if (match != null) passed = int.tryParse(match.group(1)!) ?? 0;
      }
      if (line.contains('failed')) {
        final match = RegExp(r'(\d+)').firstMatch(line);
        if (match != null) failed = int.tryParse(match.group(1)!) ?? 0;
      }
      if (line.contains('skipped')) {
        final match = RegExp(r'(\d+)').firstMatch(line);
        if (match != null) skipped = int.tryParse(match.group(1)!) ?? 0;
      }
    }

    return MarathonRunResult(
      success: failed == 0,
      runId: runId,
      passed: passed,
      failed: failed,
      skipped: skipped,
      output: output,
    );
  }

  MarathonStatus _parseStatus(String output) {
    var runId = 'unknown';
    var status = 'unknown';
    var passed = 0;
    var failed = 0;
    var skipped = 0;

    for (final line in output.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.contains('status')) {
        status = trimmed.split(':').last.trim().replaceAll('"', '');
      }
      if (trimmed.contains('run_id') || trimmed.contains('Run ID')) {
        runId = trimmed.split(':').last.trim().replaceAll('"', '');
      }
      if (trimmed.contains('passed')) {
        passed = int.tryParse(
              RegExp(r'(\d+)').firstMatch(trimmed)?.group(1) ?? '',
            ) ??
            0;
      }
      if (trimmed.contains('failed')) {
        failed = int.tryParse(
              RegExp(r'(\d+)').firstMatch(trimmed)?.group(1) ?? '',
            ) ??
            0;
      }
      if (trimmed.contains('skipped')) {
        skipped = int.tryParse(
              RegExp(r'(\d+)').firstMatch(trimmed)?.group(1) ?? '',
            ) ??
            0;
      }
    }

    return MarathonStatus(
      runId: runId,
      status: status,
      passed: passed,
      failed: failed,
      skipped: skipped,
    );
  }
}

class MarathonException implements Exception {
  const MarathonException(this.message);

  final String message;

  @override
  String toString() => 'Marathon error: $message';
}
