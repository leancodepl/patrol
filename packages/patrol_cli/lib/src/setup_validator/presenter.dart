import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/setup_validator.dart';

/// Renders a [ValidationReport] for the terminal.
///
/// Kept separate from the validator so other output formats stay a new
/// formatter, not a refactor.
class ValidationPresenter {
  ValidationPresenter({required Logger logger}) : _logger = logger;

  final Logger _logger;

  /// Prints the report. With [quiet], notices are suppressed.
  void present(ValidationReport report, {bool quiet = false}) {
    for (final section in report.sections) {
      final findings = quiet
          ? section.findings
                .where((finding) => finding.severity != Severity.notice)
                .toList()
          : section.findings;

      if (quiet && findings.isEmpty && section.findings.isNotEmpty) {
        continue;
      }

      _logger.info('${section.title}:');
      if (findings.isEmpty) {
        _logger.success('✓ all checks passed');
      }
      findings.forEach(_printFinding);
      _logger.info('');
    }

    final errors = report.countOf(Severity.error);
    final warnings = report.countOf(Severity.warning);
    _logger.info(
      'Result: $errors ${_plural(errors, 'error')}, '
      '$warnings ${_plural(warnings, 'warning')}',
    );
  }

  void _printFinding(Finding finding) {
    final headline = '[${finding.id}] ${finding.summary}';
    switch (finding.severity) {
      case Severity.error:
        _logger.err('✗ $headline');
      case Severity.warning:
        _logger.warn(headline, tag: '!');
      case Severity.notice:
        _logger.info('• $headline');
    }
    if (finding.fix != null) {
      _logger.info('    Fix: ${finding.fix}');
    }
    if (finding.docsUrl != null) {
      _logger.info('    Docs: ${finding.docsUrl}');
    }
  }

  String _plural(int count, String noun) => count == 1 ? noun : '${noun}s';
}
