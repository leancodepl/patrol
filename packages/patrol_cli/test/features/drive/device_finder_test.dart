import 'package:logging/logging.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:test/test.dart';

import 'fixures/devices.dart';

void main() {
  late DeviceFinder deviceFinder;

  setUp(() {
    final logger = Logger('');

    deviceFinder = DeviceFinder(logger: logger);
  });

  group('findDevicesToUse', () {
    test('throws when no devices are attached', () {
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
  });
}
