import 'dart:async';

import 'package:adb/adb.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/vm_connection_details.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:process/process.dart';

class DeviceToHostPortTransformer
    implements StreamTransformer<VMConnectionDetails, VMConnectionDetails> {
  DeviceToHostPortTransformer({
    required ProcessManager processManager,
    required TargetPlatform devicePlatform,
    required Adb adb,
    required Logger logger,
  })  : _processManager = processManager,
        _devicePlatform = devicePlatform,
        _adb = adb,
        _logger = logger;

  final ProcessManager _processManager;
  final TargetPlatform _devicePlatform;
  final Adb _adb;
  final Logger _logger;

  /// The number was chosen randomly
  static const _hostPort = 61011;

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

  Future<int?> _devicePortToHostPort(int devicePort) async {
    final int? hostPort;

    switch (_devicePlatform) {
      case TargetPlatform.android:
        await _adb.forwardPorts(fromHost: _hostPort, toDevice: devicePort);

        // It is necessary to grab the port from adb forward --list because
        // if debugger was attached, the port might be different from the one
        // we set
        final forwardList = await _processManager.run(
          // TODO: Add to wrapper
          ['adb', 'forward', '--list'],
          runInShell: true,
        );
        final output = forwardList.stdout as String;
        hostPort = int.tryParse(
          RegExp('tcp:([0-9]+) tcp:$devicePort').firstMatch(output)?.group(1) ??
              '',
        );
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
