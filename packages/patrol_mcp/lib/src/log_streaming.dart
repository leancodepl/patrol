import 'dart:async';
import 'dart:io';

final class LogStreaming {
  LogStreaming._();
  static final _instance = LogStreaming._();
  static LogStreaming get instance => _instance;

  File? _logFile;
  IOSink? _logSink;

  /// The teardown of the previous sink, awaited before a new one is opened.
  Future<void>? _closing;

  /// Start logging to a file in the project root
  Future<String> startLogging(String projectRoot) async {
    // Clean up any existing logging session
    await stopLogging();

    _logFile = File('$projectRoot/patrol.log');

    _logSink = _logFile!.openWrite();

    return _logFile!.path;
  }

  Future<void> stopLogging() async {
    final sink = _logSink;
    if (sink == null) {
      // A close may still be in flight from a concurrent caller; opening a new
      // sink before it lands would truncate the file underneath it.
      await _closing;
      return;
    }

    // Detach first. A second caller reaching flush() on a sink that is already
    // closing throws "StreamSink is bound to a stream" and, in the MCP server,
    // takes the whole process down with it.
    _logSink = null;
    _logFile = null;

    final closing = _closing = () async {
      try {
        await sink.flush();
      } catch (_) {} // Ignore flush errors
      try {
        await sink.close();
      } catch (_) {} // Ignore close errors
    }();

    await closing;
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
