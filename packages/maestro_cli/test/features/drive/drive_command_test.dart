import 'package:maestro_cli/src/features/drive/device.dart';
import 'package:maestro_cli/src/features/drive/drive_command.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'fixures/devices.dart';

void main() {
  group('finds device to use when', () {
    test('no devices available, no devices wanted', () {
      final devicesToUse = DriveCommand.findDevicesToRun(
        availableDevices: [],
        wantDevices: [],
      );

      expect(devicesToUse, <String>[]);
    });

    test('1 device available, no devices wanted', () {
      final devicesToUse = DriveCommand.findDevicesToRun(
        availableDevices: [androidDevice],
        wantDevices: [],
      );

      expect(devicesToUse, <Device>[]);
    });

    test('1 device available, 1 device wanted (match)', () {
      final devicesToUse = DriveCommand.findDevicesToRun(
        availableDevices: [androidDevice],
        wantDevices: [androidDeviceId],
      );

      expect(devicesToUse, [androidDevice]);
    });

    test('1 device available, 1 device wanted (no match)', () {
      void func() {
        DriveCommand.findDevicesToRun(
          availableDevices: [androidDevice],
          wantDevices: [iosDeviceName],
        );
      }

      expect(
        func,
        throwsA(
          isA<Exception>().having(
            (exception) => exception.toString(),
            'message',
            'Exception: Device $iosDeviceName is not available',
          ),
        ),
      );
    });

    test('2 devices available, 1 device wanted (full match)', () {
      final devicesToUse = DriveCommand.findDevicesToRun(
        availableDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId],
      );

      expect(devicesToUse, [androidDevice]);
    });

    test('2 devices available, 2 devices wanted (full match)', () {
      final devicesToUse = DriveCommand.findDevicesToRun(
        availableDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId, iosDeviceName],
      );

      expect(devicesToUse, [androidDevice, iosDevice]);
    });

    test('0 devices available, 2 devices wanted (full match)', () {
      final devicesToUse = DriveCommand.findDevicesToRun(
        availableDevices: [androidDevice, iosDevice],
        wantDevices: [androidDeviceId, iosDeviceName],
      );

      expect(devicesToUse, [androidDevice, iosDevice]);
    });
  });
}
