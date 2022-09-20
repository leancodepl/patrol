import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:test/test.dart';

import 'fixures/devices.dart';

void main() {
  late DeviceFinder deviceFinder;

  setUp(() {
    deviceFinder = DeviceFinder();
  });

  group('findDevicesToUse', () {
    test('no devices attached, no devices wanted', () {
      expect(
        () => deviceFinder.findDevicesToUse(
          attachedDevices: [],
          wantDevices: [],
        ),
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

        expect(devicesToUse, <Device>[androidDevice]);
      },
    );

    test('1 device attached, 1 device wanted (match)', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice],
        wantDevices: [androidDeviceId],
      );

      expect(devicesToUse, [androidDevice]);
    });

    test('1 device attached, 1 device wanted (no match)', () {
      expect(
        () {
          deviceFinder.findDevicesToUse(
            attachedDevices: [androidDevice],
            wantDevices: [iosDeviceName],
          );
        },
        throwsA(
          isA<ToolExit>().having(
            (err) => err.message,
            'message',
            'Device $iosDeviceName is not attached',
          ),
        ),
      );
    });

    test('2 devices attached, 1 device wanted (full match)', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId],
      );

      expect(devicesToUse, [androidDevice]);
    });

    test('2 devices attached, 2 devices wanted (full match)', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId, iosDeviceName],
      );

      expect(devicesToUse, [androidDevice, iosDevice]);
    });

    test('0 devices attached, 2 devices wanted (full match)', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId, iosDeviceName],
      );

      expect(devicesToUse, [androidDevice, iosDevice]);
    });
  });
}
