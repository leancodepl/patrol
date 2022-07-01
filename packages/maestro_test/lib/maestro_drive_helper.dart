// ignore_for_file: avoid_print

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:maestro_test/src/extensions.dart';

/// Allows for basic control of the Maestro automation server running on device.
class MaestroDriveHelper {
  /// Creates a new [MaestroDriveHelper] instance for use in the driver file (on
  /// test host).
  MaestroDriveHelper()
      : host = Platform.environment['MAESTRO_HOST']!,
        port = Platform.environment['MAESTRO_PORT']! {
    print('Creating MaestroDriveHelper instance. Host: $host, port: $port');
  }

  /// Host on which Maestro server instrumentation is running.
  final String host;

  /// Port on [host] on which Maestro server instrumentation is running.
  final String port;

  final _client = http.Client();

  String get _baseUri => 'http://$host:$port';

  /// Returns whether the Maestro automation server is running on target device.
  Future<bool> isRunning() async {
    try {
      final result = await _client.get(Uri.parse('$_baseUri/isRunning'));
      print('status code: ${result.statusCode}, response body: ${result.body}');
      return result.successful;
    } catch (err) {
      print('failed to call isRunning(): $err');
      return false;
    }
  }

  /// Stops the instrumentation server.
  Future<void> stop() async {
    try {
      print('stopping instrumentation server...');
      await _client.post(Uri.parse('$_baseUri/stop'));
    } catch (err) {
      print('failed to call stop(): $err');
    } finally {
      print('instrumentation server stopped');
    }
  }
}
