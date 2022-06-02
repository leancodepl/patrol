// ignore_for_file: avoid_print

import 'package:ansi_styles/ansi_styles.dart';
import 'package:logging/logging.dart';

final log = Logger('');

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
    final fmtLog = _formatLog(log);

    if (log.level >= Level.SEVERE) {
      print(AnsiStyles.red(fmtLog));
    } else if (log.level >= Level.WARNING) {
      print(AnsiStyles.yellow(fmtLog));
    } else if (log.level >= Level.INFO) {
      print(AnsiStyles.white(fmtLog));
    } else if (log.level >= Level.FINE && verbose) {
      print(AnsiStyles.grey(fmtLog));
    }
  });
}

/// Copied from
/// https://github.com/leancodepl/logging_bugfender/blob/master/lib/src/print_strategy.dart.
String _formatLog(LogRecord record) {
  final log = StringBuffer()
    ..writeAll(
      <String>[
        // '[${record.level.name}]',
        if (record.loggerName.isNotEmpty) '${record.loggerName}:',
        record.message,
      ],
      ' ',
    );

  if (record.error != null) {
    log.write('\n${record.error}');
  }
  if (record.stackTrace != null) {
    log.write('\n${record.stackTrace}');
  }

  return log.toString();
}
