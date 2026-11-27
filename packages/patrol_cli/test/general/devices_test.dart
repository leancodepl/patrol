import 'dart:async';
import 'dart:io' show IOOverrides;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/fakes.dart';
import '../src/fixtures.dart';
import '../src/mocks.dart';

void main() {
  late DeviceFinder deviceFinder;
  late MockProcessManager processManager;

  setUp(() {
    processManager = MockProcessManager();
    final disposeScope = DisposeScope();
    final logger = MockLogger();
    deviceFinder = DeviceFinder(
      processManager: processManager,
      parentDisposeScope: disposeScope,
      logger: logger,
    );
  });

  group('findDevicesToUse()', () {
    test('throws when no devices are attached', () {
      expect(
        () =>
            deviceFinder.findDevicesToUse(attachedDevices: [], wantDevices: []),
        throwsA(
          isA<ToolExit>().having(
            (err) => err.message,
            'message',
            'No devices attached',
          ),
        ),
      );
    });

    test(
      'returns the first device when 1 device is attached and no devices are '
      'wanted',
      () {
        final devicesToUse = deviceFinder.findDevicesToUse(
          attachedDevices: [androidDevice],
          wantDevices: [],
        );

        expect(devicesToUse, [androidDevice]);
      },
    );

    test('prefers a non-Linux device when no devices are wanted', () {
      const linux = Device(
        name: 'Linux',
        id: 'linux',
        targetPlatform: TargetPlatform.linux,
        real: true,
      );
      const chrome = Device(
        name: 'Chrome',
        id: 'chrome',
        targetPlatform: TargetPlatform.web,
        real: true,
      );

      // No terminal: no interactive device selection.
      final stdin = MockStdin();
      when(() => stdin.hasTerminal).thenReturn(false);

      // `flutter devices` lists the Linux desktop before Chrome.
      expect(
        IOOverrides.runZoned(
          () => deviceFinder.findDevicesToUse(
            attachedDevices: [linux, chrome],
            wantDevices: [],
          ),
          stdin: () => stdin,
        ),
        [chrome],
      );
      expect(
        deviceFinder.findDevicesToUse(
          attachedDevices: [linux],
          wantDevices: [],
        ),
        [linux],
      );
    });

    test(
      'returns the device when 1 device is attached and it is also wanted',
      () {
        final devicesToUse = deviceFinder.findDevicesToUse(
          attachedDevices: [androidDevice],
          wantDevices: [androidDeviceId],
        );

        expect(devicesToUse, [androidDevice]);
      },
    );

    test('throws when the wanted device is not attached', () {
      expect(
        () => deviceFinder.findDevicesToUse(
          attachedDevices: [androidDevice],
          wantDevices: [iosDeviceName],
        ),
        throwsA(
          isA<ToolExit>().having(
            (err) => err.message,
            'message',
            'Device $iosDeviceName is not attached',
          ),
        ),
      );
    });

    test('returns the wanted device from the pool of attached devices', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId],
      );

      expect(devicesToUse, [androidDevice]);
    });

    test('returns the wanted devices from the pool of attached devices', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId, iosDeviceName],
      );

      expect(devicesToUse, [androidDevice, iosDevice]);
    });

    test("throws when 'all' is not the only wanted device", () {
      expect(
        () => deviceFinder.findDevicesToUse(
          attachedDevices: [androidDevice, iosDevice],
          wantDevices: ['all', iosDeviceName],
        ),
        throwsA(
          isA<ToolExit>().having(
            (err) => err.message,
            'description',
            "No other devices can be specified when using 'all'",
          ),
        ),
      );
    });

    test('finds Android device by its id', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId],
      );

      expect(devicesToUse, [androidDevice]);
    });

    test('finds Android device by its name', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceName],
      );

      expect(devicesToUse, [androidDevice]);
    });

    test('finds iOS device by its id', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [iosDeviceId],
      );

      expect(devicesToUse, [iosDevice]);
    });

    test('finds iOS device by its name', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [iosDeviceName],
      );

      expect(devicesToUse, [iosDevice]);
    });
  });

  group('Device.bundledForTest()', () {
    test('returns a synthetic web device for chrome', () {
      final device = Device.bundledForTest('chrome');

      expect(
        device,
        isA<Device>()
            .having((d) => d.name, 'name', 'Chrome')
            .having((d) => d.id, 'id', 'chrome')
            .having(
              (d) => d.targetPlatform,
              'targetPlatform',
              TargetPlatform.web,
            )
            .having((d) => d.real, 'real', true),
      );
    });

    test('is case-insensitive and trims whitespace', () {
      expect(Device.bundledForTest(' Chrome '), isNotNull);
    });

    test('returns null for a device that is not bundled', () {
      expect(Device.bundledForTest('emulator-5554'), isNull);
    });
  });

  group('getAttachedDevices()', () {
    // Trimmed output of `flutter devices --machine` on a Linux arm64 host.
    const machineOutput = '''
[
  {"name": "Linux", "id": "linux", "isSupported": true, "targetPlatform": "linux-arm64", "emulator": false, "sdk": "Ubuntu 24.04 LTS 6.10.14-linuxkit"},
  {"name": "Linux x64", "id": "linux-x64", "isSupported": true, "targetPlatform": "linux-x64", "emulator": false, "sdk": "Ubuntu 24.04 LTS"},
  {"name": "Windows", "id": "windows", "isSupported": true, "targetPlatform": "windows-x64", "emulator": false, "sdk": "Windows 11"},
  {"name": "Pixel 5", "id": "emulator-5554", "isSupported": true, "targetPlatform": "android-arm64", "emulator": true, "sdk": "Android 14 (API 34)"}
]
''';

    test(
      'keeps Linux desktop devices and maps them to TargetPlatform.linux',
      () async {
        final process = FakeProcess();
        when(
          () =>
              processManager.start(any(), runInShell: any(named: 'runInShell')),
        ).thenAnswer((_) async {
          process.writeStdout(machineOutput.replaceAll('\n', ' '));
          // Exit only after the output went through the line decoder.
          Timer(const Duration(milliseconds: 10), () => process.exit(0));
          return process;
        });

        final devices = await deviceFinder.getAttachedDevices(
          flutterCommand: const FlutterCommand('flutter'),
        );

        expect(devices.map((d) => (d.id, d.targetPlatform, d.description)), [
          ('linux', TargetPlatform.linux, 'desktop Linux'),
          ('linux-x64', TargetPlatform.linux, 'desktop Linux x64'),
          ('emulator-5554', TargetPlatform.android, 'emulator-5554'),
        ]);
      },
    );
  });
}
