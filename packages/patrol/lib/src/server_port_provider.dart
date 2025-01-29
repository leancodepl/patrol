import 'dart:io';

import 'package:patrol/src/server_port/android_server_port_provider_bindings.dart';
import 'package:patrol/src/server_port/ios_server_port_provider_bindings.dart';

/// Provides a port for the of native server. Gets the port from the native side
/// using ffi.
int getTestServerPort() {
  if (Platform.isAndroid) {
    return AndroidServerPortProvider.getPort();
  } else {
    try {
      final port = IOSServerPortProvider123.getGlobalPort();
      return port;
    } catch (e) {
      print("Error getting port: $e");
      return 0;
    }
  }
}

/// Returns the port for the app server.
/// This port is set while building the app under test.
int getAppServerPort() {
  return int.parse(
    const String.fromEnvironment(
      'PATROL_TEST_SERVER_PORT',
      defaultValue: '0',
    ),
  );
}
