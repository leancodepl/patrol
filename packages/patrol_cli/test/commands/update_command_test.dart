import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/commands/update.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

const _latestVersion = '999.0.0';

void main() {
  group('UpdateCommand', () {
    late MockLogger mockLogger;
    late MockProgress mockProgress;
    late MockPubUpdater mockPubUpdater;
    late CommandRunner<int> runner;

    setUp(() {
      mockLogger = MockLogger();
      mockProgress = MockProgress();
      mockPubUpdater = MockPubUpdater();

      when(() => mockLogger.progress(any())).thenReturn(mockProgress);
      when(() => mockLogger.err(any())).thenReturn(null);

      when(
        () => mockPubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => _latestVersion);

      runner = CommandRunner<int>('patrol', 'Test runner')
        ..argParser.addOption('flutter-command', defaultsTo: 'flutter')
        ..addCommand(
          UpdateCommand(
            pubUpdater: mockPubUpdater,
            analytics: MockAnalytics(),
            logger: mockLogger,
          ),
        );
    });

    void stubUpdate(ProcessResult result) {
      when(
        () => mockPubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      ).thenAnswer((_) async => result);
    }

    test('activates exactly the latest version', () async {
      stubUpdate(ProcessResult(0, 0, '', ''));

      final result = await runner.run(['update']);

      expect(result, equals(0));
      verify(
        () => mockPubUpdater.update(
          packageName: 'patrol_cli',
          versionConstraint: _latestVersion,
        ),
      ).called(1);
      verify(
        () => mockProgress.complete('Updated patrol_cli to version 999.0.0'),
      ).called(1);
    });

    test('fails and prints the reason when pub fails to activate', () async {
      // E.g. the latest version requires a newer Dart SDK.
      // See https://github.com/leancodepl/patrol/issues/2347
      stubUpdate(
        ProcessResult(
          0,
          65,
          'Resolving dependencies...',
          'The current Dart SDK version is 3.0.0.',
        ),
      );

      final result = await runner.run(['update']);

      expect(result, equals(1));
      verify(
        () =>
            mockProgress.fail('Failed to update patrol_cli to version 999.0.0'),
      ).called(1);
      verify(() => mockLogger.err('Resolving dependencies...')).called(1);
      verify(
        () => mockLogger.err('The current Dart SDK version is 3.0.0.'),
      ).called(1);
      verifyNever(() => mockProgress.complete(any()));
    });

    test('fails when activating throws', () async {
      when(
        () => mockPubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      ).thenThrow(const ProcessException('dart', ['pub']));

      final result = await runner.run(['update']);

      expect(result, equals(1));
      verify(
        () =>
            mockProgress.fail('Failed to update patrol_cli to version 999.0.0'),
      ).called(1);
    });

    test('does nothing when already on the latest version', () async {
      when(
        () => mockPubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => constants.version);

      final result = await runner.run(['update']);

      expect(result, equals(0));
      verifyNever(
        () => mockPubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      );
    });
  });
}
