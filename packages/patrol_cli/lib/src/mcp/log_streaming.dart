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

  /// Closes the log file. Writes made while it closes, or after, are dropped.
  Future<void> stopLogging() async {
    final sink = _logSink;
    if (sink == null) {
      return;
    }
    _logSink = null;
    _logFile = null;

    try {
      await sink.flush();
      await sink.close();
    } catch (_) {
      // The file or its directory may be gone already.
    }
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
