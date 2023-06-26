// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:patrol_cli/src/test_runner.dart';
import 'package:test/test.dart';

import '../src/fixtures.dart';

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
      var buildCalled = false;

      setUp(() {
        actualLog = [];
        expectedLog = [];
        buildCalled = false;

        testRunner
          ..builder = (target, device) async {
            buildCalled = true;
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
            expectedLog.add('build A ${androidDevice.id}');
            expect(actualLog, equals(actualLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute A ${androidDevice.id}');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('build B ${androidDevice.id}');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute B ${androidDevice.id}');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('build C ${androidDevice.id}');
            expect(actualLog, equals(expectedLog));

            fakeAsync.elapse(Duration(seconds: 1));
            expectedLog.add('execute C ${androidDevice.id}');
            expect(actualLog, equals(expectedLog));

            expect(buildCalled, true);
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
          expectedLog.add('build A ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

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
          expectedLog.add('build B ${androidDevice.id}');
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
          expectedLog.add('build C ${androidDevice.id}');
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
            ['build A ${androidDevice.id}', 'build A ${iosDevice.id}'],
          );
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.addAll(
            ['execute A ${androidDevice.id}', 'execute A ${iosDevice.id}'],
          );
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.addAll(
            ['build B ${androidDevice.id}', 'build B ${iosDevice.id}'],
          );
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.addAll(
            ['execute B ${androidDevice.id}', 'execute B ${iosDevice.id}'],
          );
          expect(actualLog, expectedLog);

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.addAll(
            ['build C ${androidDevice.id}', 'build C ${iosDevice.id}'],
          );
          expect(actualLog, equals(expectedLog));

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

          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('build A ${androidDevice.id}');
          expect(actualLog, equals(actualLog));

          testRunner.dispose();
          fakeAsync.elapse(Duration(seconds: 1));
          expectedLog.add('execute A ${androidDevice.id}');
          expect(actualLog, equals(expectedLog));

          fakeAsync.elapse(Duration(seconds: 10));
          expect(actualLog, equals(expectedLog));
        });
      });

      test('does not execute test target if it failed to build', () async {
        final actualLog = <String>[];

        final testRunner = TestRunner();
        testRunner
          ..addDevice(androidDevice)
          ..addTarget('A')
          ..addTarget('B')
          ..addTarget('C');

        testRunner.builder = (target, device) async {
          actualLog.add('start build $target ${device.id}');
          if (target == 'B') {
            throw Exception('failed to build');
          }
          actualLog.add('end build $target ${device.id}');
        };
        testRunner.executor = (target, device) async {
          actualLog.add('start execute $target ${device.id}');
          actualLog.add('end execute $target ${device.id}');
        };

        final result = await testRunner.run();
        expect(actualLog, [
          'start build A ${androidDevice.id}',
          'end build A ${androidDevice.id}',
          'start execute A ${androidDevice.id}',
          'end execute A ${androidDevice.id}',
          'start build B ${androidDevice.id}',
          'start build C ${androidDevice.id}',
          'end build C ${androidDevice.id}',
          'start execute C ${androidDevice.id}',
          'end execute C ${androidDevice.id}',
        ]);

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
                target: 'B',
                device: androidDevice,
                runs: [TargetRunStatus.failedToBuild],
              ),
              TargetRunResult(
                target: 'C',
                device: androidDevice,
                runs: [TargetRunStatus.passed],
              ),
            ],
          ),
        );
      });

      test(
        'continues to run tests if one test target failed to execute',
        () async {
          final actualLog = <String>[];

          final testRunner = TestRunner();
          testRunner
            ..addDevice(androidDevice)
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
              throw Exception('failed to execute');
            }
            actualLog.add('end execute $target ${device.id}');
          };

          final result = await testRunner.run();
          expect(actualLog, [
            'start build A ${androidDevice.id}',
            'end build A ${androidDevice.id}',
            'start execute A ${androidDevice.id}',
            'end execute A ${androidDevice.id}',
            'start build B ${androidDevice.id}',
            'end build B ${androidDevice.id}',
            'start execute B ${androidDevice.id}',
            'start build C ${androidDevice.id}',
            'end build C ${androidDevice.id}',
            'start execute C ${androidDevice.id}',
            'end execute C ${androidDevice.id}',
          ]);

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
                  target: 'B',
                  device: androidDevice,
                  runs: [TargetRunStatus.failedToExecute],
                ),
                TargetRunResult(
                  target: 'C',
                  device: androidDevice,
                  runs: [TargetRunStatus.passed],
                ),
              ],
            ),
          );
        },
      );
    });
  });
}
