import 'dart:async';
import 'dart:io';

final class LogStreaming {
  LogStreaming._();
  static final _instance = LogStreaming._();
  static LogStreaming get instance => _instance;

  File? _logFile;
  IOSink? _logSink;

  /// Start logging to [logFile], or to `patrol.log` in the project root.
  Future<String> startLogging(String projectRoot, {String? logFile}) async {
    // Clean up any existing logging session
    await stopLogging();

    _logFile = File(logFile ?? '$projectRoot/patrol.log');
    await _logFile!.parent.create(recursive: true);

    _logSink = _logFile!.openWrite();

    return _logFile!.path;
  }

  Future<void> stopLogging() async {
    final sink = _logSink;
    if (sink == null) {
      return;
    }
    // Detached before the first await: a session's cleanup and the next
    // session's start can both stop the shared sink, and a second close while
    // the first flush is pending throws.
    _logSink = null;
    _logFile = null;

    // Flush any pending writes before closing
    try {
      await sink.flush();
    } catch (_) {} // Ignore flush errors

    await sink.close();
  }

  void writeLog(String message) {
    if (_logSink == null) {
      return;
    }

    try {
      _logSink!.writeln(message);
    } catch (_) {} // Ignore logging errors
  }
}
