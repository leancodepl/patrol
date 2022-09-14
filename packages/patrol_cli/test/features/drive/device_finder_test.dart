import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:test/test.dart';

import 'fixures/devices.dart';

void main() {
  late DeviceFinder deviceFinder;

  setUp(() {
    deviceFinder = DeviceFinder();
  });

  group('finds device to use when', () {
    test('no devices attached, no devices wanted', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [],
        wantDevices: [],
      );

      expect(devicesToUse, <String>[]);
    });

    test('1 device attached, no devices wanted', () {
      final devicesToUse = deviceFinder.findDevicesToUse(
        attachedDevices: [androidDevice],
        wantDevices: [],
      );

      expect(devicesToUse, <Device>[]);
    });

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
          isA<Exception>().having(
            (exception) => exception.toString(),
            'message',
            'Exception: Device $iosDeviceName is not attached',
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
