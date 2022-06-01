// ignore_for_file: avoid_print

import 'package:ansi_styles/ansi_styles.dart';
import 'package:logging/logging.dart';

final log = Logger('maestro');

/// Sets up the global logger.
///
/// We use 4 log levels:
/// - [Level.SEVERE], printed in red
/// - [Level.WARNING], printed in yellow
/// - [Level.INFO], printed in white
/// - [Level.FINE], printed in grey and only when [verbose] is true
void setUpLogger({required bool verbose}) {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((log) {
    if (log.level >= Level.SEVERE) {
      print(AnsiStyles.red(log.message));
    } else if (log.level >= Level.WARNING) {
      print(AnsiStyles.yellow(log.message));
    } else if (log.level >= Level.INFO) {
      print(AnsiStyles.white(log.message));
    } else if (log.level >= Level.FINE && verbose) {
      print(AnsiStyles.grey(log.message));
    }
  });
}
