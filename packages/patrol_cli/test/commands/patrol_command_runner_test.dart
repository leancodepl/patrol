import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/extensions/command_runner.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
import 'package:patrol_cli/src/runner/patrol_command_runner.dart';
import 'package:platform/platform.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';
import '../ios/ios_test_backend_test.dart';
import '../src/mocks.dart';

const latestVersion = '999.0.0';

/// Strips ANSI color codes from a string
String stripAnsi(String str) {
  return str.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '');
}

void main() {
  group('PatrolCommandRunner', () {
    late Logger logger;
    late PubUpdater pubUpdater;
    late FileSystem fs;
    late PatrolCommandRunner commandRunner;

    // Save original compatibility list to restore after tests
    final originalList =
        List<VersionCompatibility>.from(versionCompatibilityList);

    tearDown(() {
      // Restore the original list after each test
      versionCompatibilityList
        ..clear()
        ..addAll(originalList);
    });

    setUp(() {
      logger = MockLogger();
      pubUpdater = MockPubUpdater();
      fs = MemoryFileSystem.test();

      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => constants.version);

      when(() => logger.info(any())).thenReturn(null);

      commandRunner = PatrolCommandRunner(
        platform: FakePlatform(environment: {}),
        processManager: FakeProcessManager(),
        pubUpdater: pubUpdater,
        fs: fs,
        analytics: MockAnalytics(),
        logger: logger,
        isCI: false,
      );
    });

    test('shows update message with compatibility warning when needed',
        () async {
      // Set up a compatibility list where patrol 3.0.0 is compatible only up to patrol_cli 2.5.0
      versionCompatibilityList
        ..clear()
        ..add(
          VersionCompatibility.fromRangeString(
            patrolCliVersion: '2.3.0 - 2.5.0',
            patrolVersion: '3.0.0 - 3.3.0',
            minFlutterVersion: '3.16.0',
          ),
        );

      // Set up a fake pubspec.yaml file with patrol dependency that is known to be incompatible
      final dir = fs.directory('/project')..createSync();
      dir.childFile('pubspec.yaml')
        ..createSync()
        ..writeAsStringSync('''
name: test_project
dependencies:
  patrol: ^3.0.0
''');
      fs.currentDirectory = dir;

      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => latestVersion);

      String? capturedMessage;
      when(() => logger.info(any())).thenAnswer((invocation) {
        final message = invocation.positionalArguments[0] as String;
        if (message.contains('Update available!')) {
          capturedMessage = stripAnsi(message);
        }
      });

      final result = await commandRunner.run(['--version']);
      expect(result, equals(0));

      expect(capturedMessage, contains('Update available!'));
      expect(
        capturedMessage,
        contains('${constants.version} → 2.5.0'),
      );
      expect(
        capturedMessage,
        contains(
          '(Newest patrol_cli $latestVersion is not compatible with project patrol version.)',
        ),
      );
      expect(
        capturedMessage,
        contains('To update to the latest compatible version, run:'),
      );
      expect(
        capturedMessage,
        contains('dart pub global activate patrol_cli 2.5.0'),
      );
      expect(
        capturedMessage,
        contains(
          '⚠️  Before updating, please ensure your patrol package version is compatible with patrol_cli $latestVersion',
        ),
      );
      expect(
        capturedMessage,
        contains(
          'Check the compatibility table at: https://patrol.leancode.co/documentation/compatibility-table',
        ),
      );
    });

    test('shows simple update message when no compatibility warning is needed',
        () async {
      // Set up a compatibility list where patrol 113.14.0 is compatible up to patrol_cli 114.0.0 (higher than test version)
      versionCompatibilityList
        ..clear()
        ..add(
          VersionCompatibility.fromRangeString(
            // We set ridiculously high version numbers to make sure that this
            // entry will always the highest versions in the compatibility list.
            patrolCliVersion: '113.5.0 - 114.0.0',
            patrolVersion: '113.14.0 - 113.15.0',
            minFlutterVersion: '113.24.0',
          ),
        );

      // Set up a fake pubspec.yaml file with patrol dependency that should be compatible
      final dir = fs.directory('/project')..createSync();
      dir.childFile('pubspec.yaml')
        ..createSync()
        ..writeAsStringSync('''
name: test_project
dependencies:
  patrol: ^113.14.0
''');
      fs.currentDirectory = dir;

      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => '113.5.5');

      String? capturedMessage;
      when(() => logger.info(any())).thenAnswer((invocation) {
        final message = invocation.positionalArguments[0] as String;
        if (message.contains('Update available!')) {
          capturedMessage = stripAnsi(message);
        }
      });

      final result = await commandRunner.run(['--version']);
      expect(result, equals(0));

      expect(capturedMessage, contains('Update available!'));
      expect(
        capturedMessage,
        contains('${constants.version} → 113.5.5'),
      );
      expect(
        capturedMessage,
        contains('Run patrol update to update to the latest version.'),
      );
      expect(
        capturedMessage,
        contains(
          'Check the compatibility table at: https://patrol.leancode.co/documentation/compatibility-table',
        ),
      );
    });

    test('handles FormatException', () async {
      const exception = FormatException('bad format');
      var isFirstInvocation = true;
      when(() => logger.info(any())).thenAnswer((_) {
        if (isFirstInvocation) {
          isFirstInvocation = false;
          throw exception;
        }
      });
      final result = await commandRunner.run(['--version']);
      expect(result, equals(1));
      verify(() => logger.err(exception.message)).called(1);
      verify(() => logger.info(commandRunner.usage)).called(1);
    });

    test('handles UsageException', () async {
      final exception = UsageException('not like this', 'here is how');
      var isFirstInvocation = true;
      when(() => logger.info(any())).thenAnswer((_) {
        if (isFirstInvocation) {
          isFirstInvocation = false;
          throw exception;
        }
      });
      final result = await commandRunner.run(['--version']);
      expect(result, equals(1));
      verify(() => logger.err(exception.message)).called(1);
      verify(() => logger.info(exception.usage)).called(1);
    });

    test('prints usage when no command is passed', () async {
      final result = await commandRunner.run([]);
      expect(result, equals(0));
      verify(() => logger.info(commandRunner.usage)).called(1);
    });

    test(
      'prints error message and usage when command option is passed',
      () async {
        final result = await commandRunner.run(['foo']);
        expect(result, equals(1));
        verify(
          () => logger.err('Could not find a command named "foo".'),
        ).called(1);
        verify(
          () => logger.info(commandRunner.usageWithoutDescription),
        ).called(1);
      },
    );

    test(
      'prints error message and usage when unknown option is passed',
      () async {
        final result = await commandRunner.run(['--bar']);
        expect(result, equals(1));
        verify(
          () => logger.err('Could not find an option named "--bar".'),
        ).called(1);
        verify(
          () => logger.info(commandRunner.usageWithoutDescription),
        ).called(1);
      },
    );

    group('--version', () {
      test('prints current version', () async {
        final result = await commandRunner.run(['--version']);
        expect(result, equals(0));
        verify(() => logger.info('patrol_cli v${constants.version}')).called(1);
      });
    });

    group('--verbose', () {
      test('enables verbose logging', () async {
        final result = await commandRunner.run(['--verbose']);
        expect(result, equals(0));

        verify(() {
          logger.info('Verbose mode enabled. More logs will be printed.');
        }).called(1);
      });
    });
  });
}
