import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/setup_validator.dart';

/// Renders a [ValidationReport] for the terminal. Kept separate from the
/// validator so other output formats are a new formatter, not a refactor.
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

      _logger.info(styleBold.wrap('${_decorate(section.title)}:'));
      if (findings.isEmpty) {
        _logger.success('✓ all checks passed');
      }
      findings.forEach(_printFinding);
      _logger.info('');
    }

    _printSummary(report);
  }

  String _decorate(String title) => switch (title) {
    'Environment' => '🩺 Environment',
    'Shared' => '📦 Shared',
    'Project' => '📁 Project',
    'Android' => '🤖 Android',
    'iOS' => '🍎 iOS',
    'macOS' => '🖥️ macOS',
    _ => title,
  };

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
      _logger.info('    ${lightCyan.wrap('Fix:')} ${finding.fix}');
    }
    if (finding.docsUrl != null) {
      _logger.info('    ${darkGray.wrap('Docs: ${finding.docsUrl}')}');
    }
  }

  void _printSummary(ValidationReport report) {
    final errors = report.countOf(Severity.error);
    final warnings = report.countOf(Severity.warning);
    final notices = report.countOf(Severity.notice);
    final line =
        'Result: $errors ${_plural(errors, 'error')}, '
        '$warnings ${_plural(warnings, 'warning')}, '
        '$notices ${_plural(notices, 'notice')}';

    if (errors > 0) {
      _logger.err('❌ $line');
    } else if (warnings > 0) {
      _logger.info(lightYellow.wrap('⚠️ $line'));
    } else {
      _logger.info(lightGreen.wrap('✅ $line'));
    }
  }

  String _plural(int count, String noun) => count == 1 ? noun : '${noun}s';
}
