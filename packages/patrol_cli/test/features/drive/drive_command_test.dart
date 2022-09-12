import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:patrol_cli/src/features/drive/drive_command.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const _androidDeviceName = 'Pixel 5';
const _androidDeviceId = 'emulator-5554';
const _androidDevice = Device(
  name: _androidDeviceName,
  id: _androidDeviceId,
  targetPlatform: TargetPlatform.android,
  real: true,
);

const _iosDeviceName = 'iPhone 13';
const _iosDeviceId = '00008101-001611D026A0001E';
const _iosDevice = Device(
  name: _iosDeviceName,
  id: _iosDeviceId,
  targetPlatform: TargetPlatform.iOS,
  real: true,
);

void main() {
  group('finds device to use when', () {
    test('no devices available, no devices wanted', () {
      final devicesToUse = DriveCommand.findOverlap(
        availableDevices: [],
        wantDevices: [],
      );

      expect(devicesToUse, <String>[]);
    });

    test('1 device available, no devices wanted', () {
      final devicesToUse = DriveCommand.findOverlap(
        availableDevices: [_androidDevice],
        wantDevices: [],
      );

      expect(devicesToUse, <Device>[]);
    });

    test('1 device available, 1 device wanted (match)', () {
      final devicesToUse = DriveCommand.findOverlap(
        availableDevices: [_androidDevice],
        wantDevices: [_androidDeviceId],
      );

      expect(devicesToUse, [_androidDevice]);
    });

    test('1 device available, 1 device wanted (no match)', () {
      void func() {
        DriveCommand.findOverlap(
          availableDevices: [_androidDevice],
          wantDevices: [_iosDeviceName],
        );
      }

      expect(
        func,
        throwsA(
          isA<Exception>().having(
            (exception) => exception.toString(),
            'message',
            'Exception: Device $_iosDeviceName is not available',
          ),
        ),
      );
    });

    test('2 devices available, 1 device wanted (full match)', () {
      final devicesToUse = DriveCommand.findOverlap(
        availableDevices: [_androidDevice, _iosDevice],
        wantDevices: [_androidDeviceId],
      );

      expect(devicesToUse, [_androidDevice]);
    });

    test('2 devices available, 2 devices wanted (full match)', () {
      final devicesToUse = DriveCommand.findOverlap(
        availableDevices: [_androidDevice, _iosDevice],
        wantDevices: [_androidDeviceId, _iosDeviceName],
      );

      expect(devicesToUse, [_androidDevice, _iosDevice]);
    });

    test('0 devices available, 2 devices wanted (full match)', () {
      final devicesToUse = DriveCommand.findOverlap(
        availableDevices: [_androidDevice, _iosDevice],
        wantDevices: [_androidDeviceId, _iosDeviceName],
      );

      expect(devicesToUse, [_androidDevice, _iosDevice]);
    });
  });
}
