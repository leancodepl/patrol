import 'dart:async';

import 'package:logging/logging.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
import 'package:test/test.dart';

final device1 = Device(
  name: 'sdk gphone64 arm64',
  id: 'emulator-5554',
  targetPlatform: TargetPlatform.android,
  real: false,
);

final device2 = Device(
  name: 'sdk gphone64 arm64',
  id: 'emulator-5556',
  targetPlatform: TargetPlatform.android,
  real: false,
);

Future<void> delay() => Future.delayed(Duration(seconds: 1));

void main() {
  late TestRunner testRunner;

  setUp(() {
    testRunner = TestRunner(logger: Logger(''));
  });

  group('TestRunner', () {
    group('run()', () {
      test('throws when no devices were added', () {
        testRunner.addTarget('app_test.dart', builder: delay);

        expect(() => testRunner.run((test, device) async {}), throwsStateError);
      });

      test('throws when no test targets were added', () {
        testRunner.addDevice(device1);

        expect(() => testRunner.run((test, device) async {}), throwsStateError);
      });

      test('throws when called while already running', () {
        testRunner
          ..addDevice(device1)
          ..addTarget('app_test.dart', builder: delay);
        unawaited(testRunner.run((target, device) async {}));

        expect(
          () => testRunner.run((target, device) async {}),
          throwsStateError,
        );
      });
    });

    group('addDevice()', () {
      test('throws when trying to add already added device', () {
        testRunner.addDevice(device1);
        expect(() => testRunner.addDevice(device1), throwsStateError);
      });

      test('throws when trying to add while running', () {
        testRunner
          ..addDevice(device1)
          ..addTarget('app_test.dart', builder: delay);
        unawaited(
          testRunner
              .run((test, device) => Future.delayed(Duration(seconds: 1))),
        );

        expect(() => testRunner.addDevice(device1), throwsStateError);
      });
    });

    group('addTarget()', () {
      test('throws when trying to add already added target', () {
        testRunner.addTarget('app_test.dart', builder: delay);
        expect(
          () => testRunner.addTarget('app_test.dart', builder: delay),
          throwsStateError,
        );
      });

      test('throws when trying to add while running', () {
        testRunner
          ..addDevice(device1)
          ..addTarget('app_test.dart', builder: delay);
        unawaited(
          testRunner
              .run((test, device) => Future.delayed(Duration(seconds: 1))),
        );

        expect(
          () => testRunner.addTarget('login_test.dart', builder: delay),
          throwsStateError,
        );
      });
    });
  });
}
