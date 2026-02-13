import '../cli/common/cli_logger.dart';
import 'marathon_client.dart';

/// Formats and displays test results in the terminal.
class ResultReporter {
  const ResultReporter({required CliLogger logger}) : _logger = logger;

  final CliLogger _logger;

  /// Reports Marathon Cloud run results.
  void reportMarathonResults(MarathonRunResult result) {
    _logger.header('Test Results');

    _logger.keyValue('Run ID', result.runId);
    _logger.keyValue('Passed', '${result.passed}');
    _logger.keyValue('Failed', '${result.failed}');
    _logger.keyValue('Skipped', '${result.skipped}');
    _logger.keyValue('Total', '${result.total}');
    _logger.info('');

    if (result.success) {
      _logger.success('All tests passed!');
    } else {
      _logger.error(
        '${result.failed} test(s) failed.',
      );
      if (result.error != null) {
        _logger.error(result.error!);
      }
    }
  }

  /// Reports local validation results.
  void reportValidation({
    required bool isValid,
    required List<String> issues,
  }) {
    _logger.header('Validation Results');

    if (isValid) {
      _logger.success('All files pass dart analyze.');
    } else {
      _logger.error('Found ${issues.length} issue(s):');
      for (final issue in issues) {
        _logger.error('  $issue');
      }
    }
  }
}
