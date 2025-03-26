import 'dart:async';

import 'package:adb/adb.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/bind_unused_port.dart';
import 'package:patrol_cli/src/coverage/vm_connection_details.dart';
import 'package:patrol_cli/src/devices.dart';

class DeviceToHostPortTransformer
    implements StreamTransformer<VMConnectionDetails, VMConnectionDetails> {
  DeviceToHostPortTransformer({
    required Device device,
    required TargetPlatform devicePlatform,
    required Adb adb,
    required Logger logger,
  })  : _device = device,
        _devicePlatform = devicePlatform,
        _adb = adb,
        _logger = logger;

  final Device _device;
  final TargetPlatform _devicePlatform;
  final Adb _adb;
  final Logger _logger;
  int? cachedPort;

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
        if (cachedPort case final cachedPort?) {
          await _adb.forwardPorts(
            fromHost: cachedPort,
            toDevice: devicePort,
            device: _device.id,
          );
        } else {
          cachedPort = await bindUnusedPort<int>(
            (port) async {
              try {
                await _adb.forwardPorts(
                  fromHost: port,
                  toDevice: devicePort,
                  device: _device.id,
                );
                return port;
              } on Exception {
                _logger.warn(
                  'Failed to forward port $port to device port $devicePort',
                );
                return null;
              }
            },
          );
        }

        // It is necessary to grab the port from adb forward --list because
        // if debugger was attached, the port might be different from the one
        // we set
        final forwardList = await _adb.getForwardedPorts();
        hostPort = forwardList
            .getMappedPortsForDevice(_device.id)
            .entries
            .where((entry) => entry.value == devicePort)
            .firstOrNull
            ?.key;
      case TargetPlatform.iOS || TargetPlatform.macOS:
        hostPort = devicePort;
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
