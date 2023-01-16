// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:patrol_cli/src/features/run_commons/result.dart';
import 'package:patrol_cli/src/features/test/native_test_runner.dart';
import 'package:test/test.dart';

import '../../fixtures.dart';

Future<void> delay() => Future.delayed(Duration(seconds: 1));

void main() {
  late NativeTestRunner testRunner;

  setUp(() {
    testRunner = NativeTestRunner();
  });

  group('FlutterTestRunner', () {
    setUp(() {
      testRunner.executor = (_, __) => delay();
    });

    group('set repeats', () {
      test('throws when called while running', () {
        testRunner
          ..addDevice(androidDevice)
          ..addTarget('app_test.dart');

        testRunner.run();
        expect(() => testRunner.repeats = 3, throwsStateError);
      });
    });

    group('addDevice()', () {
      test('throws when trying to add already added device', () {
        testRunner.addDevice(androidDevice);
        expect(() => testRunner.addDevice(androidDevice), throwsStateError);
      });

      test('throws when trying to add while running', () {
        testRunner
          ..addDevice(androidDevice)
          ..addTarget('app_test.dart');
        unawaited(testRunner.run());

        expect(() => testRunner.addDevice(androidDevice), throwsStateError);
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
          ..addDevice(androidDevice)
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

        testRunner.executor = (target, device) async {
          await delay();
          actualLog.add('execute $target ${device.id}');
        };
      });

      test('throws when no devices were added', () {
        testRunner.addTarget('app_test.dart');

        expect(() => testRunner.run(), throwsStateError);
      });

      test('throws when no test targets were added', () {
        testRunner.addDevice(androidDevice);

        expect(() => testRunner.run(), throwsStateError);
      });

      test('throws when called while already running', () {
        testRunner
          ..addDevice(androidDevice)
          ..addTarget('app_test.dart');
        unawaited(testRunner.run());

        expect(
          () => testRunner.run(),
          throwsStateError,
        );
      });

      test(
        'builds and executes test targets sequentially on single device',
        () {
          fakeAsync((fakeAsync) {
            testRunner
              ..addDevice(androidDevice)
              ..addTarget('A')
              ..addTarget('B')
              ..addTarget('C');

            expect(actualLog, equals(<String>[]));
            testRunner.run();

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute A ${androidDevice.id}');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute B ${androidDevice.id}');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute C ${androidDevice.id}');
            expect(actualLog, equals(expectedLog));
          });
        },
      );

      test('runs repeated tests sequentially on single device', () {
        testRunner.repeats = 3;

        fakeAsync((fakeAsync) {
          testRunner
            ..addDevice(androidDevice)
            ..addTarget('A')
            ..addTarget('B')
            ..addTarget('C');

          final expectedLog = <String>[];
          expect(actualLog, expectedLog);
          unawaited(testRunner.run());

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute B ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute B ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute B ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute C ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute C ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute C ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));
        });
      });

      test('runs tests simultaneously on multiple devices', () {
        fakeAsync((fakeAsync) {
          testRunner
            ..addDevice(androidDevice)
            ..addDevice(iosDevice)
            ..addTarget('A')
            ..addTarget('B')
            ..addTarget('C');

          final expectedLog = <String>[];
          expect(actualLog, equals(<String>[]));
          late RunResults result;
          unawaited(() async {
            result = await testRunner.run();
          }());

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.addAll(
            ['execute A ${androidDevice.id}', 'execute A ${iosDevice.id}'],
          );
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.addAll(
            ['execute B ${androidDevice.id}', 'execute B ${iosDevice.id}'],
          );
          expect(actualLog, expectedLog);

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.addAll(
            ['execute C ${androidDevice.id}', 'execute C ${iosDevice.id}'],
          );
          expect(actualLog, expectedLog);

          expect(
            result,
            RunResults(
              targetRunResults: [
                TargetRunResult(
                  target: 'A',
                  device: androidDevice,
                  runs: [TargetRunStatus.passed],
                ),
                TargetRunResult(
                  target: 'A',
                  device: iosDevice,
                  runs: [TargetRunStatus.passed],
                ),
                TargetRunResult(
                  target: 'B',
                  device: androidDevice,
                  runs: [TargetRunStatus.passed],
                ),
                TargetRunResult(
                  target: 'B',
                  device: iosDevice,
                  runs: [TargetRunStatus.passed],
                ),
                TargetRunResult(
                  target: 'C',
                  device: androidDevice,
                  runs: [TargetRunStatus.passed],
                ),
                TargetRunResult(
                  target: 'C',
                  device: iosDevice,
                  runs: [TargetRunStatus.passed],
                ),
              ],
            ),
          );
        });
      });

      test('handles disposal correctly', () {
        fakeAsync((fakeAsync) {
          testRunner
            ..addDevice(androidDevice)
            ..addTarget('A')
            ..addTarget('B')
            ..addTarget('C');

          expect(actualLog, equals(<String>[]));
          testRunner.run();

          testRunner.dispose();
          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 10));
          expect(actualLog, equals(expectedLog));
        });
      });
    });
  });
}
