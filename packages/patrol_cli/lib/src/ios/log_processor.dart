import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/src/base/logger.dart';

/// Processes iOS device and simulator logs, writing them to a file and looking for the Flutter observatory URL
class IOSLogProcessor {
  IOSLogProcessor(
      this.deviceId, this.logFilePath, this.onObservatoryUri, this._logger);
  final String deviceId;
  final String logFilePath;
  final void Function(String) onObservatoryUri;
  final Logger _logger;

  StreamSubscription<dynamic>? _logSubscription;
  IOSink? _logSink;
  bool _isSimulator = false;

  /// Starts the iOS device or simulator log stream and writes to a file
  Future<void> start() async {
    _logger.info('Starting iOS log processor');
    await _determineDeviceType();
    await _startIOSLogStream();
    _logger.info('iOS log processor started');
  }

  /// Stops the iOS device or simulator log stream
  Future<void> stop() async {
    await _logSubscription?.cancel();
    await _logSink?.close();
  }

  Future<void> _determineDeviceType() async {
    try {
      final result = await Process.run('xcrun', ['simctl', 'list', 'devices']);
      _isSimulator = result.stdout.toString().contains(deviceId);
    } catch (e) {
      _logger.err('Error determining device type: $e');
      _isSimulator = false; // Assume physical device if there's an error
    }
  }

  Future<void> _startIOSLogStream() async {
    final logFile = File(logFilePath);
    _logSink = logFile.openWrite(mode: FileMode.writeOnly);

    late Process logProcess;
    if (_isSimulator) {
      logProcess = await Process.start('xcrun', ['simctl', 'spawn', deviceId, 'log', 'stream', '--style', 'syslog']);
    } else {
      logProcess = await Process.start('idevicesyslog', ['-u', deviceId]);
    }

    _logSubscription = logProcess.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_processLogLine);

    logProcess.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => _logger.err('Log error: $line'));
  }

  void _processLogLine(String line) {
    _logSink?.writeln(line);
    _checkForObservatoryUri(line);
  }

  void _checkForObservatoryUri(String line) {
    final match = RegExp(r'The Dart VM service is listening on (http://[^\s]+)')
        .firstMatch(line);
    if (match != null) {
      final observatoryUri = match.group(1);
      if (observatoryUri != null) {
        onObservatoryUri(observatoryUri);
      }
    }
  }
}