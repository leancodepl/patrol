import 'package:mason_logger/mason_logger.dart';

/// Wrapper around mason_logger providing themed output for Chase CLI.
class CliLogger {
  CliLogger({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  Logger get logger => _logger;

  void info(String message) => _logger.info(message);
  void success(String message) => _logger.success(message);
  void warn(String message) => _logger.warn(message);
  void error(String message) => _logger.err(message);
  void detail(String message) => _logger.detail(message);

  Progress progress(String message) => _logger.progress(message);

  /// Displays a header for a major section.
  void header(String title) {
    _logger.info('');
    _logger.info(lightCyan.wrap('━━━ $title ━━━') ?? title);
    _logger.info('');
  }

  /// Displays a key-value pair.
  void keyValue(String key, String value) {
    _logger.info('  ${darkGray.wrap(key)}: $value');
  }

  /// Displays a cost summary.
  void costSummary({
    required int apiCalls,
    required int inputTokens,
    required int outputTokens,
    required double estimatedCost,
  }) {
    header('Cost Summary');
    keyValue('API calls', '$apiCalls');
    keyValue('Input tokens', '$inputTokens');
    keyValue('Output tokens', '$outputTokens');
    keyValue(
      'Estimated cost',
      '\$${estimatedCost.toStringAsFixed(4)}',
    );
  }

  /// Displays a table of generated test files.
  void testFileTable(List<String> files) {
    if (files.isEmpty) {
      warn('No test files generated.');
      return;
    }

    header('Generated Tests');
    for (final file in files) {
      _logger.info('  ${green.wrap('✓')} $file');
    }
    _logger.info('');
  }

  /// Prompts for yes/no confirmation.
  bool confirm(String message) => _logger.confirm(message);

  /// Prompts for text input.
  String prompt(String message, {String? defaultValue}) {
    return _logger.prompt(message, defaultValue: defaultValue);
  }

  /// Prompts for a choice from options.
  String chooseOne(
    String message, {
    required List<String> choices,
    String? defaultValue,
  }) {
    return _logger.chooseOne(
      message,
      choices: choices,
      defaultValue: defaultValue,
    );
  }
}
