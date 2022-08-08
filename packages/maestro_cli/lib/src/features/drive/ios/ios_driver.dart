import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:maestro_cli/src/common/logging.dart';
import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;
import 'package:maestro_cli/src/features/drive/platform_driver.dart';

class IOSDriver extends PlatformDriver {
  @override
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required String device,
    required String? flavor,
    Map<String, String> dartDefines = const {},
    required bool verbose,
    required bool debug,
    bool simulator = false,
  }) async {
    final cancel = await _runServer(
      deviceName: device,
      simulator: simulator,
      onServerInstalled: () async {
        await flutter_driver.runWithOutput(
          driver: driver,
          target: target,
          host: host,
          port: port,
          verbose: verbose,
          device: device,
          flavor: flavor,
          dartDefines: dartDefines,
        );
      },
    );

    await cancel();
  }

  @override
  Future<List<Device>> devices() async {
    final result = await Process.run(
      'flutter',
      ['devices', '--machine'],
    );

    final jsonOutput = jsonDecode(result.stdout as String) as List<dynamic>;

    final iosDevices = <IOSDevice>[];
    for (final deviceJson in jsonOutput) {
      deviceJson as Map<String, dynamic>;

      final name = deviceJson['name'] as String;
      final id = deviceJson['id'] as String;
      final targetPlatform = deviceJson['targetPlatform'] as String;

      if (targetPlatform == 'ios') {
        iosDevices.add(IOSDevice(name: name, udid: id));
      }
    }

    return iosDevices.map((device) => Device.iOS(name: device.name)).toList();
  }

  Future<Future<void> Function()> _runServer({
    required String deviceName,
    required void Function() onServerInstalled,
    bool simulator = false,
  }) async {
    // TODO: don't hardcode working directory
    const xcProjPath = '/Users/bartek/dev/leancode/maestro/AutomatorServer/ios';

    // TODO: Fix failing to build when using Dart x86_64.
    final process = await Process.start(
      'xcodebuild',
      [
        'test',
        '-workspace',
        'AutomatorServer.xcworkspace',
        '-scheme',
        'AutomatorServer',
        '-sdk',
        if (simulator) 'iphonesimulator' else 'iphoneos',
        '-destination',
        'platform=iOS${simulator ? " Simulator" : ""},name=$deviceName',
      ],
      runInShell: true,
      workingDirectory: xcProjPath,
    );

    final stdOutSub = process.stdout.listen((msg) {
      final lines = systemEncoding
          .decode(msg)
          .split('\n')
          .map((str) => str.trim())
          .toList()
        ..removeWhere((element) => element.isEmpty);

      for (final line in lines) {
        if (line.startsWith('MaestroServer')) {
          log.info(line);
        } else {
          log.fine(line);
        }

        if (line.contains('Server started')) {
          onServerInstalled();
        }
      }
    });

    final stdErrSub = process.stderr.listen((msg) {
      final text = systemEncoding.decode(msg).trim();
      log.severe(text);

      if (text.contains('** TEST FAILED **')) {
        throw Exception(
          'Test failed. See logs above. Also, consider running with --verbose.',
        );
      }
    });

    return () async {
      await process.exitCode.then((exitCode) async {
        await stdOutSub.cancel();
        await stdErrSub.cancel();

        final msg = 'xcodebuild exited with code $exitCode';
        if (exitCode == 0) {
          log.info(msg);
        } else {
          log.severe(msg);
        }
      });
    };
  }
}

class IOSDevice {
  IOSDevice({required this.name, required this.udid});

  final String name;
  final String udid;
}
