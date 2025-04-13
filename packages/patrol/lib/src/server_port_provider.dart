import 'dart:ffi';
import 'dart:io';

import 'package:patrol/src/server_port/android_server_port_provider_bindings.dart';

/// Gets the port from the native side using ffi
int getTestServerPort() {
  if (Platform.isAndroid) {
    return AndroidServerPortProvider.getPort();
  } else {
    try {
      return _getIosServerPort();
    } catch (err) {
      return 0;
    }
  }
}

int _getIosServerPort() {
  final nativeLibrary = DynamicLibrary.process();

  // Without this, the analyzer complains about the type of the function.
  // ignore: omit_local_variable_types
  final int Function() getGlobalPort = nativeLibrary
      .lookup<NativeFunction<Int32 Function()>>('getGlobalPort')
      .asFunction();

  return getGlobalPort();
}

/// Returns the port for the app server.
/// This port is set while building the app under test.
int getAppServerPort() {
  return int.parse(
    const String.fromEnvironment('PATROL_APP_SERVER_PORT', defaultValue: '0'),
  );
}
