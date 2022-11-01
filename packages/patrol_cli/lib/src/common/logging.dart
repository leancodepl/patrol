// ignore_for_file: avoid_print

import 'dart:async';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:logging/logging.dart';
import 'package:mason_logger/mason_logger.dart' as mason_logger;

extension LoggerX on Logger {
  static final _logger = mason_logger.Logger();

  /// Writes progress message to stdout.
  mason_logger.Progress progress(String message) {
    return _logger.progress(message);
  }

  set verbose(bool newValue) => _verbose = newValue;

  void ok(String msg) {
    info('${mason_logger.green.wrap("✓")} $msg');
  }

  void err(String msg) {
    info('${mason_logger.red.wrap("✗")} $msg');
  }
}

bool _verbose = false;
StreamSubscription<void>? _sub;

/// Sets up the global logger.
///
/// We use 4 log levels:
/// - [Level.SEVERE], printed in red
/// - [Level.WARNING], printed in yellow
/// - [Level.INFO], printed in white
/// - [Level.FINE], printed in grey and only when [_verbose] is true
Future<void> setUpLogger() async {
  Logger.root.level = Level.ALL;

  await _sub?.cancel();
  _sub = Logger.root.onRecord.listen((log) {
    final fmtLog = _formatLog(log);

    if (log.level >= Level.SEVERE) {
      print(AnsiStyles.red(fmtLog));
    } else if (log.level >= Level.WARNING) {
      print(AnsiStyles.yellow(fmtLog));
    } else if (log.level >= Level.INFO) {
      print(fmtLog);
    } else if (log.level >= Level.FINE && _verbose) {
      print(AnsiStyles.grey(fmtLog));
    }
  });
}

/// Copied from
/// https://github.com/leancodepl/logging_bugfender/blob/master/lib/src/print_strategy.dart.
String _formatLog(LogRecord record) {
  final hasName = record.loggerName.isNotEmpty;
  final hasMessage = record.message != 'null' && record.message.isNotEmpty;

  final hasTopLine = hasName || hasMessage;
  final hasError = record.error != null;
  final hasStackTrace = record.stackTrace != null;

  final log = StringBuffer();

  if (hasTopLine) {
    log.writeAll(
      <String>[
        if (hasName) '${record.loggerName}: ',
        if (hasMessage) record.message,
      ],
    );
  }

  if (hasTopLine && hasError) {
    log.write('\n');
  }

  if (hasError) {
    log.write(record.error);
  }

  if (hasError && hasStackTrace) {
    log.write('\n');
  }

  if (hasStackTrace) {
    log.write(record.stackTrace);
  }

  return log.toString();
}
