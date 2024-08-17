import 'dart:async';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/vm_connection_details.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:process/process.dart';

class DeviceToHostPortTransformer
    implements StreamTransformer<VMConnectionDetails, VMConnectionDetails> {
  DeviceToHostPortTransformer({
    required ProcessManager processManager,
    required TargetPlatform devicePlatform,
    required Logger logger,
  })  : _processManager = processManager,
        _devicePlatform = devicePlatform,
        _logger = logger;

  final ProcessManager _processManager;
  final TargetPlatform _devicePlatform;
  final Logger _logger;

  @override
  Stream<VMConnectionDetails> bind(Stream<VMConnectionDetails> stream) async* {
    await for (final value in stream) {
      final hostPort = await _devicePortToHostPort(value.port);
      if (hostPort != null) {
        yield VMConnectionDetails(
          port: hostPort,
          auth: value.auth,
        );
      }
    }
  }

  Future<io.ProcessResult> _forwardAdbPort(String host, String guest) async {
    return _processManager.run(
      ['adb', 'forward', 'tcp:$host', 'tcp:$guest'],
      runInShell: true,
    );
  }

  // TODO: Process disposal?
  Future<String?> _devicePortToHostPort(String devicePort) async {
    final String? hostPort;

    switch (_devicePlatform) {
      case TargetPlatform.android:
        await _forwardAdbPort('61011', devicePort);

        // It is necessary to grab the port from adb forward --list because
        // if debugger was attached, the port might be different from the one
        // we set
        final forwardList = await _processManager.run(
          ['adb', 'forward', '--list'],
          runInShell: true,
        );
        final output = forwardList.stdout as String;
        hostPort =
            RegExp('tcp:([0-9]+) tcp:$devicePort').firstMatch(output)?.group(1);
      case TargetPlatform.iOS || TargetPlatform.macOS:
        hostPort = devicePort;
      default:
        hostPort = null;
    }

    if (hostPort == null) {
      _logger.err('Failed to forward device port $devicePort to host');
      return null;
    }

    return hostPort;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
