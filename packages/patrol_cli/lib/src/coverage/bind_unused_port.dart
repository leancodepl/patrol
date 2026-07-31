// Slightly modified code from https://chromium.googlesource.com/external/github.com/dart-lang/test/+/master/pkgs/test_core/lib/src/util/io.dart#147

import 'dart:async';
import 'dart:io';

/// Repeatedly finds a probably-unused port on localhost and passes it to
/// [tryBind] until it binds successfully.
///
/// [tryBind] should return a non-`null` value or a Future completing to a
/// non-`null` value once it binds successfully. This value will be returned
/// by [bindUnusedPort] in turn.
Future<T> bindUnusedPort<T extends Object>(
  FutureOr<T?> Function(int port) tryBind,
) async {
  T? value;
  await Future.doWhile(() async {
    value = await tryBind(await _getUnsafeUnusedPort());
    return value == null;
  });
  return value!;
}

/// Whether this computer supports binding to IPv6 addresses.
var _maySupportIPv6 = true;

/// Returns a port that is probably, but not definitely, not in use.
///
/// This has a built-in race condition: another process may bind this port at
/// any time after this call has returned.
Future<int> _getUnsafeUnusedPort() async {
  late int port;
  if (_maySupportIPv6) {
    try {
      final socket = await ServerSocket.bind(
        InternetAddress.loopbackIPv6,
        0,
        v6Only: true,
      );
      port = socket.port;
      await socket.close();
    } on SocketException {
      _maySupportIPv6 = false;
    }
  }
  if (!_maySupportIPv6) {
    final socket = await RawServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    port = socket.port;
    await socket.close();
  }
  return port;
}
