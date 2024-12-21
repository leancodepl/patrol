import 'dart:ffi';
import 'dart:io';

import 'package:patrol/src/server_port/android_server_port_provider_bindings.dart';

/// Provides a port for the of native server. Gets the port from the native side
/// using ffi.
int getTestServerPort() {
  if (Platform.isAndroid) {
    return AndroidServerPortProvider.getPort();
  } else {
    final nativeLibrary = DynamicLibrary.process();
    final getGlobalPort = nativeLibrary
        .lookup<NativeFunction<Int32 Function()>>('getGlobalPort')
        .asFunction;
    return getGlobalPort();
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
