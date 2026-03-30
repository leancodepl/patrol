import 'dart:async';
import 'dart:io';

final class LogStreaming {
  LogStreaming._();
  static final _instance = LogStreaming._();
  static LogStreaming get instance => _instance;

  File? _logFile;
  IOSink? _logSink;

  /// Start logging to a file in the project root
  Future<String> startLogging(String projectRoot) async {
    // Clean up any existing logging session
    await stopLogging();

    _logFile = File('$projectRoot/patrol.log');

    _logSink = _logFile!.openWrite();

    return _logFile!.path;
  }

  Future<void> stopLogging() async {
    if (_logSink == null) {
      return;
    }

    // Flush any pending writes before closing
    try {
      await _logSink!.flush();
    } catch (_) {} // Ignore flush errors

    await _logSink!.close();
    _logSink = null;
    _logFile = null;
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
