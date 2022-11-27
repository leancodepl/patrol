import 'dart:io' as io;

import 'package:mason_logger/mason_logger.dart' as mason_logger;
import 'package:mason_logger/mason_logger.dart' show darkGray, red, lightGreen;

export 'package:mason_logger/mason_logger.dart';

/// Like [mason_logger.Progress], but not animated.
class ProgressTask implements mason_logger.Progress {
  ProgressTask(this._message, this._stdout) : _stopwatch = Stopwatch() {
    _stopwatch.start();
    _stdout.write('$_dot $_message...\n');
  }

  final Stopwatch _stopwatch;

  final String _message;
  final io.Stdout _stdout;

  @override
  void complete([String? message]) {
    _stopwatch.stop();
    _stdout.write('${lightGreen.wrap('✓')} ${message ?? _message} $_time\n');
  }

  @override
  void fail([String? message]) {
    _stdout.write('${red.wrap('✗')} ${message ?? _message} $_time\n');
    _stopwatch.stop();
  }

  final _dot = '${lightGreen.wrap("•")}';

  String get _time {
    final elapsedTime = _stopwatch.elapsed.inMilliseconds;
    final displayInMilliseconds = elapsedTime < 100;
    final time = displayInMilliseconds ? elapsedTime : elapsedTime / 1000;
    final formattedTime = displayInMilliseconds
        ? '${time.toString()}ms'
        : '${time.toStringAsFixed(1)}s';
    return '${darkGray.wrap('($formattedTime)')}';
  }

  @override
  void cancel() => throw UnsupportedError('cancel() is not supported');

  @override
  void update(String update) {
    throw UnsupportedError('update() is not supported');
  }
}

class Logger extends mason_logger.Logger {
  Logger({super.level = mason_logger.Level.info});

  mason_logger.Progress task(String message) {
    return ProgressTask(message, io.stdout);
  }
}
