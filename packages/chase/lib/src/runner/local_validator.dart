import '../utils/process_runner.dart';

/// Result of running dart analyze on test files.
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    required this.issues,
    required this.rawOutput,
  });

  final bool isValid;
  final List<String> issues;
  final String rawOutput;
}

/// Validates generated Patrol tests using `dart analyze`.
class LocalValidator {
  const LocalValidator({
    required ProcessRunner processRunner,
    required this.testDirectory,
  }) : _processRunner = processRunner;

  final ProcessRunner _processRunner;
  final String testDirectory;

  /// Runs `dart analyze` on the integration test directory.
  Future<ValidationResult> validate({String? workingDirectory}) async {
    final result = await _processRunner.run(
      'dart',
      ['analyze', testDirectory],
      workingDirectory: workingDirectory,
      timeout: const Duration(minutes: 2),
    );

    final output = result.output;
    final issues = _parseIssues(output);

    return ValidationResult(
      isValid: result.success && issues.isEmpty,
      issues: issues,
      rawOutput: output,
    );
  }

  /// Runs `dart format` on the integration test directory.
  Future<void> format({String? workingDirectory}) async {
    await _processRunner.run(
      'dart',
      ['format', testDirectory],
      workingDirectory: workingDirectory,
    );
  }

  List<String> _parseIssues(String output) {
    final issues = <String>[];
    final lines = output.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // dart analyze outputs lines like:
      // error - ... - path.dart:line:col - ERROR_CODE
      // warning - ... - path.dart:line:col - WARNING_CODE
      // info - ... - path.dart:line:col - INFO_CODE
      if (trimmed.startsWith('error') ||
          trimmed.startsWith('warning') ||
          trimmed.contains(' error ') ||
          trimmed.contains(' warning ')) {
        issues.add(trimmed);
      }
    }

    return issues;
  }
}
