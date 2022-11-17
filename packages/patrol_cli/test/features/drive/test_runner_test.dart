// ignore_for_file: cascade_invocations

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

Future<void> delay() => Future.delayed(Duration(seconds: 1));

void main() {
  late TestRunner testRunner;

  setUp(() {
    testRunner = TestRunner();
  });

  group('TestRunner', () {
    setUp(() {
      testRunner.builder = (_, __) => delay();
      testRunner.executor = (_, __) => delay();
    });

    group('set repeats', () {
      test('throws when called while running', () {
        testRunner
          ..addDevice(device1)
          ..addTarget('app_test.dart');

        testRunner.run();
        expect(() => testRunner.repeats = 3, throwsStateError);
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
          ..addTarget('app_test.dart');
        unawaited(testRunner.run());

        expect(() => testRunner.addDevice(device1), throwsStateError);
      });
    });

    group('addTarget()', () {
      test('throws when trying to add already added test target', () {
        testRunner.addTarget('app_test.dart');
        expect(
          () => testRunner.addTarget('app_test.dart'),
          throwsStateError,
        );
      });

      test('throws when trying to add while running', () {
        testRunner
          ..addDevice(device1)
          ..addTarget('app_test.dart');
        unawaited(testRunner.run());

        expect(
          () => testRunner.addTarget('login_test.dart'),
          throwsStateError,
        );
      });
    });

    group('run()', () {
      late List<String> actualLog;
      late List<String> expectedLog;

      setUp(() {
        actualLog = [];
        expectedLog = [];

        testRunner
          ..builder = (target, device) async {
            await delay();
            actualLog.add('build $target ${device.id}');
          }
          ..executor = (target, device) async {
            await delay();
            actualLog.add('execute $target ${device.id}');
          };
      });

      test('throws when no devices were added', () {
        testRunner.addTarget('app_test.dart');

        expect(() => testRunner.run(), throwsStateError);
      });

      test('throws when no test targets were added', () {
        testRunner.addDevice(device1);

        expect(() => testRunner.run(), throwsStateError);
      });

      test('throws when called while already running', () {
        testRunner
          ..addDevice(device1)
          ..addTarget('app_test.dart');
        unawaited(testRunner.run());

        expect(
          () => testRunner.run(),
          throwsStateError,
        );
      });

      test(
        'builds and executes test targets sequentially on single device',
        () async {
          fakeAsync((fakeAsync) {
            testRunner
              ..addDevice(device1)
              ..addTarget('A')
              ..addTarget('B')
              ..addTarget('C');

            expect(actualLog, equals(<String>[]));
            testRunner.run();

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('build A emulator-5554');
            expect(actualLog, equals(actualLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute A emulator-5554');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('build B emulator-5554');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute B emulator-5554');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('build C emulator-5554');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute C emulator-5554');
            expect(actualLog, equals(expectedLog));
          });
        },
      );

      test('runs repeated tests sequentially on single device', () {
        testRunner.repeats = 3;

        fakeAsync((fakeAsync) {
          testRunner
            ..addDevice(device1)
            ..addTarget('A')
            ..addTarget('B')
            ..addTarget('C');

          final expectedLog = <String>[];
          expect(actualLog, expectedLog);
          unawaited(testRunner.run());

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('build A emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('build B emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute B emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute B emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute B emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('build C emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute C emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute C emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute C emulator-5554');
          expect(actualLog, equals(expectedLog));
        });
      });

      test('runs tests simultaneously on multiple devices', () {
        fakeAsync((fakeAsync) {
          testRunner
            ..addDevice(device1)
            ..addDevice(device2)
            ..addTarget('A')
            ..addTarget('B')
            ..addTarget('C');

          final expectedLog = <String>[];
          expect(actualLog, equals(<String>[]));
          unawaited(testRunner.run());

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog
              .addAll(['build A emulator-5554', 'build A emulator-5556']);
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog
              .addAll(['execute A emulator-5554', 'execute A emulator-5556']);
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog
              .addAll(['build B emulator-5554', 'build B emulator-5556']);
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog
              .addAll(['execute B emulator-5554', 'execute B emulator-5556']);
          expect(actualLog, expectedLog);

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog
              .addAll(['build C emulator-5554', 'build C emulator-5556']);
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog
              .addAll(['execute C emulator-5554', 'execute C emulator-5556']);
          expect(actualLog, expectedLog);
        });
      });

      test('handles disposal correctly', () async {
        fakeAsync((fakeAsync) {
          testRunner
            ..addDevice(device1)
            ..addTarget('A')
            ..addTarget('B')
            ..addTarget('C');

          expect(actualLog, equals(<String>[]));
          testRunner.run();

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('build A emulator-5554');
          expect(actualLog, equals(actualLog));

          testRunner.dispose();
          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A emulator-5554');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 10));
          expect(actualLog, equals(expectedLog));
        });
      });

      test('does not execute test target if it failed to build', () async {
        final actualLog = <String>[];

        final testRunner = TestRunner();
        testRunner
          ..addDevice(device1)
          ..addTarget('A')
          ..addTarget('B')
          ..addTarget('C');

        testRunner.builder = (target, device) async {
          actualLog.add('start build $target ${device.id}');
          if (target == 'B') {
            throw Exception('build failed');
          }
          actualLog.add('end build $target ${device.id}');
        };
        testRunner.executor = (target, device) async {
          actualLog.add('start execute $target ${device.id}');
          actualLog.add('end execute $target ${device.id}');
        };

        await testRunner.run();
        expect(actualLog, [
          'start build A emulator-5554',
          'end build A emulator-5554',
          'start execute A emulator-5554',
          'end execute A emulator-5554',
          'start build B emulator-5554',
          'start build C emulator-5554',
          'end build C emulator-5554',
          'start execute C emulator-5554',
          'end execute C emulator-5554',
        ]);
      });

      test(
        'continues to run tests if one test target failed to execute',
        () async {
          final actualLog = <String>[];

          final testRunner = TestRunner();
          testRunner
            ..addDevice(device1)
            ..addTarget('A')
            ..addTarget('B')
            ..addTarget('C');

          testRunner.builder = (target, device) async {
            actualLog.add('start build $target ${device.id}');
            actualLog.add('end build $target ${device.id}');
          };
          testRunner.executor = (target, device) async {
            actualLog.add('start execute $target ${device.id}');
            if (target == 'B') {
              throw Exception('build failed');
            }
            actualLog.add('end execute $target ${device.id}');
          };

          await testRunner.run();
          expect(actualLog, [
            'start build A emulator-5554',
            'end build A emulator-5554',
            'start execute A emulator-5554',
            'end execute A emulator-5554',
            'start build B emulator-5554',
            'end build B emulator-5554',
            'start execute B emulator-5554',
            'start build C emulator-5554',
            'end build C emulator-5554',
            'start execute C emulator-5554',
            'end execute C emulator-5554',
          ]);
        },
      );
    });
  });
}
