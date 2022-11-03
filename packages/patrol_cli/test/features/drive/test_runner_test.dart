import 'dart:async';

import 'package:fake_async/fake_async.dart';
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

void main() {
  late TestRunner testRunner;

  setUp(() {
    testRunner = TestRunner();
  });

  group('smoke tests', () {
    test('devices cannot be added after run', () {
      testRunner
        ..addDevice(device1)
        ..addTarget('app_test.dart');
      unawaited(
        testRunner.run((test, device) => Future.delayed(Duration(seconds: 1))),
      );

      expect(() => testRunner.addDevice(device1), throwsStateError);
    });

    test('tests cannot be added after run', () {
      testRunner
        ..addDevice(device1)
        ..addTarget('app_test.dart');
      unawaited(
        testRunner.run((test, device) => Future.delayed(Duration(seconds: 1))),
      );

      expect(() => testRunner.addTarget('login_test.dart'), throwsStateError);
    });

    test('cannot run with no devices', () {
      testRunner.addTarget('app_test.dart');

      expect(() => testRunner.run((test, device) async {}), throwsStateError);
    });

    test('cannot run with no tests', () {
      testRunner.addDevice(device1);

      expect(() => testRunner.run((test, device) async {}), throwsStateError);
    });

    test('cannot add devices with the same ID', () {
      testRunner.addDevice(device1);
      expect(() => testRunner.addDevice(device1), throwsStateError);
    });

    test('cannot run tests while they are already running', () {
      testRunner
        ..addDevice(device1)
        ..addTarget('app_test.dart');
      unawaited(testRunner.run((target, device) async {}));

      expect(() => testRunner.run((target, device) async {}), throwsStateError);
    });

    test('runs tests sequentially in FIFO order on a single device', () async {
      fakeAsync((fakeAsync) {
        var code = '';

        testRunner
          ..addDevice(device1)
          ..addTarget('A')
          ..addTarget('B')
          ..addTarget('C');

        expect(code, equals(''));
        testRunner.run((target, device) async {
          await Future<void>.delayed(Duration(seconds: 1));
          code = target;
        });

        fakeAsync.elapse(Duration(seconds: 1));
        expect(code, equals('A'));

        fakeAsync.elapse(Duration(seconds: 1));
        expect(code, equals('B'));

        fakeAsync.elapse(Duration(seconds: 1));
        expect(code, equals('C'));
      });
    });

    test('runs tests simultaneously on multiple devices', () {
      fakeAsync((fakeAsync) {
        final code = <String>[];

        testRunner
          ..addDevice(device1)
          ..addDevice(device2)
          ..addTarget('A')
          ..addTarget('B')
          ..addTarget('C');

        expect(code, equals(<String>[]));
        unawaited(
          testRunner.run((target, device) async {
            await Future<void>.delayed(Duration(seconds: 1));
            code.add('${device.id} $target');
          }),
        );

        fakeAsync.elapse(Duration(seconds: 1));
        expect(code, equals(['emulator-5554 A', 'emulator-5556 A']));

        fakeAsync.elapse(Duration(seconds: 1));
        expect(
          code,
          equals([
            'emulator-5554 A',
            'emulator-5556 A',
            'emulator-5554 B',
            'emulator-5556 B',
          ]),
        );

        fakeAsync.elapse(Duration(seconds: 1));
        expect(
          code,
          equals([
            'emulator-5554 A',
            'emulator-5556 A',
            'emulator-5554 B',
            'emulator-5556 B',
            'emulator-5554 C',
            'emulator-5556 C',
          ]),
        );
      });
    });
  });
}
