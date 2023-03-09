import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:test/test.dart';

import '../src/fixtures.dart';
import '../src/mocks.dart';

void main() {
  late DeviceFinder deviceFinder;

  setUp(() {
    final processManager = MockProcessManager();
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

        expect(devicesToUse, [androidDevice]);
      },
    );

    test(
      'returns the first device when 2 devices is attached and no devices are '
      'wanted',
      () {
        final devicesToUse = deviceFinder.findDevicesToUse(
          attachedDevices: [androidDevice, iosDevice],
          wantDevices: [],
        );

        expect(devicesToUse, [androidDevice]);
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
}
