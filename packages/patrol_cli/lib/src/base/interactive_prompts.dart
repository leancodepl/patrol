import 'dart:io';

import 'package:patrol_cli/src/base/logger.dart';

/// Utility class for interactive command-line prompts.
class InteractivePrompts {
  InteractivePrompts({required Logger logger}) : _logger = logger;

  final Logger _logger;

  /// Prompts the user to select an option from a list.
  ///
  /// Returns the index of the selected option, or null if the user cancels.
  /// Throws [UnsupportedError] if stdin doesn't have a terminal.
  int? selectFromList<T>({
    required String prompt,
    required List<T> options,
    required String Function(T) displayFunction,
    String cancelMessage = 'Cancel',
  }) {
    if (!stdin.hasTerminal) {
      throw UnsupportedError('Interactive prompts require a terminal');
    }

    if (options.isEmpty) {
      throw ArgumentError('Options list cannot be empty');
    }

    _logger.info('$prompt\n');

    // Display the options
    for (var i = 0; i < options.length; i++) {
      _logger.info('  [${i + 1}] ${displayFunction(options[i])}');
    }
    _logger.info('  [q] $cancelMessage\n');

    while (true) {
      stdout.write(
        'Please select an option (1-${options.length}, q to quit): ',
      );
      final input = stdin.readLineSync()?.trim();

      if (input == null || input.isEmpty) {
        _logger.warn('Please enter a valid option.\n');
        continue;
      }

      if (input.toLowerCase() == 'q') {
        return null;
      }

      final selection = int.tryParse(input);
      if (selection == null || selection < 1 || selection > options.length) {
        _logger.warn(
          'Invalid selection. Please enter a number between 1 and ${options.length}, or q to quit.\n',
        );
        continue;
      }

      return selection - 1; // Convert to 0-based index
    }
  }
}
