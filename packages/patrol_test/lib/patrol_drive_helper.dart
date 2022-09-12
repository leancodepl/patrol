// ignore_for_file: avoid_print

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:patrol_test/src/extensions.dart';

/// Allows for basic control of the Patrol automation server running on device.
class PatrolDriveHelper {
  /// Creates a new [PatrolDriveHelper] instance for use in the driver file (on
  /// test host).
  PatrolDriveHelper()
      : host = Platform.environment['PATROL_HOST']!,
        port = Platform.environment['PATROL_PORT']! {
    print('Creating PatrolDriveHelper instance. Host: $host, port: $port');
  }

  /// Host on which Patrol server instrumentation is running.
  final String host;

  /// Port on [host] on which Patrol server instrumentation is running.
  final String port;

  final _client = http.Client();

  String get _baseUri => 'http://$host:$port';

  /// Returns whether the Patrol automation server is running on target device.
  Future<bool> isRunning() async {
    final uri = Uri.parse('$_baseUri/isRunning');
    try {
      final result = await _client.get(uri);
      print('status code: ${result.statusCode}, response body: ${result.body}');
      return result.successful;
    } catch (err) {
      print('failed to call $uri: $err');
      return false;
    }
  }

  /// Stops the instrumentation server.
  Future<void> stop() async {
    final uri = Uri.parse('$_baseUri/stop');
    try {
      print('stopping instrumentation server...');
      await _client.post(uri);
    } catch (err) {
      print('failed to call $uri: $err');
    } finally {
      print('instrumentation server stopped');
    }
  }
}
