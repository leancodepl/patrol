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

  // TODO: decide if the same device can be added many times

  test('devices cannot be added after run', () {
    testRunner
      ..addDevice(device1)
      ..addTest((device) => Future.delayed(Duration(seconds: 1)))
      ..run();

    expect(() => testRunner.addDevice(device1), throwsStateError);
  });

  test('tests cannot be added after run', () {
    testRunner
      ..addDevice(device1)
      ..addTest((device) => Future.delayed(Duration(seconds: 1)))
      ..run();

    expect(() => testRunner.addTest((_) async {}), throwsStateError);
  });

  test('cannot run with no devices', () {
    testRunner.addTest((device) => Future.delayed(Duration(seconds: 1)));

    expect(testRunner.run, throwsStateError);
  });

  test('cannot run with no tests', () {
    testRunner.addDevice(device1);

    expect(testRunner.run, throwsStateError);
  });

  test('cannot run tests while they are already running', () {
    testRunner
      ..addDevice(device1)
      ..addTest((device) => Future.delayed(Duration(seconds: 1)))
      ..run();

    expect(testRunner.run, throwsStateError);
  });

  test('runs tests sequentially in FIFO order on a single device', () async {
    fakeAsync((fakeAsync) {
      var code = '';

      testRunner
        ..addDevice(device1)
        ..addTest((device) async {
          await Future<void>.delayed(Duration(seconds: 1));
          code = 'A';
        })
        ..addTest((device) async {
          await Future<void>.delayed(Duration(seconds: 1));
          code = 'B';
        })
        ..addTest((device) async {
          await Future<void>.delayed(Duration(seconds: 1));
          code = 'C';
        });

      expect(code, equals(''));
      testRunner.run();

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
        ..addTest((device) async {
          await Future<void>.delayed(Duration(seconds: 1));
          code.add('${device.id} A');
        })
        ..addTest((device) async {
          await Future<void>.delayed(Duration(seconds: 1));
          code.add('${device.id} B');
        })
        ..addTest((device) async {
          await Future<void>.delayed(Duration(seconds: 1));
          code.add('${device.id} C');
        });

      expect(code, equals(<String>[]));
      testRunner.run();

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
}
